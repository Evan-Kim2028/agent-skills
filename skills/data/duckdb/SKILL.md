---
name: data-duckdb
description: Use when building or debugging pipelines that use DuckDB as the embedded analytical engine — tuning memory_limit and threads, handling larger-than-memory queries and disk spilling, reading Parquet/CSV efficiently (predicate & projection pushdown, glob/Hive partitioning, union_by_name), writing Parquet well (PER_THREAD_OUTPUT, ROW_GROUP_SIZE, the partitioned-write temp-blowup trap), connection reuse, and EXPLAIN ANALYZE profiling. Covers DuckDB-over-Parquet and DuckDB-as-query-layer on a single node. Don't use as an OLTP/transactional application database, for cluster-scale work that genuinely exceeds one big node, or for generic SQL tutoring. For querying Iceberg tables (`iceberg_scan`, catalog reads) see data-apache-lakehouse; for serving DuckDB results over HTTP see data-api. Prefer the data hub when the right data skill is unclear or the task spans ingest→store→serve.

---

# DuckDB — embedded analytical engine

DuckDB as the compute layer of a single-node data pipeline: vectorized, columnar, in-process, reading and writing Parquet directly with filter and projection pushdown. This skill is the engine discipline — memory, threads, spilling, file layout, and connection lifecycle. It is the format-agnostic complement to **data-apache-lakehouse** (Iceberg specifics) and **data-api** (serving), and inherits the cross-cutting principles from the **data** hub.

> **Verified:** 2026-06 against DuckDB 1.5.x. Numbers below (memory-per-thread, thread multipliers,
> ROW_GROUP_SIZE defaults) are guidance from the DuckDB performance docs and are version-sensitive —
> re-check on a major bump. v1.5.3 (May 2026) statically links jemalloc on Linux, which materially
> improves heavy out-of-core spilling; older builds spill more slowly. Code & config: [`references/duckdb-operations.md`](references/duckdb-operations.md).

## When to invoke this skill

- Choosing DuckDB (vs Polars/DataFusion/a warehouse) for a transform or serving query, and sizing it.
- A query OOMs, spills heavily, or runs far slower than the data volume warrants.
- Reading large Parquet datasets (single file, glob, or Hive-partitioned) and you want pruning to actually happen.
- Writing Parquet output and deciding file/row-group layout, or a partitioned write is blowing up disk.
- A long-lived service or pipeline opening DuckDB connections — deciding lifecycle and tuning.

## Principles

Load-bearing for any DuckDB workload. Each is paired with a falsifiable test — if you can't pass it, the principle is being violated.

### DuckDB is a single-node engine — confirm it fits before reaching for it

DuckDB rivals a cluster *when the data fits and the job is bounded*: the working set (the largest hash table, sort, or join state) fits in `memory_limit`, or spills to fast local disk. It is not a distributed warehouse, and it is not an OLTP store. The honest sizing question is about the **largest intermediate**, not the input size — a 500 GB scan that aggregates to 10 K groups is trivial; a 50 GB join that materializes a 200 GB hash table is not.

**Test:** name the largest blocking intermediate this query builds (join hash table / sort / group state) and whether it fits `memory_limit` or spills to NVMe. If the answer is "the whole input," or "I don't know," size it before running.

### Set `memory_limit` and `threads` explicitly; budget per thread

Defaults (`memory_limit` = 80% RAM, `threads` = cores) are a starting point, not a config. Budget **1–4 GB per thread** — ~1–2 GB/thread for aggregation-heavy, 3–4 GB/thread for join-heavy, never below ~125 MB/thread. So `threads` and `memory_limit` are chosen *together*: 8 threads of join work wants ~32 GB. **For remote/object-store reads, raise `threads` to 2–5× cores** — the bottleneck is synchronous HTTP latency, not CPU.

**Test:** is `memory_limit / threads` in the 1–4 GB band for this workload's shape? For S3/GCS reads, is `threads` above core count? If you're on bare defaults for a heavy job, you haven't tuned it.

### Push work into SQL; let pushdown prune

Filter, project, and aggregate *in the query* so DuckDB prunes row groups (predicate pushdown) and skips columns (projection pushdown) at the Parquet scan. Never `SELECT *` into a DataFrame and filter in Python — that reads everything and discards it. Parameterize values; never string-interpolate user input.

**Test:** run `EXPLAIN` — are the `WHERE` predicate and column list pushed into the scan, or is there a full scan with a late filter? If the bytes read ≈ table size for a selective query, pushdown isn't happening.

### Spilling is a safety net with holes — design within them

Larger-than-memory `GROUP BY` / `JOIN` / `ORDER BY` / windowed operators spill to `temp_directory` (put it on SSD/NVMe — HDD spilling is brutal). But the net has holes: `list()` and `string_agg()` **cannot** offload to disk, and a query with several blocking operators at once can still OOM even under the limit. Lower `memory_limit` *below* 80% to leave allocator headroom, and decompose a job that can't fit into bounded batches rather than hoping the spill saves you.

**Test:** does this query aggregate unbounded groups with `list()`/`string_agg()`, or stack multiple blocking operators? If yes, it can OOM despite spilling — batch it or restructure.

### Reuse one connection — it *is* the cache

A DuckDB connection holds metadata, the buffer cache, and loaded extensions. Open one per worker (or a small pool) and reuse it; reconnecting per query throws away cached state and re-pays setup. In a service, open it once at startup, not per request.

**Test:** does the process open a connection per request/query, or once and reuse it? Per-request connections mean you're discarding the cache every call.

### Parquet layout is a contract you write for the next reader

On write: `PER_THREAD_OUTPUT` (one file per thread) is the fast path when file count is flexible; size `ROW_GROUP_SIZE` so each file has **at least as many row groups as reader threads** (default 122,880 rows; min 2,048) — too few row groups starves intra-file parallelism, too many bloats metadata. **Watch the partitioned-write trap:** `PARTITION_BY` without bounded threading can make temp storage balloon until the disk fills; bound the threads or batch the write. On read: glob or Hive partitioning to span files, `union_by_name` to tolerate schema drift.

**Test:** does each output file have ≥ `threads` row groups? Is any `PARTITION_BY` write thread-bounded? If a partitioned write keeps growing temp files, that's the trap, not a slow disk.

### Choose persistence deliberately

A persistent `.duckdb` file has compression on by default (often ~8× smaller, and faster to scan than uncompressed in-memory). Pure `:memory:` has compression off unless you `ATTACH ':memory:' (COMPRESS)`. Don't default to in-memory for a working set that would benefit from compressed on-disk storage — and don't keep a persistent file you treat as disposable cache.

**Test:** is the choice between persistent and in-memory deliberate, given the working-set size and whether the data outlives the process? If it's `:memory:` by habit on a large set, reconsider.

## Anti-patterns

| Smell | What's wrong |
|---|---|
| `con.execute("SELECT * FROM read_parquet(...)").df()` then filter in pandas | No pushdown — reads the whole dataset to discard most of it |
| New `duckdb.connect()` per request/query | Throws away buffer cache + metadata; re-loads extensions every call |
| Bare defaults on a 100 GB join job | `memory_limit`/`threads` not budgeted per-thread → OOM or thrash |
| `temp_directory` on an HDD (or unset on a tiny `/tmp`) | Spilling crawls or fills the volume mid-query |
| `PARTITION_BY` write with unbounded threads | Temp storage doubles until the disk is exhausted (the partitioned-write trap) |
| `list()`/`string_agg()` over unbounded groups | Cannot spill — OOMs regardless of `memory_limit` |
| `threads` left at core count for S3/GCS reads | Under-parallelized; synchronous HTTP latency dominates |
| One giant Parquet file with one row group | No intra-file parallelism; one thread does all the work |
| Reading remote data repeatedly per query | Re-fetches over the network; cache to a local persistent table or Parquet |

## References

- **DuckDB operations** — connection setup & tuning pragmas, memory/thread config, larger-than-memory batching, Parquet read/write recipes, partitioned-write mitigation, `EXPLAIN ANALYZE` workflow: [`references/duckdb-operations.md`](references/duckdb-operations.md)
- Official performance guide: <https://duckdb.org/docs/current/guides/performance/overview>
- Tuning workloads: <https://duckdb.org/docs/current/guides/performance/how_to_tune_workloads>
- Parquet tips: <https://duckdb.org/docs/current/data/parquet/tips>
- Out-of-memory guide: <https://duckdb.org/docs/current/guides/performance/oom>
- Querying Iceberg from DuckDB → **data-apache-lakehouse**; serving DuckDB results over HTTP → **data-api**; shared pipeline principles → **data** hub.
