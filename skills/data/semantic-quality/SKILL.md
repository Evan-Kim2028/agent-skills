---
name: data-semantic-quality
description: >
  Portable methodology for semantic (row-truth) data quality in pipelines —
  write-time quality attributes, single-sourced scoring, entity-scoped rule
  evaluation, provenance trust ladders, cohort-relative fences, golden entity
  packs with dual error budgets, and layered enforcement. Use when designing
  or debugging quality flags, outlier or anomaly rules, entity-resolution
  confidence gates, classification trust ladders, producer–consumer quality
  contracts, split-brain between stored flags and API/UI filters, or golden
  pack regression for correctness. Don't use for schema/type/null-fraction
  fences alone (data hub / data-apache-lakehouse), multi-pipeline memory
  admission or OOM (data-pipeline-operations), table retirement
  (data-table-lifecycle), DuckDB engine tuning (data-duckdb), or domain-specific
  business thresholds and product rule books (keep those in the product repo's
  own skills — not this pack).
---

# Semantic data quality — row truth, not just schema

The **data** hub fences structure (types, nulls, atomic publish). This skill is the
discipline for **semantic** correctness: is this row the right real-world entity with
attributes fit for the consumer? It is methodology only — no product thresholds, no
marketplace or catalog rule books. Domain rule encyclopedias stay in the product repo.

## When to invoke this skill

- Designing quality flags, outlier/anomaly rules, or include-in-downstream predicates.
- Fixing split-brain: lake/table says clean, API or UI re-scores differently.
- Entity resolution or classification where weak signals must not override strong ones.
- Adding a golden pack (known-good / known-bad entities) with precision and recall budgets.
- Writing a producer–consumer contract that includes quality expectations, not only schema.
- Choosing whether a fence is absolute (global physical invariant) or cohort-relative.

## Don't use

| Task | Go here instead |
|---|---|
| Schema, types, null fractions, required columns | **data** hub / **data-apache-lakehouse** |
| Watermarks, O(history) rebuilds, bounded memory | **data** hub |
| Multi-pipeline admission, MemoryMax, timer stacking | **data-pipeline-operations** |
| Drop/deprecate tables, maintenance coverage lists | **data-table-lifecycle** |
| Rate limits, pushdown, pagination, cache keys | **data-api** (honors attributes; does not invent rules) |
| Concrete domain thresholds or product-specific junk taxonomies | **product-repo skill**, not this pack |

## Non-negotiables

1. **No domain product nouns or concrete business thresholds** in advice generated from this skill. Patterns only (cohort fence, trust ladder, quality attribute). Thresholds and product taxonomies live in the domain repo.
2. **Quality attributes are write-time and single-sourced.** Read sites trust stored state; they do not re-derive a parallel truth.
3. **Rule evaluation scope matches evidence scope.** If anchors span partitions or sources, score at entity (or declared cohort) scope — not an arbitrary write chunk.
4. **Golden packs require dual error budgets:** known-bad must stay bad (false-negative budget); known-good must stay good (false-positive budget).
5. **Enforcement is layered** (hub principle 8): runtime guard > CI pack > checklist > review convention.

## Principles

Each principle has a falsifiable **Test:**. If the test fails, the principle is violated.

### 1. Separate mechanical validation from semantic validation

Mechanical: columns, types, null fractions, required keys. Semantic: right entity, right
attributes for the stated consumer use. Dimensions (accuracy, completeness, consistency,
uniqueness, validity, timeliness, usefulness) **label** what you measure; they are not a
test suite by themselves.

**Test:** can you name which checks are mechanical vs semantic for this table, and which
skill owns each? If everything is filed under "data quality" with no split, the fence is muddled.

### 2. Quality attributes are first-class, write-time fields

Persist flags, reason lists, confidence, or include-in-X predicates on the fact table (or a
documentedly coupled sidecar of attributes). Emit them in the same publish path that lands
rows. Details: [`references/quality-attributes.md`](references/quality-attributes.md).

**Test:** after publish, does a cold reader (new process, no in-memory scorer) see the same
quality decision as the write path? If only the API rescores in memory, attributes are not first-class.

### 3. Single score path — no multi-reader re-derivation

One function (or job) owns scoring/reconcile for a given attribute set. Rollup builders, APIs,
and UIs consume the result. Temporary dual-read during cutover is allowed only behind an
explicit env/flag with a deletion date.

**Test:** change one rule threshold in one place. Do all consumers move together on the next
publish, or does one site still use old logic?

### 4. Group or stratify before fencing

Anomaly and outlier rules run **after** grouping by the dimensions that define a fair cohort
(entity, variant, grade band, region, …). Fencing a mixed cohort produces false positives.

**Test:** take two legitimate sub-populations with different price/volume levels. Does a
single global fence flag one of them incorrectly? If yes, stratification is missing.

### 5. Prefer cohort-relative fences over absolute constants when distributions vary

Absolute floors/caps are fine for global physical impossibilities (negative price, impossible
range). For "implausible relative to peers," use ratios or percentiles of a defined cohort.
Details: [`references/rule-scoping.md`](references/rule-scoping.md).

**Test:** does the same absolute constant pass junk on expensive entities and thrash cheap
ones? If yes, the fence should be relative (or dual: absolute floor *and* cohort ratio).

### 6. Provenance trust ladder for classification

Every classification dimension (identity, category, state) uses ordered evidence: stronger
sources override weaker ones; strong-vs-weak mismatch **quarantines** rather than guessing.
Weak signals never win by running first.

**Test:** invent a row where weak evidence and strong evidence disagree. Is the row quarantined
or soft-failed, or does the weak path still win?

### 7. Confidence is a gate when identity is inferred

Inferred entity links carry a confidence score. Below threshold, the row does not enter
downstream aggregates that assume identity — not "average in with a discount."

**Test:** can low-confidence rows appear in the primary rollup or oracle path without an
explicit override flag? If yes, confidence is decoration, not a gate.

### 8. Contracts include meaning and quality expectations

Producer–consumer agreements cover schema **and** what fields mean, which quality attributes
exist, and what consumers may assume (e.g. "filtered rows are excluded from default charts").
Schema-only contracts leave semantic drift free.

**Test:** if a new quality attribute is added, does any contract artifact or OpenAPI/docs path
require updating, or can consumers only discover it by reading source?

### 9. Golden packs are domain-owned; this skill requires they exist for rule changes

The pack contents (entity ids, expected flags) live in the product repo. The portable
requirement: any rule change ships with positive and negative cases and dual error budgets.

**Test:** delete the pack or empty the known-bad set. Does CI or publish still go green for a
rule change? If yes, there is no real pack gate.

### 10. Serving must not invent a second quality truth

APIs and UIs **honor** persisted attributes (filter, degrade, label). Temporary client-side
tripwires are incident mitigations, not the system of record. Serving contracts and
publish-coupled projections: **data-api**.

**Test:** turn off all client-side junk filters. Do default product views still exclude
write-time-flagged rows? If the chart fills with known-bad pack members, serving is the firewall.

## Workflow: add or change a quality rule

Copy and check off:

```
Quality rule change:
- [ ] 1. Name consumer use + quality dimension (accuracy / consistency / …)
- [ ] 2. Choose layer: produce | publish | serve (serve only honors; does not define)
- [ ] 3. Define quality attribute(s) + single writer/reconcile path
- [ ] 4. Define evidence scope (entity keys, cohort, anchors)
- [ ] 5. Stratify dimensions listed before any fence
- [ ] 6. Prefer relative fence unless absolute physical invariant
- [ ] 7. Add golden pack cases: ≥1 known-good, ≥1 known-bad
- [ ] 8. Wire runtime or CI enforcement (hub layered enforcement)
- [ ] 9. Update serving contract if consumers filter on the attribute
- [ ] 10. No domain thresholds committed into this portable skill pack
```

## Common mistakes

- Absolute floor as the only junk detector on multi-scale entities.
- Per-chunk scoring when medians/anchors need the full entity pool.
- Read-time-only flags (API/rollup rescore; lake stays clean).
- Weak title/lane signal winning over structured strong evidence.
- Treating dimensions dashboards as a substitute for executable checks.
- Frontend tripwires as the permanent quality system.
- Copying product-repo rule books into this pack.

## References

- **Write-time quality attributes, single score path, packs:** [`references/quality-attributes.md`](references/quality-attributes.md)
- **Rule scope, stratification, trust ladder, relative fences:** [`references/rule-scoping.md`](references/rule-scoping.md)
- Shared pipeline principles → **data** hub
- Serving honor attributes + publish-coupled sidecars → **data-api**
- WAP / branch validation for risky publishes → **data-apache-lakehouse**
