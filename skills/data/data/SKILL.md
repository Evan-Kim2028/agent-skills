---
name: data
description: Hub for data-engineering pipeline work — picking a storage/ingestion/serving approach and applying the cross-cutting discipline (idempotency, incremental-not-full-recompute, schema fencing, resilience, bounded memory, layered enforcement) that every data sub-skill shares. Routes to specialists — data-apache-lakehouse (Apache Iceberg lakehouses), data-api (consuming external APIs and serving data over HTTP), data-duckdb (DuckDB as the single-node analytical engine — memory/threads, spilling, Parquet read/write), data-pipeline-operations (running multiple pipelines on shared host infrastructure — admission control, capacity budgets), and data-table-lifecycle (whether a table should still exist, and how to retire it safely). Use when a task spans ingest → store → serve, when the right specialist isn't obvious yet, or when you need the shared pipeline principles. Don't use for OLTP / relational schema design, one-off pandas or notebook analysis, generic SQL tutoring, ML model training, or BI-tool config — and when a specialist clearly fits (Iceberg → data-apache-lakehouse, API client/serving → data-api, DuckDB engine tuning → data-duckdb, multi-pipeline capacity → data-pipeline-operations, table retirement → data-table-lifecycle), skip the hub and go straight there.
---

# Data engineering — routing hub

The shared entry point for building and operating data pipelines. Its job is two things the individual skill descriptions can't do: **route** you to the right specialist, and state the **cross-cutting principles** every specialist assumes. When you already know the specialist, load it directly — this hub is for the choices you make *before* that, and for the discipline that spans all of them.

## Routing — which skill

| Your task | Skill |
|---|---|
| Designing/operating an **Apache Iceberg** lakehouse (bronze/silver/gold, PyIceberg, catalog choice, compaction/expire, WAP, snapshot rollback, single-host bounded-RAM writes) | **data-apache-lakehouse** |
| **Consuming** an external HTTP API for ingestion (rate limits, backoff, pagination, auth, response validation) **or serving** gold/analytical data over HTTP (FastAPI + DuckDB, pushdown, keyset pagination, cache invalidation) | **data-api** |
| Using **DuckDB** as the compute engine — tuning memory/threads, larger-than-memory spilling, Parquet read/write layout, connection lifecycle, EXPLAIN profiling | **data-duckdb** |
| Running **multiple pipelines** on shared single-host infrastructure — memory admission control, concurrency caps, capacity ratchets, OOM kills that only appear when individually-fine pipelines coexist | **data-pipeline-operations** |
| Deciding whether a **table/artifact should still exist** — consumer audits, safe drops, maintenance coverage | **data-table-lifecycle** |
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

Watch for **O(history) leaks disguised as incremental** — a watermark exists somewhere in the code, but a specific operation still scales with total history instead of the delta:

- A per-batch **full-history re-walk** (re-reading an entire JSONL/log from the start every run instead of from the watermark — measured: thousands of redundant walks per run).
- A **full-column preflight scan** before the real query (scanning millions of rows to check a condition a pushdown predicate would answer for free — measured: 2.48M rows scanned hourly where a predicate made it near-free).
- An **unbounded anti-join key collect** (materializing every key ever seen instead of scoping to the chunk's own date range when the key embeds a date).

A full-rebuild trigger (schema change, resolver bump, backfill) belongs on its **own lane**, separate
from the regular incremental run, with checkpoints that survive a retry. A rebuild whose retry logic
wipes its own staging checkpoints resets to record one on every crash and, on a large enough history,
never finishes — measured: 9 attempts over 19 hours, 0 successes, each retry restarting a 602-day
rebuild from day 1.

**Test:** if the upstream grew 10× tomorrow, would this step's runtime grow 10×? If yes, it lacks a watermark. Separately: does a crash mid-rebuild resume from a checkpoint, or restart from record one? If it restarts, the rebuild lane isn't resumable and won't survive its own retries on real data volume.

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

### 8. Enforcement is layered: runtime guard > CI gate > checklist > review convention

A principle enforced by only a checklist or a comment is a suggestion, not enforcement. Real
enforcement stacks from strongest to weakest, and the top layer is the one that actually blocks a
violation: a **runtime guard** that refuses to proceed (a constructor that raises without a required
argument, an admission gate that refuses units without a memory cap); a **CI gate** that structurally
parses the change (a unit-file parser checking caps are present and heavy units are routed through
admission, a timer-overlap lint, a live-vs-repo drift audit — not a keyword grep); a **checklist
artifact** reviewed per pipeline (a row per pipeline × falsifiable test × last-verified date); and a
**review convention** (a PR template row) as the last, weakest backstop. Use as many layers as the
risk warrants — structure beats memory, and memory is the only thing a checklist or convention relies
on.

A checker that greps source for a comment or a string literal **false-passes**: it confirms the words
exist, not that the code does what they claim. Enforcement has to parse structure — AST, unit-file
fields, config schema — not text.

**Test:** delete the checklist — does anything still block a violation? If no, you have documentation,
not enforcement, and the runtime guard or CI gate layer is missing.

## References

- **Shared resilience & idempotency code** (retry + jitter, circuit breaker, dead-letter queue, idempotency keys): [`references/resilience-and-idempotency.md`](references/resilience-and-idempotency.md)
- Specialist: **data-apache-lakehouse** — the Iceberg-specific expression of these principles (OCC retry, snapshot watermarks, WAP branches, compaction).
- Specialist: **data-api** — the API-specific expression (rate-limit buckets, pagination-cursor watermarks, response schema fencing; serving with pushdown + keyset pagination + cache invalidation).
- Specialist: **data-duckdb** — the embedded-engine expression (memory/thread budgeting, larger-than-memory spilling and its limits, Parquet read/write layout, connection-as-cache).
- Specialist: **data-pipeline-operations** — the multi-pipeline coexistence expression (claims-based admission control, capacity pools, the capacity ratchet loop, subprocess-scope accounting).
- Specialist: **data-table-lifecycle** — the artifact-retirement expression (consumers-or-deprecate, drop durability, catalog-generated maintenance coverage).
