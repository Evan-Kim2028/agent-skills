# External API client ingestion

> Patterns for **consuming** external HTTP APIs in data pipelines — blockchain indexers,
> marketplace APIs, price trackers, FX feeds. For serving your own data APIs see
> `serving.md`. For one-off interactive tool calls prefer an MCP server instead.
> Code shown against **httpx 0.27** and **pydantic 2.x**; re-check signatures on upgrade.

## 1. Rate limiting — token-bucket + `Retry-After`

```python
import time, threading

class TokenBucket:
    def __init__(self, rate: float, capacity: float):
        self.rate, self.capacity = rate, capacity
        self._tokens, self._last = capacity, time.monotonic()
        self._lock = threading.Lock()

    def consume(self, tokens: float = 1.0):
        with self._lock:
            now = time.monotonic()
            self._tokens = min(self.capacity, self._tokens + (now - self._last) * self.rate)
            self._last = now
            wait = max(0.0, (tokens - self._tokens) / self.rate)
        if wait:
            time.sleep(wait)
        with self._lock:
            self._tokens -= tokens

rps_bucket = TokenBucket(rate=10, capacity=20)   # 10 req/s, burst 20
```

LLM-style quota APIs carry a *dual* quota — instantiate two buckets (requests/min
**and** tokens/min) and consume from both before each call.

## 2. Retries — exponential backoff with jitter

Retry **only** on 429 / 5xx and **only** for idempotent reads. Never blindly retry
a POST that mutates state. This is the client-side twin of shared resilience
patterns — see [`../../data/references/resilience-and-idempotency.md`](../../data/references/resilience-and-idempotency.md).

```python
import random, httpx

RETRYABLE = {429, 500, 502, 503, 504}

def get_with_backoff(client: httpx.Client, url: str, **kw) -> httpx.Response:
    for attempt in range(5):
        resp = client.get(url, **kw)
        if resp.status_code not in RETRYABLE:
            resp.raise_for_status()
            return resp
        if attempt == 4:
            resp.raise_for_status()
        retry_after = resp.headers.get("Retry-After")
        wait = float(retry_after) if retry_after else 0.5 * 2**attempt * (1 + 0.25 * random.random())
        time.sleep(wait)
```

## 3. Pagination — resumable generator with persisted cursor

One page resident in RAM at a time. Persist the cursor after each page so a crash
resumes mid-run, not from page 1.

```python
import json, pathlib
from typing import Any, Generator

CURSOR_DIR = pathlib.Path("/var/run/ingestion")

def _load(source: str) -> dict:
    p = CURSOR_DIR / f"{source}.cursor.json"
    return json.loads(p.read_text()) if p.exists() else {}

def _save(source: str, state: dict):
    CURSOR_DIR.mkdir(parents=True, exist_ok=True)
    tmp = CURSOR_DIR / f"{source}.cursor.tmp"
    tmp.write_text(json.dumps(state))
    tmp.rename(CURSOR_DIR / f"{source}.cursor.json")   # atomic on POSIX

def paginate(client: httpx.Client, source: str, url: str) -> Generator[list[Any], None, None]:
    state = _load(source)
    params: dict[str, Any] = {k: v for k, v in state.items() if k in ("cursor", "after", "page")}
    while True:
        data = get_with_backoff(client, url, params=params).json()
        records = data.get("data") or data.get("results") or data
        if not records:
            break
        yield records
        # Detect cursor style: token, keyset, or offset
        if nc := (data.get("next_cursor") or data.get("next_page_token")):
            state, params = {"cursor": nc}, {"cursor": nc}
        elif lid := data.get("last_id"):
            state, params = {"after": lid}, {"after": lid}
        else:
            pg = state.get("page", 1) + 1
            state, params = {"page": pg}, {"page": pg}
        _save(source, state)
        if not data.get("has_more", True):
            break
```

## 4. Conditional requests — ETag / 304

```python
import shelve

CACHE_DB = "/var/cache/ingestion/http_cache"

def conditional_get(client: httpx.Client, url: str) -> tuple[bytes | None, bool]:
    """Returns (body, changed). body is None on 304."""
    with shelve.open(CACHE_DB) as c:
        entry = c.get(url, {})
    hdrs = {}
    if "etag" in entry:       hdrs["If-None-Match"]     = entry["etag"]
    if "last_mod" in entry:   hdrs["If-Modified-Since"] = entry["last_mod"]
    resp = get_with_backoff(client, url, headers=hdrs)
    if resp.status_code == 304:
        return None, False
    with shelve.open(CACHE_DB) as c:
        c[url] = {"etag": resp.headers.get("ETag", ""),
                  "last_mod": resp.headers.get("Last-Modified", "")}
    return resp.content, True
```

## 5. Auth & secrets — env / secret manager, inline token refresh

```python
import os

def _secret(key: str) -> str:
    if v := os.getenv(key):
        return v
    import boto3, json as _j
    return _j.loads(boto3.client("secretsmanager")
                    .get_secret_value(SecretId=key)["SecretString"])[key]

def _refresh(client: httpx.Client) -> str:
    r = client.post(os.environ["TOKEN_URL"],
                    data={"grant_type": "client_credentials",
                          "client_id": _secret("API_CLIENT_ID"),
                          "client_secret": _secret("API_CLIENT_SECRET")})
    r.raise_for_status()
    return r.json()["access_token"]

def authed_get(client: httpx.Client, url: str, token: list[str], **kw) -> httpx.Response:
    """token is a 1-element list so callers share the refreshed value."""
    for _ in range(2):
        r = client.get(url, headers={"Authorization": f"Bearer {token[0]}"}, **kw)
        if r.status_code != 401:
            r.raise_for_status(); return r
        token[0] = _refresh(client)
    r.raise_for_status(); return r
```

## 6. Schema validation at the boundary

Validate with Pydantic **before** the payload enters the pipeline. A broken upstream
response must fail loudly at ingestion, not corrupt a gold table three stages later.

```python
from pydantic import BaseModel, ValidationError, field_validator

class TradeRecord(BaseModel):
    trade_id: str
    price:    float
    quantity: float
    ts:       int           # unix epoch ms

    @field_validator("price", "quantity")
    @classmethod
    def positive(cls, v: float) -> float:
        if v <= 0: raise ValueError(f"must be positive, got {v}")
        return v

def parse_trades(raw: list[dict]) -> list[TradeRecord]:
    good, bad = [], []
    for i, item in enumerate(raw):
        try:   good.append(TradeRecord.model_validate(item))
        except ValidationError as e: bad.append(f"row {i}: {e.errors()[0]['msg']}")
    if bad:
        raise ValueError("Schema violation at ingestion boundary:\n" + "\n".join(bad))
    return good
# For tabular feeds: pandera DataFrameSchema gives column-level contracts on a DataFrame.
```

## 7. Idempotent landing — atomic tmp → rename keyed by (source, window)

A deterministic filename means re-running the same window overwrites the identical
file. Partial writes are never visible.

```python
import hashlib, json, pathlib

LANDING = pathlib.Path("/srv/lake/raw")

def land(source: str, cursor: str, records: list[dict]) -> pathlib.Path:
    key  = hashlib.sha256(f"{source}:{cursor}".encode()).hexdigest()[:16]
    path = LANDING / source / f"{key}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp  = path.with_suffix(".tmp")
    tmp.write_bytes(json.dumps(records).encode())
    tmp.rename(path)        # POSIX atomic; overwrites if exists
    return path
# Downstream dedup: MERGE ON trade_id WHEN MATCHED THEN DO NOTHING, or distinct().
```

## 8. `polite_get` — one helper every ingestion script reuses

Combines throttle → conditional headers → backoff → `Retry-After` in a single call.

```python
def polite_get(url: str, *, client: httpx.Client | None = None,
               params: dict | None = None, use_cache: bool = True,
               max_attempts: int = 5) -> httpx.Response | None:
    """Returns Response, or None on 304 Not Modified."""
    rps_bucket.consume()

    extra: dict = {}
    if use_cache:
        with shelve.open(CACHE_DB) as c:
            entry = c.get(url, {})
        if "etag"     in entry: extra["If-None-Match"]     = entry["etag"]
        if "last_mod" in entry: extra["If-Modified-Since"] = entry["last_mod"]

    own = client is None
    cl  = client or httpx.Client(timeout=30)
    try:
        for attempt in range(max_attempts):
            resp = cl.get(url, params=params, headers=extra)
            if resp.status_code == 304:
                return None
            if resp.status_code not in RETRYABLE:
                resp.raise_for_status()
                if use_cache:
                    with shelve.open(CACHE_DB) as c:
                        c[url] = {"etag": resp.headers.get("ETag", ""),
                                  "last_mod": resp.headers.get("Last-Modified", "")}
                return resp
            if attempt == max_attempts - 1:
                resp.raise_for_status()
            ra   = resp.headers.get("Retry-After")
            wait = float(ra) if ra else 0.5 * 2**attempt * (1 + 0.25 * random.random())
            time.sleep(wait)
    finally:
        if own: cl.close()
```

Typical ingestion script:

```python
token = [_secret("API_TOKEN")]
with httpx.Client(base_url="https://api.example.com") as client:
    for page in paginate(client, "trades_v2", "/v2/trades"):
        records = parse_trades(page)
        land("trades_v2", cursor=str(records[0].trade_id), records=page)
```
