---
name: apache-lakehouse
description: Use when designing, modifying, or debugging Apache Iceberg lakehouses (bronze/silver/gold medallion specifically on Iceberg) — PyIceberg + Polars/DuckDB/Arrow/pandas writes, Spark or Flink ingestion, catalog choice (Glue/REST/Polaris/Lakekeeper/Nessie/JDBC), Spark/Trino maintenance procedures, gold aggregates, compaction/expire/orphan, branching/WAP, CDC, snapshot rollback, slow incremental jobs, lock contention, schema evolution. Includes Iceberg internals and PyIceberg metadata-table diagnostics. Don't use for Delta Lake or Databricks-native medallion, Apache Hudi, Snowflake-native, or BigQuery-native designs — even if "medallion" is mentioned. Don't use for plain Parquet on S3 with a Hive metastore (that's not Iceberg), OLTP modeling, generic Airflow/dbt orchestration unrelated to Iceberg, or Postgres/MySQL schema work — different invariants.
---

# Apache Iceberg Lakehouse

Domain skill for building and operating Python-first Apache Iceberg lakehouses: PyIceberg + Polars/DuckDB medallion writes, REST/Glue catalog choice, and the architectural discipline that keeps incremental jobs incremental.

> **Verified:** 2026-05-28 against PyIceberg 0.11.1, pyiceberg-core 0.8.0, Iceberg spec V2/V3.
> Claims tagged `[v0.11]` and the **PyIceberg capability matrix** (in
> [`references/pyiceberg-capabilities.md`](references/pyiceberg-capabilities.md)) are
> version-sensitive — re-check against your installed version (`pip show pyiceberg`) before trusting
> them; the matrix lists how to verify each in seconds. Everything else (Iceberg internals, the
> architectural principles) is format/architecture-level and ages slowly.

## When to invoke this skill

- Designing a new pipeline, layer, or transform in a bronze/silver/gold lakehouse.
- Adding or modifying a gold aggregate, analytics view, or derived table.
- Debugging incremental jobs that get slower as data grows, scheduled jobs that overrun their window, lock contention, memory pressure, or "metadata bigger than data."
- Reviewing any PR that touches a layer boundary (bronze→silver, silver→gold) or the catalog config.
- Choosing or swapping a catalog backend (Glue, REST, Polaris, Lakekeeper, Nessie, JDBC, Hive).
- Picking compaction / expire-snapshots / orphan-file-removal cadence for a table.
- Deciding between Iceberg, Delta, and Hudi for a new lakehouse.
- Investigating a bad publish — finding the right snapshot to roll back to, auditing what a backfill landed.

If you're about to add a global lock, a "rebuild from full history" path, a Parquet mirror next to an Iceberg table, a cron that recomputes a snapshot from scratch, or a write that bypasses the catalog — stop and read this skill first.

## Medallion rules

1. **Bronze** — raw ingest, minimal transforms, append-friendly.
2. **Silver** — typed, deduped, schema-validated; fail closed on drift when correctness depends on it.
3. **Gold** — business aggregates; read silver/bronze only; no back-writing to lower layers in the same job.

## Iceberg internals worth knowing (the parts that change how you write code)

The skill assumes you know the layered model (datafiles → manifests → manifest list → metadata.json → catalog). These are the facts that actually change PyIceberg-writer behavior:

- **Pruning happens twice, at different layers.** Manifest entries carry per-column lower/upper bounds, evaluated at *planning* time (cheap Avro reads, zero datafiles touched). Parquet row groups carry their own min/max, evaluated at *scan* time after the file is opened. A predicate on a sorted/partitioned column gets both layers; a predicate on an unsorted high-cardinality column gets ~no manifest pruning. **This is why sort order matters: it tightens manifest bounds.**
- **Manifest lists carry partition bounds and per-snapshot sequence numbers.** Diffing two snapshots is a manifest-list-only walk — you never need to open datafiles to find what changed. This is the underlying machinery of incremental reads even when PyIceberg only exposes it indirectly via watermark columns.
- **`last-sequence-number` in `metadata.json` is the OCC primitive.** Every commit bumps it. Equality deletes are scoped by it (a delete with sequence N only applies to data files with sequence < N). A re-inserted row gets a higher sequence number and survives. This is also what `CommitFailedException` retries depend on — your exactly-once primitive in PyIceberg.
- **The catalog stores exactly one pointer per table** — the current `metadata.json` path. Atomic CAS on that pointer is the entire basis for ACID. Hadoop catalog on S3 has no atomic rename → corruption under concurrent writers. Use REST/Glue/Nessie/JDBC for any multi-writer S3 deployment.
- **Manifests are Avro, never mixed.** A manifest tracks datafiles or delete files, never both. Reading manifests is fast; rewriting them (`rewrite_manifests`) is cheap relative to data rewrites.
- **Stats are written at commit time, not by a separate job.** Unlike Hive, Iceberg manifests are always fresh because writers compute bounds inline. Don't add a post-write "stats job" — it doesn't exist.
- **Puffin files** carry precomputed sketches (currently Theta sketches for approximate distinct counts). PyIceberg does not read or write them today. Don't pin a `COUNT DISTINCT` SLA to puffin if PyIceberg is in the loop.

## Architectural principles

Load-bearing properties of any Iceberg lakehouse transform. Each principle is paired with a falsifiable test — if you can't pass the test, the principle is being violated, not "applied differently."

### Forward motion is a watermark, not a scan

Every layer-to-layer promote carries a persisted high-water mark on its time/sequence column (`event_ts`, `sequence_id`, `updated_at`, etc.). The watermark commit is part of the same atomic write as the data — not a side-effect afterward. A transform with no watermark is a global recompute waiting to happen; it passes tests today and gets slower in proportion to data growth, with no warning. "Rebuild from history" exists only behind an explicit `--rebuild` flag, never as the default code path.

PyIceberg has no `incrementalAppendScan` yet (Java does). A watermark column committed atomically with the data is the substitute, and it lines up with Iceberg's own model: each commit bumps `last-sequence-number`; your watermark carries equivalent semantics at the row level.

**Test:** if the upstream table grew 10× tomorrow, would this transform's runtime grow 10×? If yes, it lacks a watermark.

### Every aggregate has a declared shape

Each gold/analytics aggregate is one of three shapes, and the shape is named in the module:

- **Append-only ledger** — immutable primary key; `append` on the delta dedupes by key.
- **Point-update keyed snapshot** — `MERGE INTO` on the keys touched by the delta. Cost is O(delta), not O(history).
- **Windowed scan** — bounded `source.filter(ts > now - window)` with partition pruning, on its own cadence.

"Full rebuild" is none of these. If you can't put one of the three labels on an aggregate, the architecture is wrong — don't slow the cadence to mask the cost, reshape the aggregate.

**Test:** can you write `# shape: append | point_update | windowed_scan` at the top of the aggregate's module without lying? If no, redesign.

### Maintenance is owned, not hoped for

PyIceberg can now **expire snapshots** `[v0.11]` (`table.maintenance.expire_snapshots()`), but this is **metadata-only — it does not physically delete the orphaned data files** (see the capability matrix). It cannot compact or remove orphan files at all. Physical file GC and compaction are Spark procedures, Trino `ALTER TABLE ... EXECUTE`, or a managed service. Untended Iceberg tables silently grow until metadata reads dominate query time and small files defeat manifest pruning. The safe order is fixed: `rewrite_data_files` → `expire_snapshots` (≥3-day window) → `remove_orphan_files` (≥3-day window) → `rewrite_manifests`. Skipping the safety window is how you delete files a still-running query needs.

There are now three legitimate ways to own maintenance — pick one explicitly, don't leave it implicit:

1. **External engine** — Spark procedures or Trino `EXECUTE optimize` on a schedule. Most control; you operate the cluster.
2. **Managed / zero-ops storage** `[2025]` — the catalog or storage layer runs policy-driven compaction, snapshot expiration, **and** orphan-file removal on the backend, decoupled from your Python pipeline. Examples: Amazon S3 Tables (continuous compaction + expiration since 2025), Cloudflare R2 Data Catalog, Polaris-managed maintenance. This is the only option where expiry *and* physical GC both happen without you wiring a second job.
3. **Hybrid** — PyIceberg `expire_snapshots` for metadata hygiene from your pipeline, plus a scheduled external/managed job for the physical `remove_orphan_files` + compaction it cannot do.

**Test:** name the person/service, the cadence, and the command (or backend policy) that maintains this table — **and** confirm physical file GC is covered, not just metadata expiry. If any of those is "I'll figure it out," the maintenance does not exist.

### Validation belongs on a branch, not in production

PyIceberg supports branches and tags since 0.8. Treat the `main` branch of an Iceberg table as published state; do risky work (large backfills, schema reshuffles, suspicious silver→gold rewrites) on a named branch, validate against it, then merge or discard. This is the write-audit-publish pattern expressed natively in Iceberg. A staging mirror that lives outside the catalog is a hidden interface; an Iceberg branch is a first-class one. Nessie adds multi-table atomic branch merges if you need them.

**Test:** if this promotion failed audit, could you discard it by dropping a branch? If the answer involves manually rewinding writes to the live table, it shouldn't have been on the live table.

### File size is a quality dimension

Parquet file size sets the floor on every downstream query's planning and IO cost. Target ~256 MB; tolerate 128–512 MB; flag and compact anything systematically under 50 MB or over 1 GB. High-frequency writers earn a more aggressive compaction cadence; rarely-updated gold can tolerate days between compactions. The shape of the file layout is a contract the lake owes to readers, not an emergent property of however the writer happened to flush.

Compaction strategy follows query pattern, not folklore:

| Strategy | When | Cost |
|---|---|---|
| **BinPack** | Streaming SLA / unclustered reads acceptable | Fastest compaction |
| **Sort** | One dominant filter column | Slower than BinPack; tight manifest bounds on the sort key |
| **Z-Order** | Two or more equally important filter columns | Slowest; best multi-column file pruning |

Scope compaction to a window (`where ts >= now - interval '1 hour'`) and turn on `partial-progress-enabled` so readers benefit sooner and large jobs don't OOM. Target file size 256–512 MB; keep the Parquet row group size (default 128 MB) dividing evenly into it.

**Test:** what is the p50 file size on this table right now? If you don't know, you don't know whether reads are healthy — go look before claiming the table is fine.

### Catalogs are commodities; pick for latency and governance

The REST Catalog spec is the standardized interface, and every serious catalog speaks it. The backend is a swappable choice driven by two real properties: commit latency under your concurrency, and the governance/auth model you need.

- **Apache Polaris** — ASF TLP; donated by Snowflake; full RBAC + credential vending. Best self-hosted open-source option for multi-engine access control.
- **Lakekeeper** — Rust single-binary; OPA authorization; lowest commit latency. Best for latency-sensitive or resource-constrained deployments.
- **Apache Nessie** — git-branching catalog; required for multi-table atomic WAP and catalog-level rollback across multiple tables in one move.
- **AWS Glue** — managed; good for AWS-native shops; weak branch/tag story. Credentials follow the standard `boto3` chain.
- **JDBC** — PostgreSQL/MySQL-backed; reasonable small-to-medium production catalog if you already operate a managed RDB. No multi-table transactions.
- **Hive Metastore** — only worth it if you already run one and intend to keep it. Not worth standing up new.
- **Hadoop / file-system catalog** — local dev only. Unsafe on S3 without a DynamoDB sidecar (no atomic rename).
- **`tabulario/iceberg-rest`** — REST reference implementation. Prototype only.
- **SQLite / in-memory** — local dev only.

**Catalog migration is a pointer move, not a data copy.** Use the `iceberg-catalog-migrator` CLI (lives in the Project Nessie repo) to move tables between any of the above. Prefer `migrate` (transfers ownership, removes source) over `register` (leaves both pointing at the same data) — concurrent writes through two catalogs to the same table is silent corruption.

Python client code does not change when the backend does — that's the point.

**Test:** could you swap your catalog backend without touching any Python outside the catalog constructor and env vars? If no, find the leak — something is depending on backend-specific behavior.

## Architectural red flags

When you see one of these, stop and audit — the table tells you which principle is probably broken.

| Smell | Likely principle violated |
|---|---|
| "Rebuild the snapshot from full history" | Watermark, declared aggregate shape |
| `read_parquet(full_curated_file)` in a promote step | Watermark, single source of truth |
| Parquet file next to an Iceberg table for the same data | Single source of truth |
| Cron more frequent than the rebuild cost it triggers | Watermark, declared aggregate shape |
| Global lock between independent pipelines to "prevent OOM" | All of the above (lock is the symptom, not the fix) |
| Two transforms peak at large RSS and "fight for memory" | Watermark, declared aggregate shape |
| Cryptic pyiceberg / arrow error far from the writer | Schema fence on the read side missing |
| `unique()` happens "later" or "on read" instead of pre-upsert | Schema fence; PyIceberg upsert requires unique source rows |
| One pipeline's failure cascades into skipped runs for unrelated pipelines | Pipeline isolation (and probably a global recompute upstream) |
| "We'll compact later" with no scheduled job | Maintenance is owned |
| Table metadata size approaches data size | Maintenance is owned (snapshot expiration missing) |
| Catalog tightly bound to backend-specific quirks in client code | Catalogs are commodities |
| Large backfill written directly to `main` | Validation belongs on a branch |
| Parquet files systematically under 10 MB | File size is a quality dimension |
| Equality deletes attempted from Python | PyIceberg can't write or read them — use Spark/Flink for MOR CDC, or upsert from Python |
| High-cardinality identity partitioning (e.g., per-user partitions) | Use `bucket(col, N)` transform; identity partition explodes manifests |
| Many tiny manifests; `manifests().length` distribution skewed small | Need `rewrite_manifests`; many small commits without manifest compaction |
| `HadoopCatalog` on S3 with multiple writers | Catalog atomicity gap — switch to REST/Glue/Nessie/JDBC |
| `COUNT DISTINCT` SLA assumed via puffin files | PyIceberg doesn't read/write puffin; design around it |
| Schema evolution mid-CDC cycle | Changelog views span schema boundaries and break; pause CDC during evolution |
| `register` used (not `migrate`) for catalog cutover with writers still active on old catalog | Two writers, no shared CAS — corruption path |

## PyIceberg metadata inspection (your production diagnostic toolkit)

`table.inspect.*` is the operational view. Each metadata table answers one diagnostic question — learn which:

| `table.inspect.X` | Answers |
|---|---|
| `snapshots()` | What did the last write actually add? Read `summary['added-records']`, `summary['added-data-files']`. |
| `history()` | Was there a rollback, and when? Two rows sharing `parent_id` where only one has `is_current_ancestor=true`. |
| `files()` | Which partitions need compaction? Group by partition; high `file_count` with low avg `file_size_in_bytes`. |
| `manifests()` | Manifest sprawl? Compare each row's `length` to the average; small ones want `rewrite_manifests`. |
| `partitions()` | Distribution skew or surviving old partition spec? Group by `spec_id`. |
| `entries()` | Full lifecycle of one file — when added, when deleted, under which snapshots. |
| `refs()` | Which branches/tags exist, what retention rules they enforce. |
| `metadata_log_entries()` | Which schema version was live at time T. |

**Recipes:**

- **Find pre-incident snapshot for rollback:** `history()` filtered `made_current_at < incident_ts`, take latest. Feed `snapshot_id` to `manage_snapshots().rollback_to_snapshot()`.
- **Audit a backfill:** snapshot summary first; then join `entries(status=1)` to `files()` on `file_path` for that snapshot for per-file row counts and partition assignment.
- **Detect compaction candidates:** `files()` grouped by partition, sort by `file_count desc, avg_size asc`.
- **Detect manifest sprawl:** `manifests()`; flag rows where `length` < 0.5 × avg.

## Branching & rollback recipes

### Single-table branching (PyIceberg-native, ≥0.8)

```python
table.manage_snapshots().create_branch(name, snapshot_id) \
    .set_min_snapshots_to_keep(10) \
    .set_max_snapshot_age_ms(...) \
    .commit()
```

Lifecycle: `create_branch` → write with branch param → validate against branch snapshot → `fast_forward("main", branch)` on pass, drop on fail. Tags are the same API (`create_tag`) but immutable — use for end-of-period audit pins.

**WAP from PyIceberg:** set `write.wap.enabled=true` on the table, write to the branch, run validation queries against the branch snapshot, then `cherrypick_snapshot(branch_head_id)` on pass. Caveat: cherry-pick is single-snapshot — multi-commit ETL on a branch must be collapsed first, or switch to a Nessie-catalog branch merge.

### Catalog branching (Nessie only)

A single Nessie commit covers all tables atomically. Use when you need cross-table transaction semantics or whole-lake dev/staging/prod environments. PyIceberg connects to Nessie REST; per-table writes go through normal table operations; the Nessie commit is the publish boundary.

### Rollback — what's reversible

| Operation | Reversible? |
|---|---|
| `rollback_to_snapshot(id)` (pointer move) | Yes — until `expire_snapshots` removes the orphan |
| Drop a branch | Yes — files survive until expire |
| `expire_snapshots` | **No** — physical delete |
| `remove_orphan_files` | **No** — physical delete |
| Nessie reference move | Yes — old commit hash still exists |

Rule: rollback first, validate that the world is sane, *then* expire. Never chain expire into a rollback recipe.

### CDC two-table pattern (when COW is acceptable)

1. Append-only `*_changes` table fed by source CDC (insert/update/delete records with `_change_type`).
2. Aggregated `*_summary` table updated via `MERGE INTO` keyed by entity ID, applying net delta per key.
3. Cost scales with change volume, not table size. The summary never does a full GROUP BY.

PyIceberg is COW-only — every UPDATE rewrites containing files. Acceptable for hourly/daily CDC, not for sub-minute streaming. For high-frequency CDC, do the source writes via Spark/Flink in MOR mode and let PyIceberg read or perform the summary merge.

## Recommended Python-first stack

- **Storage:** S3 / R2 / MinIO. Parquet, 256 MB target files. Conditional writes available since 2024.
- **Object storage layout:** set `write.object-storage.enabled=true` for S3/GCS/ADLS — distributes file paths via hash prefix, eliminating LIST hot spots when partition or file count is high.
- **Write distribution mode:** `hash` for partitioned tables (one writer per partition cleanly), `range` for sorted output, `none` only for append-only streaming where compaction will re-cluster later.
- **Table format:** Apache Iceberg V2; V3 only when equality deletes are needed.
- **Catalog:** Polaris or Lakekeeper via REST for self-hosted; Glue for AWS-native; JDBC if you already run a managed RDB.
- **Reads:** PyIceberg scan → Polars `LazyFrame`; DuckDB 1.4+ for SQL analytics on gold.
- **Writes:** PyIceberg `append` / `upsert` for bronze→silver; dbt-trino or dbt-duckdb for silver→gold.
- **Maintenance:** external engine (Spark procedures weekly / Trino `EXECUTE optimize`), **or** managed zero-ops storage `[2025]` (S3 Tables, R2 Data Catalog, Polaris-managed) that runs compaction + expiry + orphan removal on the backend, **or** hybrid (PyIceberg `expire_snapshots` for metadata + a scheduled job for physical GC). PyIceberg alone cannot compact or remove orphan files.
- **Orchestration:** Dagster software-defined assets (assets *are* Iceberg tables); Prefect or Airflow as alternatives.
- **WAP / quality:** Iceberg branches (single-table) or Nessie (multi-table atomic); dbt tests + Great Expectations at the bronze boundary.

## Decision template for new work

Before writing a new transform, derived table, gold aggregate, or maintenance job, answer these on paper. If any answer is "not sure" or "we'll figure it out at runtime," do not start coding.

1. **What is the watermark column** (`event_ts`, `sequence_id`, `updated_at`, …) and where is it persisted?
2. **What is the source of truth for the layer this writes to?** Is there a parallel mirror? Why?
3. **What shape is this aggregate** — `append`, `point_update`, or `windowed_scan`? None of those means redesign.
4. **What is the schema fence on the read side?** What error message does a downstream consumer see if my output is malformed?
5. **Who maintains this table** — what is the compact/expire/orphan cadence and who runs it?
6. **What happens to other pipelines if this one hangs for an hour?** If the answer involves a global lock, redesign.

## PyIceberg capability matrix (version-sensitive)

The claims most likely to age as PyIceberg releases live in a single table in
[`references/pyiceberg-capabilities.md`](references/pyiceberg-capabilities.md) — pinned to one
version + date, with a "Verify by" column that turns "is this still true?" into a few seconds of
grep/doc-check. Read it before relying on any `expire_snapshots` / `remove_orphan_files` /
equality-delete / compaction claim, and update that one table (not scattered prose) when you bump
PyIceberg. Headline as of `[v0.11.1 · 2026-05]`: `expire_snapshots` is metadata-only, and
`remove_orphan_files` / `rewrite_data_files` / `rewrite_manifests` / equality deletes are all
**absent** from PyIceberg — physical GC and compaction still need Spark/Trino/managed.

## PyIceberg gotchas worth memorizing

- **Upsert requires unique source rows.** Always dedup pre-upsert: `df.sort(ordering_col).unique(subset=upsert_keys, keep="last")`. Never rely on the catalog to dedup.
- **Name mapping** — PyIceberg needs field IDs; if you `add_files()` Parquet that has no field IDs, persist `schema.name-mapping.default` first.
- **Sorted writes** — declaring a sort order on the table doesn't make PyIceberg sort on commit. Sort the DataFrame yourself, or do the initial layout via Spark/Trino.
- **Bucket / Truncate partition transforms can't be written from Python yet** `[v0.11]`. Initial layout via Spark or Trino.
- **Equality deletes are out** `[v0.11]` — PyIceberg can neither read nor write them reliably (the Rust core does not change this). Use COW upserts from Python, or accept a Spark/Flink hop for MOR CDC. Mixed-engine MOR pipelines may return wrong results when PyIceberg reads — compact before PyIceberg consumes.
- **No incremental snapshot-to-snapshot reads** `[v0.11]` from Python yet (Java has `incrementalAppendScan`). Use a watermark column.
- **`expire_snapshots` is metadata-only** `[v0.11]` — `table.maintenance.expire_snapshots()` prunes the snapshot history tree but leaves the orphaned Parquet on storage. It does **not** save storage cost on its own; physical GC (`remove_orphan_files`) and compaction (`rewrite_data_files`, `rewrite_manifests`) are still Spark/Trino/managed only. See the capability matrix.
- **Optimistic concurrency control.** Retry on `CommitFailedException`; this is your exactly-once primitive.
- **Metrics column control.** `write.metadata.metrics.column.<col>` controls per-column stats in manifests. Drop to `counts` or `none` for high-cardinality string columns never filtered on; keep `full` on every column used in `WHERE`. Wrong setting = either huge manifests or no pruning.
- **`HadoopCatalog` on S3 is unsafe under concurrent writers.** No atomic rename. Use REST/Glue/Nessie/JDBC for any multi-writer S3 deployment.
- **Puffin files** `[v0.11]` — PyIceberg doesn't read or write them. Don't depend on Theta-sketch-backed COUNT DISTINCT if PyIceberg is in the loop.
- **Cherry-pick is single-snapshot.** A multi-commit ETL job on a branch can't be cherry-picked atomically — collapse it first, or use Nessie branch merge.

## References

- Iceberg spec: <https://iceberg.apache.org/docs/latest/>
- PyIceberg docs: <https://py.iceberg.apache.org/>
- PyIceberg source (read this when behavior is undocumented or you suspect a version gap): <https://github.com/apache/iceberg-python>
- *Apache Iceberg: The Definitive Guide* — Shiran, Hughes, Merced (O'Reilly, 2024). Source for the internals, metadata-table, branching, and rollback material in this skill. Note: written before Polaris and Lakekeeper, and predates much of PyIceberg's branching API — treat its Spark/SQL examples as concept references, not recipes.
- Polaris: <https://polaris.apache.org/>
- Lakekeeper: <https://lakekeeper.io/>
- Nessie: <https://projectnessie.org/>
- Catalog migrator: <https://github.com/projectnessie/iceberg-catalog-migrator>
- `pyiceberg-core` (Rust bindings): <https://github.com/apache/iceberg-python> (the `pyiceberg-core` extra) and iceberg-rust: <https://github.com/apache/iceberg-rust>
- Amazon S3 Tables — managed Iceberg storage with policy-driven maintenance `[2025]`: <https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html>
- Cloudflare R2 Data Catalog (managed Iceberg) `[2025]`: <https://developers.cloudflare.com/r2/data-catalog/>

> Version-sensitive capability claims and how to re-verify them live in
> [`references/pyiceberg-capabilities.md`](references/pyiceberg-capabilities.md). Update that table and
> its **Verified** date when you bump PyIceberg.
