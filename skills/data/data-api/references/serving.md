# Serving gold data over HTTP

> Patterns for exposing **analytical/gold-layer data** via FastAPI + DuckDB — push-down filtering,
> keyset pagination, cache invalidation tied to publish tokens, and a factory router that generates
> endpoints from a spec dict. Shown against **FastAPI 0.11x, DuckDB 1.x, pydantic v2**. For
> *consuming* external APIs (HTTP clients, ingestion) see `client-ingestion.md`. For generic REST
> API design (auth, versioning, error shapes) see the `api-and-interface-design` skill — this file
> is specifically about serving analytical data fast; it is not a general REST tutorial.

## Connection management — one DuckDB per worker

Open one connection at startup via `lifespan`. Never open per-request. Set a memory cap.

```python
import duckdb
from contextlib import asynccontextmanager
from fastapi import FastAPI

_conn: duckdb.DuckDBPyConnection | None = None
def get_conn() -> duckdb.DuckDBPyConnection: return _conn

@asynccontextmanager
async def lifespan(app: FastAPI):
    global _conn
    _conn = duckdb.connect(":memory:")
    _conn.execute("SET memory_limit='2GB'")
    _conn.execute("SET threads=4")
    _conn.execute("INSTALL iceberg; LOAD iceberg")
    yield
    _conn.close()
```

In a multi-worker uvicorn/Gunicorn setup each process gets its own connection — correct, DuckDB
in-process is not shared across OS processes. Reference gold data via `iceberg_scan(path)` or
`read_parquet(glob)` inside queries; don't import full tables into DuckDB memory.

## Push filters to the engine — never SELECT *, filter in Python

Every filter the engine prunes is data never read. Build the full WHERE/LIMIT into DuckDB SQL.
Use `$name` parameter binding for all user-supplied values — never string-interpolate them.

```python
# Bad: full table scan, then Python filter
df = conn.execute("SELECT * FROM gold_orders").df()
result = df[df["region"] == region]  # OOM on large tables

# Good: push down via parameterized query
def fetch_orders(
    conn: duckdb.DuckDBPyConnection,
    region: str,
    status: str | None,
    limit: int,
) -> list[dict]:
    clauses = ["region = $region"]
    params: dict = {"region": region, "limit": limit}
    if status is not None:
        clauses.append("status = $status")
        params["status"] = status
    where = " AND ".join(clauses)
    sql = (
        f"SELECT order_id, region, status, amount, created_at "
        f"FROM gold_orders WHERE {where} ORDER BY created_at DESC LIMIT $limit"
    )
    return conn.execute(sql, params).fetchdf().to_dict("records")
```

Column names in the f-string are only safe when sourced from a static allowlist (see **Response
contracts** below). User-supplied *values* always go through `$param` binding.

## Keyset (cursor) pagination — not OFFSET

`OFFSET N` forces DuckDB to scan and discard N rows every page — O(N). Keyset is O(page):
`WHERE key > :last ORDER BY key LIMIT :n`.

```python
from pydantic import BaseModel
from typing import Any, Generic, TypeVar
import base64, json

T = TypeVar("T")

class Page(BaseModel, Generic[T]):
    items: list[T]
    next_cursor: str | None   # None = last page

def encode_cursor(val: Any) -> str:
    return base64.urlsafe_b64encode(json.dumps(val).encode()).decode()

def decode_cursor(tok: str) -> Any:
    return json.loads(base64.urlsafe_b64decode(tok))

def paginate(conn, table_expr: str, key_col: str, sel: str,
             after: str | None, page_size: int = 50) -> Page:
    params: dict = {"n": page_size + 1}
    if after:
        params["last"] = decode_cursor(after)
        sql = f"SELECT {sel} FROM {table_expr} WHERE {key_col} > $last ORDER BY {key_col} LIMIT $n"
    else:
        sql = f"SELECT {sel} FROM {table_expr} ORDER BY {key_col} LIMIT $n"
    rows = conn.execute(sql, params).fetchdf().to_dict("records")
    items = rows[:page_size]
    return Page(items=items, next_cursor=encode_cursor(items[-1][key_col]) if len(rows) > page_size else None)
```

The sort key must be stable and indexed (Iceberg hidden partitioning or a sorted Parquet write).
Never mix OFFSET and keyset on the same endpoint.

## Caching + publish-token invalidation

Cache results keyed on the current publish token (Iceberg snapshot id, a `.publish_token` file, or
a Redis key flipped by the writer on each gold rebuild). Readers never serve stale gold; cache never
grows forever.

```python
import hashlib, time
from pathlib import Path
from typing import Any

_store: dict[str, tuple[float, Any]] = {}
_TTL = 300.0

def publish_token(warehouse: str) -> str:
    tok = Path(warehouse) / ".publish_token"
    return tok.read_text().strip() if tok.exists() else "static"

def cached_query(conn, warehouse: str, sql: str, params: dict) -> list[dict]:
    token = publish_token(warehouse)
    fp = hashlib.sha256(f"{token}:{sql}:{sorted(params.items())}".encode()).hexdigest()
    entry = _store.get(fp)
    if entry and entry[0] > time.monotonic():
        return entry[1]
    result = conn.execute(sql, params).fetchdf().to_dict("records")
    _store[fp] = (time.monotonic() + _TTL, result)
    return result
```

In production replace `_store` with Redis so token-flip invalidation broadcasts across all workers.

**The `_store` dict above is unbounded — don't ship it as-is.** A module-level `dict` keyed by
`(id, window)` with TTL checked only on read never evicts on its own; measured failure: exactly this
shape (checked-on-read-only TTL, no size bound) grew monotonically to OOM under real traffic. See
**Bounded, thread-safe caches** below before this pattern reaches production.

## Honor persisted quality attributes

When the fact table carries write-time quality attributes (flags, reason lists, confidence), default
serving paths **filter or label from those columns**. Do not re-score cohorts in the request handler
as the long-term design — that recreates split-brain with the lake. Rule definition lives in
**data-semantic-quality**; serving only implements the consumption contract.

```python
# Good: trust stored attribute
sql = """
  SELECT sale_id, entity_id, amount, sold_at
  FROM gold_facts
  WHERE entity_id = $id
    AND coalesce(quality_exclude, false) = false
  ORDER BY sold_at DESC
  LIMIT $limit
"""

# Bad long-term: re-derive "junk" only in the API while the table stays unflagged
```

Document which endpoints honor which attributes in OpenAPI or route docs. Deploy smoke: known-bad
pack members must not appear on default product paths.

## Publish-coupled serving sidecars

A sidecar (sorted Parquet, per-entity cursor file, pre-aggregate) is a **derived projection** for
latency — not a second system of record.

Constraints:

1. Rebuild after successful source publish; pass the source snapshot id / version-hint into the builder.
2. API cache keys include that source version (same as publish-token discipline above).
3. Sidecar schema is contractual; missing columns fail smoke.
4. Apply quality-attribute filters when **building** from source when possible.
5. Never treat the sidecar as authoritative if it disagrees with a fresh source read for correctness audits.

```text
publish gold facts (version V)
    → rebuild sidecar(s) bound to V
    → flip publish_token / version-hint to V
    → API caches miss and rebuild under V
```

If publish succeeds but sidecar rebuild fails, either fail the unit or serve degraded with an
explicit stale signal — do not silently pin users to V-1 under a V token.

## Bounded, thread-safe caches — don't let a serving cache grow to OOM

A production cache needs three properties the `_store` dict above has none of: a **bounded type**
whose constructor requires a max size (misuse-resistant — you cannot construct an unbounded one),
**thread safety** under concurrent request handlers, and — if a per-key lock registry sits alongside
the cache (e.g. to serialize recomputation per key) — that registry must be bounded too, or it's the
same unbounded-growth leak one level down.

```python
import threading
from cachetools import TTLCache   # any maxsize+ttl cache works; the point is the type, not the library

class BoundedCache:
    def __init__(self, maxsize: int, ttl_s: float):
        if maxsize <= 0:
            raise ValueError("maxsize must be > 0 — a BoundedCache cannot be unbounded")
        self._c = TTLCache(maxsize=maxsize, ttl=ttl_s)
        self._lock = threading.Lock()

    def get_or_set(self, key, compute):
        with self._lock:
            if key in self._c:
                return self._c[key]
        value = compute()
        with self._lock:
            self._c[key] = value
        return value

_query_cache = BoundedCache(maxsize=10_000, ttl_s=300.0)   # ctor forces a size — can't skip it
```

**Test:** try to construct the cache with no size argument — does it raise, or silently default to
unbounded? If it defaults, someone eventually will, and the process OOMs weeks later under real
traffic, not in testing.

## Executor lifecycle — don't drop wait-on-exception

`with ThreadPoolExecutor() as pool: ...` waits for every submitted future on exit, *including* when
the `with` block raises — that implicit wait is part of the context manager's contract. Replacing it
with a shared, module-level executor (to avoid spinning up threads per request) silently drops that
guarantee: on an exception, the handler returns or re-raises immediately while its submitted futures
are still running against resources (a DB cursor, a file handle) that the caller's own cleanup just
closed.

```python
from concurrent.futures import ThreadPoolExecutor, wait

# Bad: shared executor, no wait — futures can outlive the resources they're using
_executor = ThreadPoolExecutor(max_workers=8)

def handle(conn, queries):
    futures = [_executor.submit(query, conn, q) for q in queries]
    return [f.result() for f in futures]   # if one raises, the rest keep running against `conn`

# Good: still shared (avoid per-request thread spin-up), but wait for all futures in `finally`
def handle_safe(conn, queries):
    futures = [_executor.submit(query, conn, q) for q in queries]
    try:
        return [f.result() for f in futures]
    finally:
        wait(futures)   # every future is done before `conn` (or anything else) is released
```

**Test:** raise inside one submitted task while others are still running. Does the caller's cleanup
(closing `conn`, releasing a lock) happen before or after every future finishes? If before, a future
can touch a resource that's already been closed underneath it.

## Factory router for many similar gold tables

One spec dict generates list / by-key / top-N / summary endpoints. A new gold table is a ~10-line
registration. `safe_columns` runs a `DESCRIBE` at startup so the same router tolerates tables with
slightly different column sets.

```python
from fastapi import APIRouter, HTTPException, Query, Depends

def safe_columns(conn, table_expr: str) -> set[str]:
    rows = conn.execute(f"DESCRIBE SELECT * FROM {table_expr} LIMIT 0").fetchall()
    return {r[0] for r in rows}

def gold_router(
    prefix: str, table_expr: str, key_col: str,
    response_cols: list[str], top_n_col: str | None = None,
) -> APIRouter:
    router = APIRouter(prefix=prefix)
    sel = ", ".join(response_cols)

    @router.get("/")
    def list_items(after: str | None = Query(None), limit: int = Query(50, le=500),
                   conn=Depends(get_conn)):
        return paginate(conn, table_expr, key_col, sel, after, limit)

    @router.get("/{key}")
    def by_key(key: str, conn=Depends(get_conn)):
        rows = conn.execute(
            f"SELECT {sel} FROM {table_expr} WHERE {key_col} = $k LIMIT 1", {"k": key}
        ).fetchdf().to_dict("records")
        if not rows:
            raise HTTPException(404, "not found")
        return rows[0]

    if top_n_col:
        @router.get("/top")
        def top_n(n: int = Query(10, le=100), order: str = Query("desc"), conn=Depends(get_conn)):
            if order not in {"asc", "desc"}:
                raise HTTPException(400, "order must be asc or desc")
            return conn.execute(
                f"SELECT {sel} FROM {table_expr} ORDER BY {top_n_col} {order} LIMIT $n", {"n": n}
            ).fetchdf().to_dict("records")

    @router.get("/summary")
    def summary(conn=Depends(get_conn)):
        return conn.execute(
            f"SELECT count(*) AS row_count, min({key_col}) AS first_key, max({key_col}) AS last_key FROM {table_expr}"
        ).fetchdf().to_dict("records")[0]

    return router

# Registration — one block per gold table
GOLD_TABLES = [
    dict(prefix="/orders",
         table_expr="iceberg_scan('s3://warehouse/gold/orders', allow_moved_paths=true)",
         key_col="order_id",
         response_cols=["order_id", "region", "status", "amount", "created_at"],
         top_n_col="amount"),
    dict(prefix="/products",
         table_expr="read_parquet('s3://warehouse/gold/products/*.parquet')",
         key_col="product_id",
         response_cols=["product_id", "name", "category", "price"],
         top_n_col="price"),
]
```

## Response contracts — pydantic models + allowlists

Declare explicit response models; FastAPI emits OpenAPI automatically. Whitelist sort fields at
request time — never embed user-supplied column names in SQL without checking them first.

```python
from pydantic import BaseModel
from datetime import datetime
from fastapi import HTTPException, Query

class OrderRow(BaseModel):
    order_id: str; region: str; status: str; amount: float; created_at: datetime

ALLOWED_SORT = {"created_at", "amount", "order_id"}

def validate_sort(col: str) -> str:
    if col not in ALLOWED_SORT:
        raise HTTPException(400, f"sort_by must be one of {sorted(ALLOWED_SORT)}")
    return col

@app.get("/orders", response_model=Page[OrderRow])
def list_orders(
    sort_by: str = Query("created_at", description="created_at | amount | order_id"),
    order: str = Query("desc", description="asc | desc"),
    conn=Depends(get_conn),
):
    sort_by = validate_sort(sort_by)
    if order not in {"asc", "desc"}:
        raise HTTPException(400, "order must be asc or desc")
    sql = f"SELECT order_id, region, status, amount, created_at FROM gold_orders ORDER BY {sort_by} {order} LIMIT 50"
    return Page(items=conn.execute(sql).fetchdf().to_dict("records"), next_cursor=None)
```

Rule: user *values* → `$param` binding; user *column names* → allowlist check before embedding in
SQL. Document the allowlist in `Query(description=...)` so it appears in the OpenAPI UI.
