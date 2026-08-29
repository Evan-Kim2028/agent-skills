---
name: data-identity-resolution
description: >
  Portable workflow for attaching messy records to canonical entities —
  evidence ladder, fail-closed assignment, quarantine on strong-vs-weak
  conflict, unresolved-null accumulation as measured debt, remap/restamp that
  cannot undo a stronger fence, backfill of unresolved keys. Use when
  resolving titles, IDs, or marketplace text to an entity key, debugging
  growing NULL identity columns, or restamping historical links. Don't use
  for quality flags or outlier fences (data-semantic-quality), estimate
  scoring (data-product-eval), schema/publish mechanics (data-apache-lakehouse),
  or product-specific match thresholds (product repo). Prefer the data hub
  when the specialist isn't obvious.
---

# Data identity resolution — attach, don't guess

`data-semantic-quality` owns the **rules**: trust ladder, confidence as a gate,
cohort fences. This skill owns the **procedure** for linking a messy incoming
record to a canonical entity key without inventing a second identity system.

No product match thresholds, no catalog taxonomies. Those stay in the product repo.

## When to invoke

- Parsing free text / third-party ids onto a canonical entity key.
- NULL or unresolved identity keys growing day over day.
- Remapping / restamping historical links after a resolver change.
- Strong structured evidence disagrees with a weak title/heuristic.

## Don't use

| Task | Go here instead |
|---|---|
| Quality flags, outliers, golden *entity* packs | **data-semantic-quality** |
| Scoring published estimates vs later facts | **data-product-eval** |
| Schema, watermarks, publish/OCC | **data-apache-lakehouse** / **data** hub |
| Serving honors stored keys; does not re-resolve | **data-api** |
| “Should this table exist?” | **data-table-lifecycle** |
| Concrete matcher constants / synonym lists | **product-repo skill** |

## Non-negotiables

1. **No domain product nouns or concrete match thresholds** in advice from this skill.
2. **Ladder rules live in `data-semantic-quality`.** Do not fork a second ladder here.
3. **Unresolved is a first-class state**, not a blank to be filled by the next weak hint.
4. **Collision / twin is a first-class state**, not another matcher branch.
5. **Remap cannot undo a stronger fence.** Restamp is ordered and is not the incremental timer.
6. **Low confidence never enters identity-assuming aggregates.**

## Principles

Each has a falsifiable **Test:**. Ladder mechanics live in **data-semantic-quality**
(trust ladder + confidence gates). Workflow detail:
[`references/attach-workflow.md`](references/attach-workflow.md).

### 1. Evidence before assignment

Collect ordered evidence (strong structured → catalog default → weak text) *then*
decide assign / quarantine / leave unresolved. Do not assign inside the first
matching `if`.

**Test:** invent a row where weak text and a strong structured field disagree. Does the weak path still win if you reorder branches?

### 2. Fail closed

Below the product’s confidence threshold the key stays null/unresolved and the
row is excluded from identity-assuming rollups. “Average it in at a discount”
is not fail-closed.

**Test:** can a below-threshold row appear in the primary aggregate without an explicit override flag?

### 3. Conflict quarantines

Strong-vs-weak mismatch is a quarantine (or a conflict label), not a coin flip.
Record which evidence class produced the decision.

**Test:** is there a durable conflict/quarantine state a later job can count, or does the row silently pick a side?

### 4. Collision is a state, not a second pass of identify()

Two assigned keys for one physical event (or one key stamped on two events that must stay
distinct) is **collision**. Persist it. Count it. An ordered restamp may pick a survivor; the
incremental matcher must not "fold" the twin away to make the rollup look unique.

**Test:** inject a duplicate physical event with two structured ids. Does a collision row (or pair)
survive publish, or does the next identify() pick a winner with no audit?

### 5. Unresolved accumulation is a metric

NULL / unresolved keys are measured debt: count per source per day, with a
rate (unresolved / landed). A resolver that “works” while the null pile grows
is losing.

**Test:** can you plot unresolved-landed per source for the last N days from published tables, without reading code? If the rate is up and no one is paging, the metric is missing.

### 6. Remap is ordered and one-way through stronger fences

A restamp / re-resolve pass applies weaker evidence only where stronger evidence
is absent. It must not clear a strong assignment or a quarantine to please a
new heuristic.

**Test:** run restamp on a fixture that has a strong key *and* a tempting weak hint the other way. Does the strong key survive?

Restamp is a **separate resumable lane** from incremental attach (principle 7). It does not ride the
hourly identify timer. Residual rows after a restamp are a keyset for the next catchup start, not a
reason to widen the incremental window to lifetime.

### 7. Backfill is a bounded, resumable lane

Unresolved backfill is not the incremental attach path. It has its own watermark
or keyset, chunk size, and idempotent write. Hub principle 2 (watermark, not
full recompute) applies — a crash must not restart the whole historical pile.

**Test:** kill a backfill at 40%. Does retry resume, or re-scan from record one and rewrite already-good keys?

### 8. One writer for the link

The attach job (or documented reconcile) is the only writer of the canonical
key + confidence + evidence class. APIs, UIs, and rollups consume. A serving
path that “fixes” identity at request time is a second resolver.

**Test:** change the attach threshold in one place. Do all consumers move on the next publish, or does one surface still re-parse text?

### 9. Coverage audit names identity rate

When someone asks “how much data do we have,” unresolved rate is part of the
answer — row count alone lies. The **data** hub coverage-audit playbook includes
this slice; this skill defines what “resolved” means (key present *and* above
gate).

**Test:** a source with 1M rows and 85% null keys — does the audit report “1M rows” or “150k resolved”?

## Workflow: attach or remap

```
Identity attach / remap:
- [ ] 1. Name the canonical key + what “unresolved” looks like on the row
- [ ] 2. List evidence classes in ladder order (product repo supplies the actual signals)
- [ ] 3. Assign only from the strongest available non-conflicting class
- [ ] 4. Conflict → quarantine; collision → collision state; below threshold → unresolved (not a guess)
- [ ] 5. Persist key, confidence, evidence class, policy version
- [ ] 6. Incremental path is watermarked; historical remap / restamp is a separate resumable lane
- [ ] 7. Restamp fixture: strong assignment survives a contradictory weak hint; twins are not folded on the timer
- [ ] 8. Publish unresolved-rate *and* collision-rate per source
- [ ] 9. Serving / rollups honor stored keys — no request-time re-parse
- [ ] 10. No domain thresholds committed into this pack
```

## Common mistakes

- First matching heuristic writes the key.
- Weak title/lane stamp overrides a structured identifier because it ran first.
- NULL keys treated as “not a problem until someone searches that row.”
- Restamp job that reapplies the full matcher and clears quarantines.
- Restamp / residual chase on the incremental timer (O(history), no collision state).
- Historical remap on the incremental timer (O(history), no resume).
- Folding twins in identify() so the rollup looks unique.
- API re-parses free text because “the lake key looks wrong.”
- Quoting source volume without the resolved rate.

## References

- **Attach / remap / backfill procedure:** [`references/attach-workflow.md`](references/attach-workflow.md)
- Trust ladder + confidence-as-gate → **data-semantic-quality** (`references/rule-scoping.md`)
- Estimate vs later truth → **data-product-eval**
- Coverage audit (query prod, include identity rate) → **data** hub
- Serving consumes stored keys → **data-api**
- Incremental vs rebuild lanes → **data** hub principle 2
