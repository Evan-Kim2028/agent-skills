---
name: data
description: Hub for data-engineering pipeline work — picking a storage/ingestion/serving approach and applying the cross-cutting discipline (idempotency, incremental-not-full-recompute, schema fencing, resilience, bounded memory) that every data sub-skill shares. Routes to specialists — apache-lakehouse (Apache Iceberg lakehouses) and data-api (consuming external APIs and serving data over HTTP). Use when a task spans ingest → store → serve, when the right specialist isn't obvious yet, or when you need the shared pipeline principles. Don't use for OLTP / relational schema design, one-off pandas or notebook analysis, generic SQL query tuning, ML model training, or BI-tool config — and when a specialist clearly fits (Iceberg → apache-lakehouse, API client/serving → data-api), skip the hub and go straight there.
---

# Data engineering — routing hub

The shared entry point for building and operating data pipelines. Its job is two things the individual skill descriptions can't do: **route** you to the right specialist, and state the **cross-cutting principles** every specialist assumes. When you already know the specialist, load it directly — this hub is for the choices you make *before* that, and for the discipline that spans all of them.

## Routing — which skill

| Your task | Skill |
|---|---|
| Designing/operating an **Apache Iceberg** lakehouse (bronze/silver/gold, PyIceberg, catalog choice, compaction/expire, WAP, snapshot rollback, single-host bounded-RAM writes) | **apache-lakehouse** |
| **Consuming** an external HTTP API for ingestion (rate limits, backoff, pagination, auth, response validation) **or serving** gold/analytical data over HTTP (FastAPI + DuckDB, pushdown, keyset pagination, cache invalidation) | **data-api** |
| Using **DuckDB** as the compute engine — tuning memory/threads, larger-than-memory spilling, Parquet read/write layout, connection lifecycle, EXPLAIN profiling | **duckdb** |
| Choosing *between* storage formats (Iceberg vs Delta vs plain Parquet vs embedded DuckDB), or the task spans ingest → store → serve | start here, then hand off |
| Generic interface/contract design unrelated to data movement | `api-and-interface-design` (not a data skill) |
| Wrapping an API as a live tool Claude calls at runtime | build an **MCP server**, not a skill |

If no specialist fits the storage layer yet, apply the principles below directly — they are format-agnostic.

## Cross-cutting principles (shared by every data sub-skill)

Load-bearing in *any* pipeline, whatever the storage engine. Each is paired with a falsifiable test — if you can't pass the test, the principle is being violated, not "applied differently." Specialists restate the engine-specific form; the canonical version lives here.

### 1. Every write is idempotent

Re-running the same step — same input window, same batch — produces identical state, never duplicates. This is what makes crashes, retries, and backfills safe. Achieve it with deterministic keys (upsert/merge on a primary key, partition-overwrite of a window, or content-addressed filenames), never by hoping a step runs exactly once.

**Test:** run the step twice on the same window. Is the output byte-identical? If row counts grow, it isn't idempotent.

### 2. Move forward by a watermark, not a full recompute

Every step persists how far it has consumed — a max timestamp, a sequence number, a pagination cursor, a snapshot id — and resumes from there. "Rebuild from history" exists only behind an explicit `--rebuild` flag. A step with no watermark gets slower in proportion to data growth, silently.

**Test:** if the upstream grew 10× tomorrow, would this step's runtime grow 10×? If yes, it lacks a watermark.

### 3. Fence schema at every boundary

Validate columns, types, and null fractions at each layer/stage edge, and fail *loud at the boundary*. A malformed upstream payload should error at ingestion with a clear message — not surface as a cryptic cast error three stages downstream. Keep a strict mode that turns warnings into hard failures in production.

**Test:** if an upstream adds a column or flips a type, which stage fails, and is its error message actionable? If the failure is far from the cause, the fence is missing.

### 4. Publish atomically; readers never see a partial write

A reader sees either the old state or the new one, never half. Use `tmp → rename` for files and a transactional commit for catalogued tables. Never mutate a live output in place while readers are pointed at it.

**Test:** kill the writer mid-publish. Can a reader observe a torn/partial result? If yes, the publish isn't atomic.

### 5. Resilience is implemented, not hoped for

Retry transient failures with exponential backoff + jitter; trip a **circuit breaker** per external dependency so one outage degrades one lane instead of hanging every loop; route un-processable records to a **dead-letter queue** with enough context to replay. A swallowed exception in an unattended loop is data loss you discover a week later. Code: [`references/resilience-and-idempotency.md`](references/resilience-and-idempotency.md).

**Test:** when an upstream dependency is down for an hour, does exactly one lane degrade and recover automatically, or does the whole host wedge? Where do failed records end up?

### 6. Peak memory is bounded by the batch, not the dataset

Tie peak RAM to batch/page/window size, not total volume — stream record batches, lazy-scan, paginate. A step whose memory scales with the table will eventually OOM on a busy day.

**Test:** does this step's peak RSS depend on total row count, or on batch size? If it scales with the data, it isn't streaming.

### 7. Freshness is observable

Every run records what it consumed and produced — a watermark, a row count, a run-log line. An unattended pipeline you can't interrogate ("when did this last update, and with how many rows?") is one you can't trust.

**Test:** without reading code, can you answer "when did table X last update and how many rows landed?" from a log or a property? If not, add the signal.

## References

- **Shared resilience & idempotency code** (retry + jitter, circuit breaker, dead-letter queue, idempotency keys): [`references/resilience-and-idempotency.md`](references/resilience-and-idempotency.md)
- Specialist: **apache-lakehouse** — the Iceberg-specific expression of these principles (OCC retry, snapshot watermarks, WAP branches, compaction).
- Specialist: **data-api** — the API-specific expression (rate-limit buckets, pagination-cursor watermarks, response schema fencing; serving with pushdown + keyset pagination + cache invalidation).
- Specialist: **duckdb** — the embedded-engine expression (memory/thread budgeting, larger-than-memory spilling and its limits, Parquet read/write layout, connection-as-cache).
