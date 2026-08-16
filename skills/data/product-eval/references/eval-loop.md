# Eval loop mechanics

> Loaded on demand from **data-product-eval**. Portable patterns only. No product
> thresholds.

## Freeze

An eval run is a triple:

1. **Estimate snapshot** — the published numbers under test (id, value, status, as-of, policy version).
2. **Fact snapshot** — the realized observations used as truth (id, value, event time, eligibility already decided by the *same* policy module).
3. **Run metadata** — policy version, freeze time, fit window, forecast horizon, strata keys.

Store run-level aggregates *and* enough per-stratum rows to re-open a regression.
Re-running the same triple must reproduce.

Anti-pattern: eval job that `SELECT`s current live tables with `now()`.

## Walk-forward

```
for origin T in scheduled origins:
    fit      = score(estimate@T, facts with event_time ≤ T)
    forecast = score(estimate@T, facts with T < event_time ≤ T+k)
```

Do not train/tune on the forecast window of the same origin. If you refit a
band or a blend, the origin that produced the fit is burned for that claim.

## Strata

Report at least:

| Slice | Why |
|---|---|
| Honesty status | Thin/stale/wide/ok mix at different error |
| Cohort / configuration axis | Multi-modal products hide inside a global median |
| Volume / density band | Sparse slots dominate count, dense slots dominate money |
| Age of estimate | Stale marks look accurate until you split on age |

A release gate may use a *core* subset of strata. The report still prints the rest.

## Two gates

| Gate | Question | Typical fail |
|---|---|---|
| **Coverage** | Of slots we claim to serve, what fraction have a number *and* a status? | Empty core-tier slots |
| **Accuracy** | Of slots that have a number, is error inside the dual budget? | Unlabeled fill, one huge miss on a known-good value |

Never average them into one “health” score.

## Dual budgets on values

| Pack member | Budget |
|---|---|
| Known-bad value (must not print, or must stay outside a band) | False-negative max (usually 0 on core) |
| Known-good value (must stay near a pinned number) | False-positive max (usually 0 on core) |

Pack contents live in the product repo. This skill only requires that they exist
and that emptying them fails the gate.

## Calibration (optional, still portable)

If you publish a band, also score *coverage of the band* (how often the later
fact lands inside) separately from point error. A tight band with 10% hit rate
is miscalibrated even if the point is close.

## Observe vs gate

| Mode | Allowed to fail closed? | Use |
|---|---|---|
| Observe-only | No — write history, alert humans | Nightly research, new policy shadow |
| Release gate | Yes — block promote / customer-facing flip | Core-tier packs, coverage floor |

A shadow that never promotes is observe-only. Label it that way in the run metadata.
