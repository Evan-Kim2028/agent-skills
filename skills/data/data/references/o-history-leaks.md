# O(history) leaks disguised as incremental

> Loaded on demand from the **data** hub, principle 2. A watermark somewhere in
> the code is not the test. If a specific operation still scales with total
> history instead of the delta, the step is not incremental.

Each shape has a falsifiable test. If the test fails, the leak is present, not
"applied differently."

## 1. Full-history re-walk

Re-reading an entire JSONL/log from the start every run instead of from the
watermark. Measured: thousands of redundant walks per run.

**Test:** if the log grew 10×, does this step's runtime grow 10×?

## 2. Full-column preflight scan

Scanning millions of rows to check a condition a pushdown predicate would
answer for free. Measured: 2.48M rows scanned hourly where a predicate made it
near-free.

**Test:** `EXPLAIN` / `plan_files()` — is the preflight a metadata or predicate
read, or a full column scan?

## 3. Unbounded anti-join key collect

Materializing every key ever seen instead of scoping to the chunk's own date
range when the key embeds a date.

**Test:** does the anti-join key set grow with corpus size, or with this
chunk's window?

## 4. Entity-keyed lifetime reload on a watermarked delta

The watermark correctly selects *which entities changed*, then the job does
`WHERE entity_id IN (...)` with **no time predicate** and reloads that
entity's entire history. Measured: Iceberg COW of 2016–now month files because
one entity sold today. Bound the score *and* the overwrite to the partition
time column (`ts >= now - lookback`). Lifetime rescore is `--rebuild` /
`--full` only. Iceberg form: **data-apache-lakehouse**.

**Test:** a new fact for one entity today — does runtime grow with that
entity's lifetime row count, or with the lookback window?

## 5. Accumulating-delta unique on a frozen basis

The job is chunked and checkpoints, so it *looks* incremental, but each
checkpoint `unique()`s every delta so far (or merges against a start-of-run
snapshot that fails the PK probe, so every chunk logs "no existing"). Comments
that say "peak RAM is one chunk" are not the code. Measured 2026-08-27:
marketplace history, 64-file chunks, `merge sink start (no existing)` on chunk
8/47, 4.6M-row unique at 7.6G RSS, 21 minutes with no further log, MemoryHigh
sitting at the peak. Fix: unique *this* chunk only, upsert into *current* gold,
newest snapshot wins. A docstring or `chunk=` log is not the test.

**Test:** after chunk 2, does the merge log `existing=` / `preserved=` against
current gold, or `existing=0` / `no existing` again? Peak RSS after chunk N
must not track unique(rows 1..N).

## 6. Write-window / read-window split

Iceberg overwrite is partitioned by `(source, as_of_date)` but the builder
`rglob`s every jsonl under raw-root into one list, then unique()s it.
Partitioned write does not make the read incremental. Measured 2026-08-27:
catalog sitemap 404 → 0 new URLs, gold still loaded ~499 jsonl files, 5.6G
over MemoryHigh=5G, no row log for 16 minutes. Daily path reads today's
`run_id` files only; lifetime is `--all-runs` / `--rebuild`.

**Test:** with no new files today, does the gold step skip, or does RSS grow
with the full raw tree?

## 7. mtime watermark on a partial chunked ingest

After chunk 8 the gold file's mtime is *now*, so a restart treats the remaining
older raw files as already consumed and skips them. File mtime vs gold mtime is
not a file-list cursor. Either keep an explicit remaining-paths watermark, or
`--rescan` / delete the incomplete gold before restart.

**Test:** kill after chunk 8 of 40. Does retry pick up remaining paths, or skip
them because gold mtime is newer than the unread files?

## 8. In-memory unique of a pinned snapshot

Iceberg load is already tip-dated (even `sink_parquet`'d), then the mapper
concats every batch and `unique(...)` on the whole snapshot in Polars.
Measured 2026-08-27: listings gold, `venue_unique` 11,051,981 rows at 14.8G RSS
sitting on MemoryHigh=14G, 20+ min with no `phase_end`. A **second unique after
the spill unique already returned** is the same leak (same day: DuckDB unique
17.8s, then Polars-unique'd the same 11M at 678% CPU / 14.8G with no log).
Skip re-unique when there is one part; otherwise spill-unique the concat. Peak
RSS must follow batch size, not snapshot row count.

**Test:** does peak RSS follow batch size, or snapshot row count? After a
spill-unique, is there a second in-memory unique of the same rows?

## 9. Unwindowed sidecar rebuild of a lifetime fact table

A daily labels job `scan_to_polars`s all of a lifetime fact table. Measured
2026-08-27: 24.6M rows, 20.2G RSS, `TimeoutStartSec` SIGTERM before Iceberg
write. Daily path is a lookback merge onto the last parquet; lifetime is
`--full`. Sidecar rebuild as a bounded pipeline: **data-api**. Job shape
(chunk + resume inside one unit start): **data-pipeline-operations**.

**Test:** does the daily sidecar rebuild's peak RSS and runtime grow with the
fact table, or with the lookback window?

## Rebuild lane (not a leak shape — a missing lane)

A full-rebuild trigger (schema change, resolver bump, backfill) belongs on its
**own lane**, separate from the regular incremental run, with checkpoints that
survive a retry. A rebuild whose retry logic wipes its own staging checkpoints
resets to record one on every crash and, on a large enough history, never
finishes — measured: 9 attempts over 19 hours, 0 successes, each retry
restarting a 602-day rebuild from day 1.

**Test:** does a crash mid-rebuild resume from a checkpoint, or restart from
record one?
