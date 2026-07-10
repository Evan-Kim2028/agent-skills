---
name: data-table-lifecycle
description: Use when deciding whether a table or artifact should keep existing, planning a table drop or deprecation, auditing a lakehouse for dead/zero-consumer tables, or building maintenance-job coverage across many tables. Covers the consumers-or-deprecate discipline (every table names a reader or gets flagged for removal), the drop-durability trap (a get_or_create-style helper silently resurrecting a "dropped" table on its next write), the metadata-vs-physical split of a drop (catalog drop_table does not delete files), and generating maintenance coverage from the catalog instead of a hand-maintained list. Don't use for choosing a storage format or catalog backend, or schema evolution within a live table — that's data-apache-lakehouse. This skill is about whether a table should exist at all, and how to retire it safely once it shouldn't. Prefer the data hub when the right data skill is unclear or the task spans ingest→store→serve.

---

# Table lifecycle — consumers-or-deprecate discipline

Tables accumulate. Every lakehouse grows tables nobody's using because deleting one *feels* riskier
than leaving it — until the unused ones are 25% of disk and nobody remembers why. This skill is the
discipline that keeps that from happening: name a consumer or flag for removal, and retire safely
when a table has none. It's the artifact-lifecycle expression of the **data** hub's principles, not a
replacement for them.

> Verified 2026-07-02 on a 110-table production lakehouse during a stabilization engagement.

## When to invoke this skill

- Before adding a new table, view, or derived artifact to a pipeline.
- Auditing a lakehouse to find tables nobody reads.
- Planning to drop, rename, or deprecate an existing table.
- Building or reviewing the list of tables a maintenance job (compaction, expiry) covers.
- A nightly job errors with "table does not exist" and nobody's sure if that's expected.

## Principles

Each is paired with a falsifiable test — if you can't pass it, the principle is violated, not
"applied differently."

### Every artifact names its consumer

A table exists because something reads it. State the consumer when the table is created, and re-prove
it periodically — not by checking the obvious downstream job, but by an adversarial sweep across
*every* consumer: sibling applications, not just the pipeline that wrote it; and traffic logs (reverse
proxy / API access logs mapping endpoint → table), not just code that imports the table name. A
110-table lakehouse audit that swept only the pipeline code missed 44 tables (~100GB, 25% of disk)
with zero consumers — they were only found by also grepping sibling apps and mapping nginx traffic
logs to table names.

**Test:** run the adversarial sweep — grep every consumer *and* check traffic logs for this table's
endpoints. Does anything read it? If the sweep across all of that finds nothing, deprecate; "the
pipeline that writes it" reading its own output doesn't count as a consumer.

### Drops are durable only after writers stop (the resurrection trap)

Dropping a table from the catalog is not the end of the story if anything downstream still writes to
it. A `get_or_create_table`-style helper — common in lakestore client code, meant to make writes
convenient — will silently recreate a dropped table the next time it runs, because from its point of
view "the table doesn't exist yet" and "I should create it" look identical. A drop is only durable
once every writer has actually stopped calling that path; verified as a live near-miss in production.

**Test:** after dropping, does anything in the codebase still call `get_or_create_table` (or
equivalent) against this table's name on any schedule? If yes, the drop isn't durable — it's a table
that will reappear on its own.

### A drop is metadata-only; physical cleanup is a separate, owned step

`catalog.drop_table` (e.g. PyIceberg's `SqlCatalog`) removes the catalog pointer. It does not delete
the underlying data files — the physical prefix still sits on storage, still costing money, still
readable by anything with a direct path. Physical cleanup is a distinct, owned step, not an assumed
side effect of the drop. The safe sequence:

1. **Gate/stop writers** — confirm no writer path still targets this table (see the resurrection trap above).
2. **Drop** — remove the catalog entry.
3. **Record the physical prefix** — write down exactly what storage path the dropped table occupied, before anyone forgets.
4. **Physical prefix cleanup** — a separate, deliberately-run step that deletes the recorded prefix.
5. **Vacuum** — reclaim the underlying object-store space (see `data-pipeline-operations` for tombstone/vacuum economics).

**Test:** after `drop_table` returns, does the storage bill go down? If no, the drop was metadata-only
and step 4 hasn't happened yet — that's expected, but it needs to be a tracked, owned task, not a gap
nobody notices.

### Maintenance coverage is generated, never hand-listed

A hand-maintained list of "tables this maintenance job covers" rots the moment a table is renamed,
added, or dropped and the list isn't updated in lockstep. Measured failure: 6 of 16 hand-listed table
names had gone stale, causing a nightly maintenance job to silently fail with "table does not exist"
for each — nobody noticed because the job kept "succeeding" on the other 10. Generate the coverage
list from the catalog at run time, minus an explicit exclusion file for tables deliberately skipped
(e.g. still under validation on a branch).

**Test:** rename or drop a table without touching the maintenance job's config. Does the job's
coverage list update itself on the next run, or does it silently skip/error on the stale name? If the
list needed manual editing to stay correct, it's a hand-list, and it will rot.

### The dead-write smell

A build stage whose outputs are majority zero-consumer is a symptom that shows up before the "44
zero-consumer tables" audit finding above — catch it earlier. Measured case: an analytics stage built
4 artifacts per tick; the unbounded full-history read feeding them accounted for ~85% of a 6.69GiB
peak, while most of what it produced had no reader at all. "Every artifact names its consumer" applied
at design time would have caught this years before the audit did.

**Test:** for a build stage producing multiple outputs, what fraction of them have a named consumer
*before* the stage ships? If most don't, the stage is doing (and paying for) dead work — cut it at
design time, not at the next lakehouse audit.

## References

- Physical cleanup and vacuum economics for the object store underneath the catalog (tombstone
  thresholds, `garbageThreshold` tuning) → **data-pipeline-operations**, SeaweedFS coexistence notes.
- `drop_table` semantics, catalog pointer mechanics → **data-apache-lakehouse**.
- Shared cross-cutting principles (idempotency, watermarks, bounded memory) → **data** hub.
