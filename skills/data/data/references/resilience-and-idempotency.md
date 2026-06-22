# Resilience & idempotency — shared pipeline code

> Format-agnostic building blocks referenced by every data sub-skill. The lakehouse skill
> applies these to Iceberg commits (OCC on `CommitFailedException`); the API skill applies
> them to HTTP calls (429/5xx). The patterns are the same; only the retryable error differs.
> Code shown for Python 3.11+.

## Retry with exponential backoff + jitter

Retry only **transient** failures, and only **idempotent** operations. Cap attempts. Always add jitter — synchronized retries from many workers create a thundering herd that keeps the dependency down.

```python
import time, random
from typing import Callable, TypeVar

T = TypeVar("T")

def retry(fn: Callable[[], T], *, attempts: int = 5, base: float = 0.2,
          retry_on: tuple[type[Exception], ...] = (Exception,)) -> T:
    for i in range(attempts):
        try:
            return fn()
        except retry_on:
            if i == attempts - 1:
                raise
            time.sleep(base * 2**i * (1 + 0.25 * random.random()))  # exp backoff + 25% jitter
    raise AssertionError("unreachable")
```

Pick `retry_on` precisely per caller — e.g. `(CommitFailedException,)` for an Iceberg commit, or a
predicate on HTTP status `in {429, 500, 502, 503, 504}` for an API read. Retrying a non-idempotent
write (a plain POST that creates rows) duplicates data; make the write idempotent first (idempotency
key, upsert, or partition-overwrite) — see below.

## Circuit breaker

Fail fast on a dependency that is already down instead of hammering it through every retry loop on
the host. One breaker instance per external dependency (catalog, object store, each upstream API).

```python
import time

class CircuitBreaker:
    def __init__(self, threshold: int = 5, recovery_s: float = 60.0):
        self.threshold, self.recovery_s = threshold, recovery_s
        self.fails, self.opened_at = 0, None

    def call(self, fn, *a, **k):
        if self.opened_at is not None:
            if time.monotonic() - self.opened_at < self.recovery_s:
                raise RuntimeError("circuit OPEN")        # short-circuit; don't touch a dead dep
            self.opened_at = None                          # HALF-OPEN: allow one probe through
        try:
            out = fn(*a, **k)
            self.fails = 0                                 # success fully closes it
            return out
        except Exception:
            self.fails += 1
            if self.fails >= self.threshold:
                self.opened_at = time.monotonic()          # trip OPEN
            raise
```

Compose with `retry`: retry handles a blip; the breaker handles a sustained outage. Retry *inside*
the breaker call, so a string of exhausted retries counts toward tripping it.

## Dead-letter queue

A record you can't process goes somewhere durable with enough context to replay — never into a
swallowed `except`. In an unattended loop, a silent drop is data loss you find out about a week later.

```python
import json, pathlib, time

def dead_letter(record: dict, reason: str, *, dlq: str = "/srv/lake/.dead_letters") -> None:
    p = pathlib.Path(dlq)
    p.mkdir(parents=True, exist_ok=True)
    key = record.get("id") or f"{int(time.time()*1000)}"
    (p / f"{key}.json").write_text(json.dumps(
        {"record": record, "reason": reason, "ts": time.time()}, default=str))
```

Replay is then a directory scan that re-feeds each JSON through the normal path and deletes it on
success. Alert on DLQ depth — a growing queue is a real incident, an empty one is the happy path.

## Idempotency — the precondition for safe retries

Retries and crash-recovery are only safe because the operation is idempotent. The three durable forms:

- **Idempotency key** (writing through an API): send a stable `Idempotency-Key` derived from the
  payload; the server collapses duplicates. Required for any non-idempotent POST you intend to retry.
- **Upsert / merge on a key** (writing to a table): `MERGE`/`merge_insert` on a primary key — the
  second write of the same row is a no-op, not a duplicate.
- **Deterministic, content-addressed output** (writing files): name the file by `(source, window)`
  or a content hash, write to `tmp`, then atomically `rename`. Re-running the window overwrites the
  same path with identical bytes.

```python
import hashlib

def idempotency_key(*parts: str) -> str:
    return hashlib.sha256("|".join(parts).encode()).hexdigest()[:32]

# window-addressed filename: re-running [from,to) lands the exact same path
def window_path(source: str, frm: int, to: int) -> str:
    return f"raw/{source}/rows_{frm}_{to}.parquet"
```

**The rule that ties it together:** decide *what makes a unit re-runnable* before you write the retry
loop. If you can't state the idempotency mechanism for a step, you don't yet have the right to retry it.
