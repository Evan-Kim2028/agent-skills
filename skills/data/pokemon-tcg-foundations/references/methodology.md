# Methodology: the traps

Every trap here produces a **wrong-but-plausible** result on a card sales tape — a number that looks like a finding and survives casual scrutiny. Each has a cheap diagnostic. Run them.

Examples marked *Ref impl* are from the reference implementation, where each of these actually fired.

---

## 1. The bounce trap (kills the best-looking factors)

**What happens.** A period's median price is a noisy estimator. Build a signal from period *t*'s price statistics, measure the return from *t* to *t+1*, and the same noise appears on both sides with opposite sign — manufacturing correlation out of nothing.

**Maximum exposure:** any statistic describing where the median sits *within* its own distribution. These are exactly the statistics that look most sophisticated.

**The diagnostic — skip-a-period test.** Build the signal from *t*. Measure the return from **t+1 → t+2**. No transaction is shared, so bounce cannot survive.

```sql
FROM cp c1
JOIN cp c0 ON c0.card_id=c1.card_id AND c0.pd=c1.pd-1   -- the signal's own lag
JOIN cp c2 ON c2.card_id=c1.card_id AND c2.pd=c1.pd+1
JOIN cp c3 ON c3.card_id=c1.card_id AND c3.pd=c1.pd+2
-- signal from c1 (and c0); target = ln(c3.p50/c2.p50)
```

**Reason about the bias direction before trusting a survivor.** Work out how estimation noise enters both the signal and the target, and which way it pushes their correlation. If bounce pushes *against* your observed sign, it is working conservatively and the finding is safer than it looks.

**Structural immunity — this is the important part.** Signals built from *disjoint transaction sets* cannot bounce. Graded sales are different transactions from raw sales; played-condition sales are different from best-condition. **Prefer cross-leg and cross-venue signals over within-leg price statistics**, and you sidestep the whole class.

> **Ref impl.** Tail shape `(p50−p10)/(p75−p10)` scored **IC −0.216** — the strongest single factor in the first pass. Under the skip test it collapsed to **−0.026**. Entirely bounce.
>
> Direction check on the survivor: noise in the anchor price enters `venuegap = ln(follower)−ln(anchor)` negatively *and* enters `ret_next` negatively, so bounce pushes their correlation **positive**. The observed venue-gap IC is **negative** — bounce was working against it.
>
> The two structurally immune factors scored +0.230 and +0.152, clean by construction.

---

## 2. Venue mix shift

**What happens.** Venue composition moves violently as pipelines add, lose and backfill sources — and venues price differently (`data-quality.md` §7). A pooled median across venues shows a large "move" that is 100% composition.

**The fix, always.** Log-return computed **within** each venue, then volume-weighted across:

```sql
CREATE OR REPLACE TABLE vm AS
SELECT *, ln(px1/px3) lm, least(n1,n3) wt
FROM mv WHERE n1>=5 AND n3>=6 AND px1>0 AND px3>0;

CREATE OR REPLACE TABLE card AS
SELECT card_id, exp(sum(lm*wt)/sum(wt))-1 AS mom
FROM vm GROUP BY 1;
```

**Confirm every result on both venues independently.** A result that appears on only one venue is a venue artifact until proven otherwise.

> **Ref impl:** TCGplayer went 117k→443k monthly sales while eBay went 198k→137k in a single month. The two-set finding held on both venues independently (+33.9/+36.3 and +28.1/+28.3), which is why it was believable.

---

## 3. Composition drift (matched-model requirement)

**What happens.** Which cards trade in a given period changes. A set-level median over "whatever traded" drifts with the mix, not with price.

**The fix.** Repeat-sales / matched-model: period-over-period change for the **same card** in the **same venue**, then aggregate.

```sql
CREATE OR REPLACE TABLE chg AS
SELECT a.card_id, a.wk,
  sum(ln(a.px/b.px)*least(a.n,b.n))/sum(least(a.n,b.n)) dlog
FROM cw a JOIN cw b
  ON a.card_id=b.card_id AND a.venue=b.venue AND a.wk=b.wk+1
WHERE a.px>0 AND b.px>0 GROUP BY 1,2;
```

---

## 4. Sticky prices break short-window medians

**What happens.** Marketplace prices are discrete and sticky, and ask-driven venues quantize to a small set of price points (`data-quality.md` §7). At weekly granularity a large share of cards show **exactly 0% change**, so the median is a degenerate statistic — it reads "stalled" while the market moves.

**The fix.** Use **14-day or monthly** periods for level and trend work. If you must go weekly, report the *mean* of log changes or breadth, never the median. **Always cross-check a weekly reading against a monthly one before reporting it.**

> **Ref impl:** >50% of cards showed exactly 0% week-over-week. This produced a false "the hot sets have stopped" conclusion, caught only by the monthly cross-check.

---

## 5. Lookahead in outlier fences

**What happens.** Per-card Tukey fences computed over the full sample — including the forward window — leak future information into the trimming decision.

**The fix.** Fences from **pre-formation data only**:

```sql
CREATE OR REPLACE TABLE fence AS
SELECT card_id, venue,
  quantile_cont(price,0.25) f25, quantile_cont(price,0.75) f75
FROM raw WHERE sale_date < <formation date>
GROUP BY 1,2;
```

**Fence width depends on the question.** 1.5×IQR for level estimation. **3×IQR when the left tail is the signal** (cheap-tail depletion studies) — 1.5×IQR trims away the thing you are measuring.

> **Ref impl:** full-sample fences invalidated the first backtest run.

---

## 6. Set beta masquerading as card selection

**What happens.** A large share of forward variance is set-level. A factor that ranks cards well overall may be doing nothing but ranking their sets — and cannot choose between two cards in the same set, which is the only decision that matters when buying one card.

**The diagnostic — always report both total and within-set IC.**

```sql
CREATE OR REPLACE TABLE ws AS
SELECT *, ret_next - avg(ret_next) OVER (PARTITION BY set_id, pd) resid,
          score    - avg(score)    OVER (PARTITION BY set_id, pd) dscore
FROM sc;
SELECT round(corr(a,b),3) within_set_ic FROM (
  SELECT rank() OVER (ORDER BY resid) a, rank() OVER (ORDER BY dscore) b FROM ws);
```

**Anything with near-zero within-set IC is a set-beta proxy**, however good its headline number.

> **Ref impl:** ~34% of forward variance was set-level. `set_momentum` scored total IC **0.491**, within-set **0.034**. The validated composite scored within-set **0.225**. Below ~0.10 is a proxy.

---

## 7. Measurement noise ceiling

**Establish this before choosing a model class.** Split each card-period's sales in half (hash the sale key — parity of timestamp is not random), compute independently on each half, correlate, and apply Spearman-Brown `2r/(1+r)`.

The result bounds everything downstream: at reliability *R*, a fraction `1−R` of your measured variance is sampling noise, and your correlation with the *true* quantity cannot exceed √*R*.

**Do not chase model classes to beat this.** It is a measurement problem, which is why more sales per bucket beats a fancier estimator — and why the reconstruction in `sparsity-and-eras.md` is worth more than any modeling change.

**Compute it separately for levels and for changes.** Momentum is a difference of two noisy levels and is meaningfully less reliable than either. Never quote one as the other.

> **Ref impl:** momentum split-half r = 0.544 → **reliability 0.70**; ceiling √0.70 ≈ 0.84. Level reliabilities are much higher (0.90–0.98, see `sparsity-and-eras.md` §5).
>
> A by-liquidity breakdown came out non-monotonic (0.97 / 0.68 / 0.40 / 0.96) — that is a confound (tiers have different true spread), not a finding. Don't lean on it.

---

## 8. Effective breadth, not row count

Cards within a set move together. **A panel of N rows does not give you N independent bets.**

Grinold: `IR = IC × √breadth`. For any set-level factor, breadth is closer to the **number of sets** than the number of cards — often one or two orders of magnitude less than the row count suggests.

This is exactly why within-set IC matters: a factor with real within-set IC restores breadth toward the card count.

---

## 9. Variant contamination

Multiple printings under one identity produce a bimodal distribution and a meaningless median. **Measure it** (`data-quality.md` §10) rather than assuming either way.

**Gate for level work:** interquartile dispersion `q75/q25 ≤ ~1.7–1.8` over a trailing window.

**Note the tension with trap 5:** this gate is a *filter for level estimation*, not a signal, and it must not be applied when the distribution's shape is what you are studying.

---

## 10. Horizon mixing

Short-horizon and long-horizon momentum are **different phenomena** and frequently have opposite signs — reversal at short horizons from bid-ask bounce and mean reversion, continuation at long horizons from genuine trend. Do not put both in one model without explicitly separating the horizons.

> **Ref impl:** card momentum was −0.027 at 14 days (skip +0.070) and **+0.20 at 60 days**.

---

## 11. Reading a coverage gap as a market event

**What happens.** Missing venue-days look exactly like collapsed demand. So does ingest lag on the newest bar. So does a silent writer regression (`data-quality.md` §2).

**All three are the same failure mode: a pipeline artifact wearing a market narrative.** When volume drops, exhaust the plumbing explanations before reaching for a market one — and do not stop at the first plumbing explanation you find, since they coexist.

**The diagnostic.** Count distinct days per venue per period against the calendar:

```sql
CREATE OR REPLACE TABLE cal AS
SELECT unnest(generate_series(<start>, <end>, INTERVAL 1 DAY))::DATE d;
SELECT count(*) missing FROM cal
WHERE d NOT IN (SELECT sale_date FROM sales WHERE venue = '<venue>');
```

**The fix.** Explicit period bounds in the panel builder. **Re-derive them on every refresh** — the upper bound moves every time.

> **Ref impl:** before the guard, the panel's early periods carried a venue gap computed from **48 sales against 48,836.** And the newest period's 66% volume drop had *two* causes — lag plus the `cardindex` regression — where only the first was initially diagnosed.

---

## 12. Choosing the sparser of two equivalent columns

**What happens.** When two columns encode the same thing, the better-named one is not necessarily the populated one. Against a reliability ceiling of ~0.70, a 2× sample increase beats every model-class change available.

**The diagnostic** is in `data-quality.md` §1: check *both* count and price agreement before picking. Agreement on price plus disagreement on count means one column is simply more complete.

---

## Standing sample caveats

State the equivalents of these on any result from a card tape:

- **How many *usable* periods**, not how many months of calendar history. Coverage bounds and ingest lag usually cut it to far fewer than the span suggests.
- **How many regimes.** One regime is the normal state of these datasets and the binding limitation on every coefficient. A model fit in an up-market with no observed drawdown has not been tested.
- **Backtest overlap.** If your evaluation window overlaps the episode that motivated the research, say so, and check what survives with the standout cohorts removed.
- **Exogenous drivers are absent from every column** — reprints, rotation, tournament meta, a popular video. They are a large share of what actually moves prices. That is an information problem, not a modeling one, and no model class fixes it.

> **Ref impl:** ~6 months of calendar history but only **6 usable 14-day periods**; one up-then-cooling episode with no drawdown; strip the two standout sets and the continuation evidence gets thin.

## Preferred model classes

Given effective breadth in the tens and typically one regime:

- **Hierarchical / partial-pooling Bayesian** — cards nested in rarity nested in set; honest about a card with 20 sales.
- **Panel regression with set fixed effects** — separates "this card is special" from "this set is moving."
- **Quantile regression** — predict the distribution, not a point.
- **Survival models on listings** — time-to-sale is a cleaner demand signal than price, where ask-side data exists and is fresh.

**Not** LSTMs, transformers, or gradient boosting on a few hundred correlated rows. They will produce a beautiful backtest and lose money.
