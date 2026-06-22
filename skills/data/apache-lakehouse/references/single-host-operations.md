# Single-host PyIceberg operations

> Patterns for running a PyIceberg lakehouse on **one host** — a single VPS, one writer
> process per table, a fixed RAM budget, and no Spark/Trino/Airflow cluster. The Iceberg
> format supports this fine; what follows is the discipline that keeps it bounded and
> crash-safe. Code is shown against PyIceberg 0.11.x — re-check signatures on upgrade
> (see [`pyiceberg-capabilities.md`](pyiceberg-capabilities.md)).

## Bounded-memory writes — one snapshot per batch

A `table.append(big_arrow_table)` needs the whole table resident. To bound peak RAM, stream a
`RecordBatchReader` and commit one batch per snapshot — peak RSS ≈ one batch regardless of total size.

```python
import pyarrow as pa
import pyarrow.dataset as ds

def append_streaming(table, source_path: str, batch_rows: int = 500_000):
    scanner = ds.dataset(source_path, format="parquet").scanner(batch_size=batch_rows)
    for batch in scanner.to_batches():               # one batch resident at a time
        table.append(pa.Table.from_batches([batch]))  # one snapshot per batch
```

Cost: more snapshots — compact and expire them on the maintenance pass. For Polars transforms,
prefer lazy `pl.scan_parquet(p)...sink_parquet(...)` over `read_parquet`, and extract a schema
without materializing data via `pl.scan_parquet(p).limit(0).collect().to_arrow().schema`.

## Adaptive batch sizing from the memory budget

A constant `max_files=50` OOMs on a busy day and wastes RAM on a quiet one. Read the real budget
(cgroup v2, or an env override) and scale the batch between a floor and a cap by current headroom.

```python
import os, resource

def memory_budget_bytes() -> int:
    env = os.getenv("LAKE_MEMORY_MAX_GB")
    if env:
        return int(float(env) * 2**30)
    try:
        return int(open("/sys/fs/cgroup/memory.max").read())   # may be "max" -> ValueError
    except (OSError, ValueError):
        return 8 * 2**30

def current_rss_bytes() -> int:
    try:
        return int(open("/sys/fs/cgroup/memory.current").read())
    except OSError:
        return resource.getrusage(resource.RUSAGE_SELF).ru_maxrss * 1024

def pick_batch_files(floor: int = 3, cap: int = 25) -> int:
    budget = memory_budget_bytes()
    frac = max(0.0, budget - current_rss_bytes()) / budget
    return max(floor, min(cap, int(floor + frac * (cap - floor))))
```

Defer the heavy gold rebuild when RSS is already near budget rather than letting the OOM killer
arbitrate.

## Subprocess isolation for heavy stages

A long-lived promote process accretes RSS across decode → curate → silver → gold and rarely returns
freed heap to the OS. Run heavy/leaky stages as a child process so the OS reclaims every byte at exit
— and get per-stage OOM enforcement without containers.

```python
import subprocess, sys

def run_isolated(stage: str, memory_max_gb: int | None = None):
    cmd = [sys.executable, "-m", "pipe.stages", stage]
    if memory_max_gb:                                   # hard cap, swap disabled
        cmd = ["systemd-run", "--user", "--scope", "--quiet",
               f"--property=MemoryMax={memory_max_gb}G",
               "--property=MemorySwapMax=0", *cmd]
    subprocess.run(cmd, check=True)                     # RSS fully reclaimed when child exits
```

## Table-property watermark (idempotent promote)

Store the last-consumed source position as a property on the **target** table; advance it with the
data. The clean form is one atomic commit (data + watermark together).

```python
import pyarrow.compute as pc

def read_watermark(table, key: str) -> int:
    return int(table.properties.get(f"wm.{key}", 0))

def promote(target, source, key: str, wm_col: str = "src_seq"):
    last = read_watermark(target, key)
    new = source.scan(row_filter=f"{wm_col} > {last}").to_arrow()
    if new.num_rows == 0:
        return
    new_wm = pc.max(new[wm_col]).as_py()
    with target.transaction() as tx:                 # ideal: data + watermark in ONE commit
        tx.append(new)                               #        -> they can never disagree
        tx.set_properties({f"wm.{key}": str(new_wm)})
```

A **two-commit** form (append, then a separate `set_properties`) is acceptable *only* when every
write is an idempotent upsert/partition-overwrite — then a crash between the two commits merely
re-processes the last window. If your writes aren't idempotent, use the single-transaction form.

## Single-host catalog: `SqlCatalog` + S3-compatible store (SeaweedFS / MinIO)

```python
from pyiceberg.catalog.sql import SqlCatalog

catalog = SqlCatalog(
    "lake",
    uri="sqlite:////srv/lake/catalog.db",         # pointer on local disk — no network per commit
    warehouse="s3://lake/warehouse",
    **{
        "s3.endpoint": "http://127.0.0.1:8333",    # SeaweedFS / MinIO endpoint
        "s3.access-key-id": "...",
        "s3.secret-access-key": "...",
        "s3.path-style-access": "true",            # REQUIRED for SeaweedFS / MinIO
        "s3.region": "us-east-1",
    },
)
```

`SqlCatalog` on SQLite is a legitimate **single-host, single-writer** production catalog: the commit
pointer is a local `.db` file, so there's no network round-trip per commit. It has **no cross-host
CAS** — run one writer process per table; readers are unlimited. For multi-writer or multi-host, move
to REST/Glue/Nessie/JDBC (a pointer move, not a data copy).

## systemd-timer maintenance (the single-host "external engine")

PyIceberg `expire_snapshots` is metadata-only; pair it with a DuckDB/Spark compaction + orphan-removal
step. Wire it as a user timer rather than Airflow/Dagster.

```ini
# ~/.config/systemd/user/lake-maintenance.service
[Service]
Type=oneshot
ExecStart=%h/.venv/bin/python -m pipe.maintenance   # expire_snapshots + compaction + orphan GC

# ~/.config/systemd/user/lake-maintenance.timer
[Timer]
OnCalendar=*-*-* 03:15:00
Persistent=true
[Install]
WantedBy=timers.target
```

Enable with `systemctl --user enable --now lake-maintenance.timer`. Keep the safe order:
`rewrite_data_files` → `expire_snapshots` (≥3-day window) → `remove_orphan_files` (≥3-day window) →
`rewrite_manifests`.

## OCC commit retry with jitter

Two writers racing the same table is normal; the loser retries against the new snapshot. This is the
exactly-once primitive — implement it.

```python
import time, random
from pyiceberg.exceptions import CommitFailedException

def commit_with_retry(fn, attempts: int = 5, base: float = 0.2):
    for i in range(attempts):
        try:
            return fn()
        except CommitFailedException:
            if i == attempts - 1:
                raise
            time.sleep(base * 2**i * (1 + 0.25 * random.random()))   # exp backoff + 25% jitter
```

## Circuit breaker + dead-letter queue

Fail fast on a dead dependency instead of hanging every retry loop; park un-processable records for
replay instead of swallowing them.

```python
import json, time, pathlib

class CircuitBreaker:
    def __init__(self, threshold=5, recovery_s=60):
        self.threshold, self.recovery_s = threshold, recovery_s
        self.fails, self.opened_at = 0, None

    def call(self, fn, *a, **k):
        if self.opened_at and time.monotonic() - self.opened_at < self.recovery_s:
            raise RuntimeError("circuit OPEN")          # short-circuit; don't hammer a dead dep
        try:
            out = fn(*a, **k)
            self.fails, self.opened_at = 0, None         # success closes it
            return out
        except Exception:
            self.fails += 1
            if self.fails >= self.threshold:
                self.opened_at = time.monotonic()
            raise

def dead_letter(record: dict, reason: str, dlq="/srv/lake/.dead_letters"):
    p = pathlib.Path(dlq); p.mkdir(parents=True, exist_ok=True)
    (p / f"{record.get('id','rec')}.json").write_text(
        json.dumps({"record": record, "reason": reason}))
```

## Schema-guard layers

Fence schema at every layer boundary so a malformed write fails at the boundary with a clear message,
not three stages later as a cryptic Arrow cast error.

```python
import os

STRICT = os.getenv("QUALITY_STRICT") == "1"

def validate(df, required: set[str], max_null_frac: dict[str, float] | None = None):
    missing = required - set(df.columns)
    problems = [f"missing columns: {sorted(missing)}"] if missing else []
    for col, frac in (max_null_frac or {}).items():
        if col in df.columns and df[col].null_count() / max(1, len(df)) > frac:
            problems.append(f"{col} exceeds null fraction {frac}")
    if problems:
        msg = "; ".join(problems)
        if STRICT:
            raise ValueError(msg)       # production: hard fail
        print(f"[quality] WARN: {msg}")  # dev: warn and continue
```

Apply as `validate_bronze` / `validate_silver` / `validate_gold` with the column contracts each layer
owes its readers.
