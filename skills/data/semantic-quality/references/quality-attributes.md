# Quality attributes — write-time, single-sourced

> Loaded on demand from **data-semantic-quality**. Portable patterns only: how to
> persist and reconcile quality decisions. No product-specific thresholds.

## What a quality attribute is

A **quality attribute** is a field (or small set of fields) on a published fact that
records a quality decision for downstream consumers:

| Kind | Role |
|---|---|
| Boolean flag | Include/exclude from a named use (oracle, default chart, rollup) |
| Reason list | Which rules fired (machine-readable codes, not free prose only) |
| Confidence | Score for inferred identity or classification |
| Quarantine state | Explicit "do not use until reviewed" |

Attributes are **data**, not log lines. Consumers filter and join on them.

## Write-time, not read-time

| Approach | Result |
|---|---|
| Score only in API / rollup memory | Split-brain: lake looks clean; product looks dirty (or the reverse) |
| Persist at publish + trust stored | One truth; cheaper reads; audits possible |
| Dual-read cutover behind env flag | Allowed temporarily; delete the flag after backfill |

**Reconcile pattern (generic):**

1. Publish or upsert fact rows for a window.
2. Collect the set of **entity keys** touched (not only row ids in the chunk).
3. Load the full evidence pool needed for those entities (cross-source if rules need it).
4. Run the single score function; write attributes back (upsert/merge on fact key).
5. Emit success/failure metrics for the reconcile step.

Chunk-local scoring is wrong when the rule's anchor (median, peer set) lives outside the chunk.

## Single score path

```
writers ──► publish facts ──► reconcile/score (one module) ──► attributes on facts
                                      │
                    rollup / API / UI / exports all read attributes
```

A second writer that bypasses reconcile must either call the same score entrypoint or be
rejected by a runtime guard ("no unattributed appends to this table").

## Fail-soft vs fail-hard

| Mode | When |
|---|---|
| Fail-soft reconcile | Attribute refresh fails; facts landed; alert and retry. Accepts temporary stale flags. |
| Fail-hard publish | Contract requires attributes; missing columns or score crash blocks publish. |

Prefer fail-hard once the contract claims attributes exist. Fail-soft only with visible alerts.

## Golden packs and dual error budgets

**Domain owns** the pack contents (entity keys, expected attribute values). This pack
requires the **shape**:

1. **Known-bad** cases — must remain flagged/quarantined after score (bounds false negatives).
2. **Known-good** cases — must remain clean (bounds false positives).
3. Pack versioned with schema; reviewed date recorded.
4. CI or publish gate runs score over the pack and fails outside budgets.

Optimizing only false negatives recreates "flag everything." Both budgets are mandatory.

## Cutover checklist

```
- [ ] Attribute columns exist on the published table (operator schema action if needed)
- [ ] Score module is the only writer of those columns
- [ ] End-of-publish (or dedicated job) reconciles touched entities
- [ ] Readers default to trust-stored (no silent rescore)
- [ ] Pack green for FN and FP budgets
- [ ] Serving contract documents which endpoints honor which attributes
```

## Anti-patterns

- Logging "would have flagged" without persisting.
- Per-request rescoring as the long-term design.
- Reason strings only — no structured codes for dashboards.
- Pack that only contains known-bad (or only known-good).
