# Attach / remap / backfill

> Loaded on demand from **data-identity-resolution**. Procedure only. Ladder
> semantics stay in **data-semantic-quality** `references/rule-scoping.md`.

## States

Every incoming row ends in exactly one identity state:

| State | Meaning | Enters identity-assuming aggregates? |
|---|---|---|
| **assigned** | Canonical key present, confidence ≥ gate, no open conflict | Yes |
| **unresolved** | No key, or confidence below gate | No |
| **quarantine** | Strong vs weak (or two strong) disagree | No |
| **collision** | Two or more assigned keys for one physical event (or one key on two events that must stay distinct) | No, until an ordered restamp picks a survivor |

Blank/null with no state column is not a state — add the column. Collision is not "run the matcher
again." It is a durable row (or pair) a later job can count.

## Incremental attach

1. Read a watermarked window of new records (not the full history).
2. Join strong structured identifiers first.
3. Fill from catalog defaults only where strong is absent.
4. Run weak text/heuristic only where both of the above are absent.
5. On any disagreement with a stronger class → quarantine, do not overwrite.
6. Write key + confidence + evidence class + policy version in the same publish as the row.
7. Advance the watermark only for rows that reached a terminal state (including unresolved and quarantine).

Anti-pattern: “best score wins” across classes of unequal strength.

## Remap / restamp

Use when the matcher or catalog changed and historical links may be stale.

Order of operations (required):

1. **Lock stronger fences.** Rows with strong evidence or quarantine are ineligible for weak rewrite.
2. **Select candidates** by policy version, evidence class, or explicit keyset — not “all rows.”
3. **Recompute** using the same incremental attach function (no second matcher).
4. **Write** only where the new evidence class is ≥ the stored class *and* does not conflict.
5. **Record** old key, new key, reason, policy version (audit).

A restamp that “just runs identify() again” will undo quarantines.

Restamp is **not** the incremental attach timer. Incremental attach reads a watermarked window of
*new* records. Restamp selects candidates by policy version / evidence class / explicit keyset and
runs on a catchup unit with chunk resume (**data-pipeline-operations**). Putting restamp on the
hourly identify path is hub leak 4 (entity lifetime reload) plus a second matcher.

## Historical backfill of unresolved

Separate lane from incremental attach (hub: rebuild ≠ incremental).

- Keyset or date-chunked; persist progress per chunk.
- Idempotent per chunk (same input → same keys).
- Does not rewrite assigned/quarantine rows unless the chunk is an explicit strong-evidence repair.
- Crash resume from last completed chunk.
- Emit unresolved-in / assigned-out / still-unresolved counts per chunk.

## Metric

Publish at least daily, per source:

- `landed_rows`
- `assigned`
- `unresolved`
- `quarantine`
- `collision` (if the product has twins / duplicate physical events)
- `unresolved_rate = unresolved / landed`

Page on rate *increase* sustained across more than one run, not on a single noisy chunk.

## Serving

Request paths may *display* stored confidence and quarantine. They may not parse
free text to invent a key the lake did not assign. Temporary dual-read during
cutover needs an explicit flag and a deletion date (**data-semantic-quality**
principle 3 / **data-api** honor attributes).
