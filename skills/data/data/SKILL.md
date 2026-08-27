---
name: data
description: Hub for data-engineering pipeline work — storage/ingest/serve choice plus shared discipline (idempotency, incremental-not-full-recompute, schema fencing, resilience, bounded memory, layered enforcement). Routes to data-apache-lakehouse, data-api, data-duckdb, data-pipeline-operations, data-table-lifecycle, data-semantic-quality, data-identity-resolution, and data-product-eval. Use when a task spans ingest → store → serve, the specialist isn't obvious, or you need a live coverage audit. Don't use for OLTP schema design, one-off notebooks, generic SQL, ML training, or BI config. When a specialist clearly fits, skip this hub and load it directly.
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
| **Semantic row truth** — quality flags, outlier/anomaly rules, trust ladders, golden packs, split-brain lake vs API quality | **data-semantic-quality** |
| **Attaching** messy records to a canonical entity key — fail-closed, quarantine, unresolved debt, remap | **data-identity-resolution** |
| **Scoring published estimates** vs later realized facts — freeze, walk-forward, coverage vs error | **data-product-eval** |
| **Coverage audit** — “how much / how fresh / how resolved” from live tables, not docs | **this hub** (playbook below), then the specialist that owns the hole |
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
- An **entity-keyed lifetime reload on a watermarked delta** — the watermark correctly selects *which entities changed*, then the job does `WHERE entity_id IN (...)` with **no time predicate** and reloads that entity's entire history (measured: Iceberg COW of 2016–now month files because one card sold today). Bound the score *and* the overwrite to the partition time column (`ts >= now - lookback`). Lifetime rescore is `--rebuild` / `--full` only.
- An **accumulating-delta unique on a frozen basis** — the job is chunked and checkpoints, so it *looks* incremental, but each checkpoint `unique()`s every delta so far (or merges against a start-of-run snapshot that fails the PK probe, so every chunk logs "no existing"). Comments that say "peak RAM is one chunk" are not the code. Measured 2026-08-27: TCGPlayer history, 64-file chunks, `merge sink start (no existing)` on chunk 8/47, 4.6M-row unique at 7.6G RSS, 21 minutes with no further log, MemoryHigh sitting at the peak. Fix: unique *this* chunk only, upsert into *current* gold, newest snapshot wins. A docstring or `chunk=` log is not the test.
- A **write-window / read-window split** — Iceberg overwrite is partitioned by `(source, as_of_date)` but the builder `rglob`s every jsonl under raw-root into one list, then unique()s it. Partitioned write does not make the read incremental. Measured 2026-08-27: Rare Candy catalog sitemap 404 → 0 new URLs, gold still loaded ~499 jsonl files, 5.6G over MemoryHigh=5G, no row log for 16 minutes. Daily path reads today's run_id files only; lifetime is `--all-runs` / `--rebuild`.
- An **mtime watermark on a partial chunked ingest of older files** — after chunk 8 the gold file's mtime is *now*, so a restart treats the remaining 2483 older raw files as already consumed and skips them. File mtime vs gold mtime is not a file-list cursor. Either keep an explicit remaining-paths watermark, or `--rescan` / delete the incomplete gold before restart.
- An **in-memory unique of a pinned snapshot** — Iceberg load is already tip-dated (even `sink_parquet`'d), then the mapper concats every batch and `unique(listing_id, observed_date)` on the whole snapshot in Polars. Measured 2026-08-27: listings-gold tcgplayer, `venue_unique` 11,051,981 rows at 14.8G RSS sitting on MemoryHigh=14G, 20+ min with no `phase_end`. Fix: unique each map batch, spill-union via DuckDB. Peak RSS must follow batch size, not snapshot row count.
- An **unwindowed sidecar rebuild of a lifetime fact table** — a daily Model-1 labels job `scan_to_polars`s all `gold.sales` including `title`. Measured 2026-08-27: 24.6M rows, 20.2G RSS, `TimeoutStartSec` SIGTERM before Iceberg write. Daily path is a lookback merge onto the last parquet; lifetime is `--full`.

**Test (entity leak):** a new fact for one entity today — does runtime grow with that entity's lifetime row count, or with the lookback window? If it grows with lifetime, the watermark is decorative.

**Test (chunked unique leak):** after chunk 2, does the merge log `existing=` / `preserved=` against current gold, or `existing=0` / `no existing` again? If the latter, the basis is frozen or PK-invalid and each chunk is O(corpus-so-far). Peak RSS after chunk N must not track unique(rows 1..N).

**Test (read vs write window):** with no new files today, does the gold step skip, or does RSS grow with the full raw tree? If it grows, the read is lifetime.

A full-rebuild trigger (schema change, resolver bump, backfill) belongs on its **own lane**, separate
from the regular incremental run, with checkpoints that survive a retry. A rebuild whose retry logic
wipes its own staging checkpoints resets to record one on every crash and, on a large enough history,
never finishes — measured: 9 attempts over 19 hours, 0 successes, each retry restarting a 602-day
rebuild from day 1.

**Test:** if the upstream grew 10× tomorrow, would this step's runtime grow 10×? If yes, it lacks a watermark. Separately: does a crash mid-rebuild resume from a checkpoint, or restart from record one? If it restarts, the rebuild lane isn't resumable and won't survive its own retries on real data volume.

### 3. Fence schema at every boundary

Validate columns, types, and null fractions at each layer/stage edge, and fail *loud at the boundary*. A malformed upstream payload should error at ingestion with a clear message — not surface as a cryptic cast error three stages downstream. Keep a strict mode that turns warnings into hard failures in production.

This is **mechanical** validation. **Semantic** correctness (right entity, right attributes for the consumer use — quality flags, trust ladders, cohort fences) is a separate concern: use **data-semantic-quality**. Schema fences alone do not make rows trustworthy for product aggregates.

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

## Coverage audit playbook

Use when the ask is inventory, not a code change: how much data, how fresh, how
usable. **Query the live warehouse / serving path.** Frozen onboarding docs and
agent memory are not evidence.

```
Coverage audit:
- [ ] 1. Name the consumer question (source × grain × window)
- [ ] 2. Read live tables (or the serving sidecar + its publish token) — not README/CLAUDE.md
- [ ] 3. Per source: landed rows, last watermark / as-of, absent vs empty vs stale
- [ ] 4. Identity rate: assigned / landed (unresolved and quarantine are not “coverage”) — **data-identity-resolution**
- [ ] 5. Stratify (status, cohort, age). A global % hides empty slices
- [ ] 6. Name the consumer of each table (**data-table-lifecycle**)
- [ ] 7. If the question is estimate honesty, stop and load **data-product-eval**
```

**Test:** can you answer “how many resolved rows landed in the last 7 days, per source, and when did each watermark move?” from published signals? If the answer came from a markdown file, the audit failed.

Principle 7 (freshness is observable) is the signal. This playbook is how you *read* it.

## References

- **Shared resilience & idempotency code** (retry + jitter, circuit breaker, dead-letter queue, idempotency keys): [`references/resilience-and-idempotency.md`](references/resilience-and-idempotency.md)
- Specialist: **data-apache-lakehouse** — the Iceberg-specific expression of these principles (OCC retry, snapshot watermarks, WAP branches, compaction).
- Specialist: **data-api** — the API-specific expression (rate-limit buckets, pagination-cursor watermarks, response schema fencing; serving with pushdown + keyset pagination + cache invalidation).
- Specialist: **data-duckdb** — the embedded-engine expression (memory/thread budgeting, larger-than-memory spilling and its limits, Parquet read/write layout, connection-as-cache).
- Specialist: **data-pipeline-operations** — the multi-pipeline coexistence expression (claims-based admission control, capacity pools, the capacity ratchet loop, subprocess-scope accounting).
- Specialist: **data-table-lifecycle** — the artifact-retirement expression (consumers-or-deprecate, drop durability, catalog-generated maintenance coverage).
- Specialist: **data-semantic-quality** — row-truth methodology (write-time quality attributes, entity-scoped rules, trust ladders, golden packs); domain thresholds stay in the product repo.
- Specialist: **data-identity-resolution** — attach/remap procedure (fail-closed, quarantine, unresolved-rate, restamp order).
- Specialist: **data-product-eval** — estimate vs later realized truth (freeze, walk-forward, coverage vs error, release vs observe).
