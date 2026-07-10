---
name: data-api
description: Use when consuming external HTTP APIs for data ingestion (rate limiting, exponential backoff, pagination/cursors, auth, response schema validation, caching, idempotent landing) or when serving gold/analytical data over HTTP (FastAPI + DuckDB, pushing filters down to the engine, keyset pagination, cache invalidation on publish, factory routers over many gold tables). Also use when defining serving contracts that honor persisted quality attributes, freshness SLIs, publish-token invalidation, or publish-coupled serving sidecars (derived projections rebuilt on source snapshot — not a second quality system). Covers blockchain-indexer / marketplace / price-feed ingestion and lakehouse gold-serving APIs. Don't use for defining semantic quality rules or thresholds (that's data-semantic-quality), generic REST/GraphQL interface design unrelated to data movement (api-and-interface-design), wrapping an API as a live MCP tool, or OLTP/CRUD application backends. Prefer the data hub when the right data skill is unclear or the task spans ingest→store→serve.

---

# Data APIs — consuming & serving

The operational API layer of a data pipeline, both directions: pulling data *in* from external APIs, and serving processed data *out*. This is not generic API design — it's the discipline that keeps ingestion resilient and serving fast over analytical data. The cross-cutting principles (idempotency, watermarks, schema fencing, resilience) live in the **data** hub; this skill is their API-specific expression.

> For the shared retry / circuit-breaker / dead-letter / idempotency code, see the hub's
> [`../data/references/resilience-and-idempotency.md`](../data/references/resilience-and-idempotency.md).

## When to invoke this skill

- Writing or debugging an ingestion client against a blockchain indexer, marketplace, price feed, or FX API.
- A pipeline that gets throttled (429s), loses its place on restart, or duplicates rows after a retry.
- Building or extending an HTTP service that serves gold/analytical tables to a dashboard or downstream consumer.
- A serving endpoint that's slow because it loads a table into Python and filters there, or paginates with `OFFSET`.
- Standing up many similar read endpoints over a set of gold tables.

## Part A — Consuming external APIs (ingestion)

Full code: [`references/client-ingestion.md`](references/client-ingestion.md).

### Throttle to the published limit; honor `Retry-After`

Stay under the documented rate with a token-bucket limiter rather than firing and reacting to 429s. When a 429 *does* arrive, obey the server's `Retry-After` header — don't guess a sleep. For token-quota APIs (LLM-style), budget on *both* requests/min and tokens/min.

**Test:** under sustained load, do you see steady throughput, or bursts of 429s and backoff? Bursts mean you're reacting, not pacing.

### Retry transient failures only, with backoff + jitter

Retry on 429/5xx and timeouts; never retry a 4xx that won't change (400/401/404). Exponential backoff + jitter (see hub resilience). Only retry reads, or writes you've made idempotent.

**Test:** does a 404 trigger five retries before failing? If so, your retry predicate is too broad.

### Pagination is a resumable watermark

Walk pages with a generator, and **persist the cursor** as you go (a file, a column, a table property). A crash mid-pull resumes from the last committed cursor instead of restarting the whole scan. Keyset/cursor pagination beats offset for large or live datasets.

**Test:** kill the pull at page 500 of 1000 and restart. Does it resume near 500, or start at page 1?

### Validate the response at the boundary

Parse every payload through a schema (pydantic for JSON, pandera for tabular) *before* it enters the pipeline. A malformed or silently-changed upstream fails loudly at ingestion with a clear message — not as a cast error three stages later. This is schema fencing (hub principle 3) at the front door.

**Test:** if the API adds a field or changes a type, does ingestion fail with an actionable error, or does bad data flow downstream?

### Be cache-friendly and idempotent

Use conditional requests (`ETag` / `If-Modified-Since`) so unchanged resources cost a cheap 304, not a full re-pull. Land raw responses idempotently: a deterministic filename keyed by `(source, cursor-window)`, written `tmp → rename`, so re-pulling a window overwrites identical bytes and dedup on merge is trivial.

**Test:** re-run yesterday's window. Does it re-download everything and create new files, or short-circuit on 304 and overwrite in place?

### Keep secrets out of code

Credentials come from env or a secret manager, never literals. Refresh tokens on a 401 and retry once; don't log the token.

## Part B — Serving data over HTTP

Full code: [`references/serving.md`](references/serving.md). Target stack: FastAPI + DuckDB over Parquet/Iceberg gold.

### Push filters down to the engine; never into Python

Build the `WHERE`/`ORDER BY`/`LIMIT` into the SQL so DuckDB prunes files and row groups. Never `SELECT *` then filter a DataFrame — that defeats every pruning layer the lakehouse gives you. Use parameterized queries; never string-interpolate user input.

**Test:** for a filtered request, how many rows does the engine read vs return? If it scans the whole table to return 50 rows, the filter isn't pushed down.

### Keyset pagination, not `OFFSET`

`OFFSET N` rescans N rows every page — page 1000 is 1000× the work of page 1. Keyset (`WHERE key > :last ORDER BY key LIMIT :n`) is O(page) regardless of depth. Return a stable envelope `{items, next_cursor}`.

**Test:** does response time for page 1000 match page 1? If late pages get slower, you're using OFFSET.

### Cache, but invalidate on publish

Cache query results keyed by a publish/version token (a `.publish_token`, or the table's current snapshot id). When gold republishes, the token flips and the cache misses exactly once — so readers never serve stale data and never cache forever.

**Test:** after a gold rebuild, does the API serve the new data on the next request? If it serves stale until a TTL expires, the cache isn't tied to the publish.

### Honor write-time quality attributes; do not re-derive them

Serving filters, labels, and default views consume **persisted** quality attributes (flags, reasons, confidence) from the published table. Do not re-implement cohort outlier logic or trust ladders in the request path except during a documented dual-read cutover. Defining those rules is **data-semantic-quality**; this skill is consumption-time contract.

**Test:** with all client-side junk filters disabled, do default endpoints still exclude rows the publish path flagged? If known-bad pack members appear, serving invented a second quality truth (or attributes were never stored).

### Publish-coupled serving sidecars (derived projections only)

When interactive latency cannot meet SLOs on the catalog table, a **sidecar** (sorted Parquet, cursor file, pre-agg) is allowed only as a **derived serving projection**:

1. Rebuild is hooked to successful source publish (same snapshot / version-hint / publish token).
2. Cache and cursor keys include the **source** version, not wall-clock alone.
3. Sidecar schema is part of the serving contract; missing columns fail deploy smoke.
4. Prefer applying quality-attribute filters **when building** the sidecar from source, not inventing new fences in the projection.
5. The sidecar is never a second fact table or system of record.

**Test:** publish source without rebuilding the sidecar (or with a stale version key). Does smoke or a version check fail, or does the API quietly serve yesterday's projection as current?

### Caches are bounded types; executors wait on exit

A cache is a type whose constructor requires a max size — never a bare module-level `dict` that only
checks TTL on read; that shape grows monotonically to OOM under real traffic (measured). If a per-key
lock registry sits alongside the cache, it must be bounded too. A shared `ThreadPoolExecutor`
(replacing a scoped `with ThreadPoolExecutor()`) drops the implicit wait-on-exception the `with` form
gives you — wait for every submitted future in `finally`, or a caller's cleanup can run while futures
are still using resources it just closed.

**Test:** can the cache be constructed without a size? Does an exception inside one submitted future
let the caller's cleanup proceed before every future finishes? Either "yes" is the bug.

### One read-only connection per worker; factory the routers

Open one read-only DuckDB connection per worker with a `memory_limit`, not one per request. For many similar gold tables, generate list/by-key/top-N/summary endpoints from a spec dict (a new table = a ~10-line registration), with a `safe_where` helper that `DESCRIBE`s the table so one router tolerates slightly different column sets. Whitelist sort/filter fields against an allowlist; emit pydantic response models so FastAPI publishes a correct OpenAPI contract.

**Test:** does adding a new gold endpoint mean writing a new router by hand, or registering a spec? And can a caller sort by an arbitrary (unindexed, unvalidated) column?

## References

- **Consuming external APIs** — rate limiting, backoff, pagination, auth, response validation, caching, `polite_get`: [`references/client-ingestion.md`](references/client-ingestion.md)
- **Serving data over HTTP** — pushdown, keyset pagination, cache invalidation, quality-attribute honor, publish-coupled sidecars, bounded/thread-safe caches, executor lifecycle, factory routers, connection management: [`references/serving.md`](references/serving.md)
- **Shared resilience & idempotency** (hub): [`../data/references/resilience-and-idempotency.md`](../data/references/resilience-and-idempotency.md)
- **Semantic quality rules** (define attributes, not serve them): **data-semantic-quality**
