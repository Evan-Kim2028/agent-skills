---
name: data-product-eval
description: >
  Portable methodology for evaluating published estimates, marks, or forecasts
  against later realized outcomes — frozen snapshots, walk-forward fit vs
  forecast, coverage floors vs error, dual budgets on values, calibration,
  observe-only vs release gates, same policy code in eval and production.
  Use when scoring an oracle/mark/estimate, preparing a data product for
  release, building a canary or truth panel, or when an issue closed but the
  live error/coverage metric did not move. Don't use for row-flag golden packs
  (data-semantic-quality), code TDD (quality-check / tdd), schema/publish
  mechanics (data-apache-lakehouse), or domain thresholds (product repo).
  Prefer the data hub when the specialist isn't obvious.
---

# Data product eval — estimates vs later truth

`data-semantic-quality` asks “is this *row* the right entity with the right flags?”
This skill asks “is this *published number* honest against what later happened?”
Code tests (`quality-check` / `tdd`) do not answer that.

No product thresholds, no marketplace rule books. Those stay in the product repo.

## When to invoke

- Scoring a published estimate / mark / forecast / fill against later realized facts.
- Preparing a data-product surface for release (coverage vs error, honesty labels).
- Adding a canary, shadow pack, or truth panel that must share policy with prod.
- An issue or PR closed but the live error / coverage / calibration metric did not move.

## Don't use

| Task | Go here instead |
|---|---|
| Quality flags, trust ladders, entity golden packs | **data-semantic-quality** |
| Attaching messy records to entity keys | **data-identity-resolution** |
| Schema, watermarks, Iceberg publish | **data-apache-lakehouse** / **data** hub |
| Serving honors attributes; keyset/sidecars | **data-api** |
| Code TDD, browser proof, merge checklist | **quality-check** |
| Domain constants (bands, floors, venue weights) | **product-repo skill** |

## Non-negotiables

1. **No domain product nouns or concrete business thresholds** in advice from this skill.
2. **Eval and production run the same policy function.** A second scorer is a second truth.
3. **Snapshots are frozen.** Scoring a moving publish against a moving fact table is not an eval.
4. **Coverage and error are different gates.** Raising coverage by filling junk is a fail.
5. **Observe-only is allowed; calling it a release gate is not.**

## Principles

Each has a falsifiable **Test:**.

### 1. One policy path

The function that decides “eligible / excluded / estimate / thin” in production is the
function the eval imports. Shadow copies drift within a week.

**Test:** change one eligibility rule. Does tonight’s eval and tonight’s publish move together, or only one?

### 2. Freeze both sides of the comparison

Pin the estimate snapshot *and* the realized-fact snapshot (or a temporal as-of). Do not
score “whatever is live now” against “whatever sold since.”

**Test:** re-run yesterday’s eval job. Are the inputs byte-identical to yesterday’s freeze? If numbers wiggle with no code change, the freeze is missing.

### 3. Separate fit from forecast

- **Fit:** estimate published at T vs facts already known at T (did we describe the past).
- **Forecast:** estimate at T vs facts in (T, T+k] (did we predict).

Mixing them hides stale-but-pretty marks.

**Test:** can you name the fit window and the forecast window, and are they computed as two series?

### 4. Stratify before you quote a single error

Global MAPE/median-abs-log is a vanity number. Slice by the dimensions that change
the distribution (status, cohort, volume band, age, venue, language — whatever the
product actually serves). Details: [`references/eval-loop.md`](references/eval-loop.md).

**Test:** can a thin, stale, or wide slice look “fine” inside the global number? If yes, the report is not stratified.

### 5. Coverage floor ≠ accuracy gate

A coverage gate asks “what fraction of served slots have a number.” An accuracy gate
asks “of slots that have a number, how wrong is it.” Filling empty slots with
unlabeled guesses raises coverage and poisons accuracy.

**Test:** if you force 100% coverage with a naive fill, does the accuracy gate go red? If both stay green, you have one gate pretending to be two.

### 6. Dual budgets on *values*, not only flags

Entity packs (`data-semantic-quality`) guard known-good / known-bad *rows*.
Estimate eval also needs known-good / known-bad *values* (this slot should stay
near X; this slot must not print a number). Dual budgets: false-negative on
known-bad, false-positive on known-good.

**Test:** delete the known-bad value cases. Does the release path still go green?

### 7. Honesty labels travel with the number

A served estimate that can be thin, stale, wide, or ambiguous must carry that
status into eval. Scoring only the happy `ok` slice hides the product.

**Test:** turn off status filtering in the report. Do thin/stale/wide slots still appear, labeled, or did they vanish from the denominator?

### 8. Observe-only vs release gate is explicit

Nightly accuracy can be report-only. A release / promote / “ready for customers”
path names the gate (coverage floor, pack budgets, calibration band) and fails
closed. Do not say “we eval” when you only write a parquet nobody reads.

**Test:** break a core-tier pack case. Does anything block promote/release, or only a log line?

### 9. Merge is not the metric

Closing a ticket or merging a policy PR is not evidence the live error or
coverage number moved. **quality-check** owns the closeout ritual; this skill
owns *which* number to measure.

**Test:** after “done,” can you show before/after on the named eval metric from the frozen path? If you only have CI green, you did not eval.

## Workflow: add or change an eval

```
Estimate eval change:
- [ ] 1. Name the consumer question (fit vs forecast; which slots)
- [ ] 2. Point eval at the production policy module (no fork)
- [ ] 3. Freeze estimate snapshot + fact snapshot (or as-of)
- [ ] 4. Define strata; refuse a global-only report
- [ ] 5. Split coverage gate from accuracy gate
- [ ] 6. Add ≥1 known-good value and ≥1 known-bad value (dual budgets)
- [ ] 7. Carry honesty labels into the score rows
- [ ] 8. Mark the run observe-only or release-gate (never both silently)
- [ ] 9. After ship: before/after on the named live metric
- [ ] 10. No domain thresholds committed into this pack
```

## Common mistakes

- A second “eval scorer” that almost-copies production eligibility.
- Scoring live tables with no freeze (non-reproducible “wins”).
- Quoting one error number across mixed statuses and cohorts.
- Raising coverage by unlabeled fill, then celebrating accuracy on the remaining clean slice.
- Golden *entity* packs only — no known-bad *values*.
- Calling a report-only job a release gate.
- Claiming done from a merged PR without a moved metric.

## References

- **Loop mechanics (freeze, walk-forward, strata, gates):** [`references/eval-loop.md`](references/eval-loop.md)
- Row flags / entity packs → **data-semantic-quality**
- Identity attach / remap → **data-identity-resolution**
- Serving honors labels; does not rescore → **data-api**
- Merge ≠ metric → **quality-check** (metric-gated closeout)
- Shared pipeline principles → **data** hub
