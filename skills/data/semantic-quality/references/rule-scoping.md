# Rule scoping — evidence, cohorts, trust ladders

> Loaded on demand from **data-semantic-quality**. How to scope semantic rules so they
> fire on the right population. No product-specific constants.

## Scope matches evidence

| Rule needs | Evaluation unit |
|---|---|
| Row-local physical invariant (negative amount) | Single row |
| Peer comparison (implausible vs similar entities) | Entity + defined cohort |
| Cross-source anchor (median from another feed) | Full multi-source pool for that entity |
| Global catalog constraint | Catalog join at entity grain |

**Wrong:** score each write chunk in isolation when the anchor lives in another chunk or source.  
**Right:** buffer touched entity keys; score with the full pool those keys need.

## Stratify, then fence

Define the dimensions that make two rows comparable **before** computing outliers or
anomaly scores. Typical strata (pick what the domain requires — names are generic):

- Entity identity key
- Variant / SKU / configuration axis
- Quality or grade band (if the product has one)
- Geography / currency / language market
- Time regime (optional: rolling window vs all history)

A fence over a mixed stratum flags legitimate multi-modal structure as junk.

**Test shape:** two real sub-populations with different levels; a correct rule leaves both
mostly clean and still catches cross-stratum absurdities when intentional.

## Relative vs absolute fences

| Fence type | Use when |
|---|---|
| **Absolute** | Global physical or legal invariant (negative price, grade outside [0, max], impossible date) |
| **Relative / cohort** | "Too cheap/expensive/frequent relative to peers" — distributions differ by entity |
| **Hybrid** | Absolute floor *and* cohort ratio (absolute alone misses expensive-entity junk) |

Prefer **ratios, percentiles, or robust z-scores within a cohort** over a single constant
when entity scales span orders of magnitude.

Document the cohort definition next to the rule (who is in the peer set; minimum peer n;
fallback when n is small — skip rule vs use wider cohort).

## Provenance trust ladder

Classification and identity use ordered evidence classes (customize labels in the domain repo):

```
STRONG   — structured source fields, verified state, multi-field identity
MEDIUM   — defaults from authoritative catalog when strong is absent
WEAK     — free text, search-lane stamps, single-token heuristics
CONFLICT — strong vs weak disagree → quarantine / manual path, do not auto-pick weak
```

**Rules:**

1. Evaluate strong before weak; never short-circuit on weak success.
2. On conflict, quarantine or lower confidence — do not let weak win by order of `if` branches.
3. Record which evidence class produced the decision (auditability).

## Confidence gates

When identity or class is inferred:

- Emit a numeric or ordinal confidence.
- Define a threshold below which rows are excluded from identity-assuming aggregates.
- Do not "partially include" low-confidence rows in primary metrics without an explicit product decision.

## Minimum peer size and cold entities

Relative rules need enough peers. Specify:

- `min_cohort_n` — below this, rule no-ops or falls back to absolute-only physical checks.
- Behavior for brand-new entities (no history): quarantine, wider cohort, or delay rule.

Silent no-op without metrics hides coverage gaps — count "rule skipped: thin cohort."

## Serving boundary

Rules **define** attributes at produce/publish. Serving **honors** them. Do not re-implement
cohort logic in the API except during a documented dual-read cutover.

See **data-api** for consumption-time contracts and publish-coupled projections.
