# DuckDB operations

> Concrete config and code for DuckDB as a pipeline engine. Shown against **DuckDB 1.5.x** (Python
> client `duckdb` 1.5.x) — re-check pragma names and defaults on a major bump. Numbers are from the
> DuckDB performance docs; treat them as starting points and confirm with `EXPLAIN ANALYZE` on your
> data and hardware.

## Connection setup & core pragmas

Open once, reuse. Tune memory and threads together, and put spill on fast disk.

```python
import duckdb, os

def open_engine(db_path: str = ":memory:") -> duckdb.DuckDBPyConnection:
    con = duckdb.connect(db_path)
    con.execute("SET memory_limit = '24GB'")        # < 80% RAM leaves allocator headroom
    con.execute("SET threads = 8")                   # ~1-4 GB/thread: 8 threads ↔ 24GB
    con.execute("SET temp_directory = '/mnt/nvme/duckdb.tmp'")  # spill target — NVMe/SSD only
    con.execute("SET preserve_insertion_order = false")          # cuts memory on big import/export
    return con
```

- `memory_limit` defaults to ~80% RAM. Budget **1–2 GB/thread** for aggregation-heavy, **3–4 GB/thread**
  for join-heavy work, never under ~125 MB/thread. Lower the limit below 80% if you hit OOM — spilling
  needs headroom the limit doesn't account for.
- `threads` defaults to core count. Drop it if HyperThreading hurts a CPU-bound job; **raise it to 2–5×
  cores for remote (S3/GCS/HTTP) reads** — synchronous IO latency, not CPU, is the bottleneck there.
- `temp_directory` is where blocking operators spill. HDD spilling is brutally slow; use NVMe/SSD and
  make sure the volume has room.

## Reading Parquet — make pruning happen

```python
# Predicate + projection pushdown: only the needed columns and matching row groups are read.
con.execute("""
    SELECT region, sum(amount) AS total
    FROM read_parquet('s3://bucket/gold/orders/**/*.parquet', hive_partitioning = true)
    WHERE dt >= $start AND region = $region
    GROUP BY region
""", {"start": "2026-01-01", "region": "us"})

# Schema drift across files: fill missing columns with NULL instead of erroring.
con.execute("SELECT * FROM read_parquet('raw/*.parquet', union_by_name = true)")
```

- A glob (`**/*.parquet`) or `hive_partitioning = true` spans many files transparently; partition
  columns in the path become queryable columns and prune whole directories.
- Verify pushdown actually happens — see the `EXPLAIN ANALYZE` section. If the scan reads ≈ the full
  dataset for a selective query, the predicate isn't being pushed.

## Writing Parquet — file & row-group layout

```python
# Fast multi-file write: one file per thread. Use when exact file names/count don't matter.
con.execute("""
    COPY (SELECT * FROM big_result)
    TO 'out/orders' (FORMAT parquet, PER_THREAD_OUTPUT true, COMPRESSION zstd)
""")

# Control row-group size so each file has >= `threads` row groups (intra-file parallelism).
con.execute("""
    COPY (SELECT * FROM big_result)
    TO 'out/orders.parquet' (FORMAT parquet, ROW_GROUP_SIZE 122880, COMPRESSION zstd)
""")
```

- `ROW_GROUP_SIZE` default 122,880 rows, minimum 2,048 (the vector size). Aim for **≥ reader-thread-count
  row groups per file**: too few starves parallelism, too many bloats metadata. Larger groups compress
  better but hold more in memory before flushing.
- `ROW_GROUPS_PER_FILE` rolls to a new file after N row groups when you want bounded file sizes.

## The partitioned-write trap

`PARTITION_BY` with unbounded threads can make temp storage **double until the disk is exhausted** —
each thread buffers every open partition. Mitigate by bounding threads for the write, or by batching.

```python
# Risk: many partitions × many threads = exploding temp files.
# Mitigation 1 — bound threads just for the partitioned write, then restore:
con.execute("SET threads = 2")
con.execute("""
    COPY (SELECT * FROM events)
    TO 'out/events' (FORMAT parquet, PARTITION_BY (dt), OVERWRITE_OR_IGNORE true)
""")
con.execute("SET threads = 8")

# Mitigation 2 — write one partition at a time in a bounded loop (predictable temp usage):
for dt in partition_values:
    con.execute(
        "COPY (SELECT * FROM events WHERE dt = $dt) TO $path (FORMAT parquet)",
        {"dt": dt, "path": f"out/events/dt={dt}/data.parquet"},
    )
```

## Larger-than-memory: batch when spilling won't save you

Spilling covers `GROUP BY`/`JOIN`/`ORDER BY`/window, but **`list()` and `string_agg()` cannot spill**,
and stacked blocking operators can still OOM. When a job can't fit, decompose into bounded batches and
combine — this keeps peak memory tied to batch size (hub principle 6).

```python
# Process by partition/window instead of one all-in-one query that materializes everything.
def aggregate_in_batches(con, dates: list[str]):
    con.execute("CREATE OR REPLACE TABLE acc (dt DATE, region TEXT, total DOUBLE)")
    for dt in dates:
        con.execute("""
            INSERT INTO acc
            SELECT $dt::DATE, region, sum(amount)
            FROM read_parquet($path) GROUP BY region
        """, {"dt": dt, "path": f"raw/dt={dt}/*.parquet"})
    return con.table("acc")
```

## Profiling — EXPLAIN ANALYZE workflow

```python
# Plan only, no execution — confirm filter/projection pushdown into the scan:
print(con.execute("EXPLAIN SELECT region, sum(amount) FROM read_parquet('g/*.parquet') "
                  "WHERE dt > '2026-01-01' GROUP BY region").fetchall()[0][1])

# Run + profile — per-operator CPU time; spot nested-loop joins, missing pushdown, spills:
print(con.execute("EXPLAIN ANALYZE SELECT ...").fetchall()[0][1])
```

What to look for: predicate and projection landed on the `PARQUET_SCAN` (not a late `FILTER` over a
full read); no surprise `NESTED_LOOP_JOIN` where a hash join was expected; operators not spilling
unexpectedly. Tune, re-run, compare — don't guess.

## Persistence vs in-memory

```python
# Persistent: compression ON by default — smaller on disk, often faster to scan than raw in-memory.
con = duckdb.connect("/srv/lake/analytics.duckdb")

# In-memory with compression explicitly enabled (off by default for :memory:):
con = duckdb.connect(":memory:")
con.execute("ATTACH ':memory:' AS c (COMPRESS)")
```

Use persistent when the working set benefits from compressed on-disk storage or outlives the process;
use `:memory:` for genuinely transient compute. Don't default to `:memory:` by habit on a large set.

## Serving & lakehouse cross-references

- Serving DuckDB query results over HTTP (one connection per worker, pushdown, keyset pagination,
  publish-token cache): see **data-api** → `references/serving.md`.
- Querying Iceberg tables (`iceberg_scan`, catalog reads, snapshot-pinned scans): see
  **apache-lakehouse**. The tuning here (memory/threads/spilling) applies to those scans too.
