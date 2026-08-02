# Methodology: the traps

Every trap here has produced a wrong-but-plausible result on this dataset. Each has a cheap diagnostic. Run them.

---

## 1. The bounce trap (kills the best-looking factors)

**What happens.** A period's median price is a noisy estimator. If you build a signal from period *t*'s price statistics and measure the return from *t* to *t+1*, the same noise appears on both sides with opposite sign, manufacturing correlation out of nothing. Any statistic describing where the median sits *within* its own distribution is maximally exposed.

**Real example.** Tail shape `(p50−p10)/(p75−p10)` scored **IC −0.216** — the strongest single factor in the first pass. Under the skip test it collapsed to **−0.026**. It was entirely bid-ask bounce.

**The diagnostic — skip-a-period test.** Build the signal from period *t*. Measure the return from **t+1 → t+2**. No transaction is shared, so bounce cannot survive.

```sql
FROM cp c1
JOIN cp c0 ON c0.tcg_card_id=c1.tcg_card_id AND c0.pd=c1.pd-1   -- for the signal's own lag
JOIN cp c2 ON c2.tcg_card_id=c1.tcg_card_id AND c2.pd=c1.pd+1
JOIN cp c3 ON c3.tcg_card_id=c1.tcg_card_id AND c3.pd=c1.pd+2
-- signal from c1 (and c0); target = ln(c3.p50/c2.p50)
```

**Reason about the bias direction before trusting a survivor.** Noise in `tcg_t` enters `venuegap = ln(eb)−ln(tcg)` negatively *and* enters `ret_next` negatively, so bounce pushes their correlation **positive**. The observed venue-gap IC is **negative**, so bounce was working against the finding — it's conservative there. Do this arithmetic each time.

**Structural immunity.** Signals built from *disjoint transaction sets* cannot bounce. PSA 10 sales are different transactions from raw sales; LP sales are different from NM. Those factors (IC +0.230 and +0.152) are clean by construction.

---

## 2. Venue mix shift

**What happens.** Marketplace composition moves violently — TCGplayer 117k→443k monthly sales while eBay went 198k→137k (Jun→Jul 2026), and the two venues price differently. A pooled median across venues will show a large "move" that is 100% composition.

**The fix, always.** Log-return computed **within** each marketplace, then volume-weighted across:

```sql
CREATE OR REPLACE TABLE vm AS
SELECT *, ln(px1/px3) lm, least(n1,n3) wt
FROM mv WHERE n1>=5 AND n3>=6 AND px1>0 AND px3>0;;

CREATE OR REPLACE TABLE card AS
SELECT tcg_card_id, exp(sum(lm*wt)/sum(wt))-1 AS mom
FROM vm GROUP BY 1;;
```

**Confirm on both venues independently.** The two-set finding held at TCGplayer +33.9/+36.3 and eBay +28.1/+28.3. A result that appears on only one venue is a venue artifact until proven otherwise.

---

## 3. Composition drift (matched-model requirement)

**What happens.** Which cards trade in a given week changes. A set-level median over "whatever traded" drifts with the mix, not with price.

**The fix.** Repeat-sales / matched-model: week-over-week change for the **same card** in the **same venue**, aggregated by median.

```sql
CREATE OR REPLACE TABLE chg AS
SELECT a.tcg_card_id, a.wk,
  sum(ln(a.px/b.px)*least(a.n,b.n))/sum(least(a.n,b.n)) dlog
FROM cw a JOIN cw b
  ON a.tcg_card_id=b.tcg_card_id AND a.marketplace=b.marketplace AND a.wk=b.wk+1
WHERE a.px>0 AND b.px>0 GROUP BY 1,2;;
```

---

## 4. Sticky prices break weekly medians

**What happens.** TCGplayer prices are discrete and sticky. At weekly granularity **more than half of cards show exactly 0% week-over-week change**, so the median WoW is a degenerate statistic and reads as "stalled" when the market is moving.

This produced a false "the hot sets have stopped" conclusion that was caught only by cross-checking against monthly matched-model data.

**The fix.** Use **14-day or monthly** periods for level/trend work. If you must go weekly, report the mean of log changes or breadth, not the median. Always cross-check a weekly reading against a monthly one before reporting it.

---

## 5. Lookahead in outlier fences

**What happens.** Per-card Tukey fences computed over the full sample — including the forward window — leak future information into the trimming decision. This invalidated the first backtest run on this dataset.

**The fix.** Fences from **pre-formation data only**:

```sql
CREATE OR REPLACE TABLE fence AS
SELECT tcg_card_id, marketplace,
  quantile_cont(price_usd,0.25) f25, quantile_cont(price_usd,0.75) f75
FROM raw WHERE sold_at < DATE '2026-06-15'   -- formation date
GROUP BY 1,2;;
```

**Fence width depends on the question.** Use 1.5×IQR for level estimation. Use **3×IQR when the left tail is the signal** (p10 depletion, cheap-tail studies) — 1.5×IQR trims away the thing you're measuring.

---

## 6. Set beta masquerading as card selection

**What happens.** ~34% of forward variance is set-level. A factor that ranks cards well overall may be doing nothing but ranking their sets.

**Real example.** `set_momentum` scores total IC **0.491**, within-set IC **0.034**. It cannot choose between two cards in the same set — which is the only decision that matters when you're buying one card.

**The diagnostic — always report both.**

```sql
CREATE OR REPLACE TABLE ws AS
SELECT *, ret_next - avg(ret_next) OVER (PARTITION BY set_id, pd) resid,
  score  - avg(score)    OVER (PARTITION BY set_id, pd) dscore
FROM sc;;
SELECT round(corr(a,b),3) within_set_ic FROM (
 SELECT rank() OVER (ORDER BY resid) a, rank() OVER (ORDER BY dscore) b FROM ws);;
```

Benchmark: the validated composite scores **within-set IC 0.261**. Anything below ~0.10 is a set-beta proxy.

---

## 7. Measurement noise ceiling

Split each card's sales in half by timestamp parity and compute the factor independently on each half.

- Measured: **split-half r = 0.544 → Spearman-Brown reliability 0.70.**
- 30% of the variance in a momentum number is sampling noise in the median.
- Ceiling on correlation with *true* momentum: √0.70 ≈ 0.84.

Do not chase model classes to beat this. It is a measurement problem, and it is why more sales per bucket beats a fancier estimator.

The by-liquidity breakdown of this came out non-monotonic (0.97 / 0.68 / 0.40 / 0.96) — that's a confound (tiers have different true spread), not a finding. Don't lean on it.

---

## 8. Effective breadth, not row count

Cards within a set move together. A 2,584-row panel does **not** give you 2,584 independent bets. Grinold: `IR = IC × √breadth` — and breadth here is closer to the number of sets (~20) than the number of cards for any set-level factor.

This is exactly why the within-set IC matters: a factor with real within-set IC restores breadth to something near the card count.

---

## 9. Variant contamination

Multiple printings map to one `tcg_card_id`, producing a bimodal price distribution and a meaningless median.

**Now measured** (eBay titles, SV/ME raw): reverse holos are **7.7% of sales**; across 638 cards with ≥10 sales each way the reverse-vs-base median price ratio is **1.000** (p25 0.905, p75 1.137) — but **21.9% of cards differ by more than 30%**.

Read that carefully: contamination is *unbiased in aggregate and severe in the tail*. Pooling is fine for set-level work. For a single card's level estimate it is roughly 1-in-5 that you are averaging two materially different assets.

Japanese printings are a non-issue in this era — no SV/ME card reaches 10 Japanese-titled raw sales, despite 6.4% of all Pokémon eBay titles mentioning Japan.

**Gate:** interquartile dispersion `q75/q25 ≤ 1.7–1.8` over the trailing 30 days. Cards above that are contaminated; exclude them from level work.

Note the tension with trap #5: this gate is a *filter for level estimation*, not a signal, and it must not be applied when the distribution's shape is what you're studying.

Title mining is eBay-only — **`title` is NULL on 91.7% of TCGplayer rows.**

---

## 10. Horizon mixing

Card momentum is **negative at 14 days** (IC −0.027, skip +0.070) and **positive at 60 days** (IC +0.20). Short-horizon reversal, long-horizon continuation. These are different phenomena. Do not put both in one model without explicitly separating the horizons.

---

---

## 11. Reading a pipeline outage as a market event

**What happens.** Missing venue-days look exactly like collapsed demand. TCGplayer has 37 fully missing days (2026-03-03 → 2026-04-21) and 23 more below quarter-volume; the newest 14-day period is always under-ingested (eBay falls 66% in the final bar from lag alone).

Both were live hazards. Before the guard was added, the panel's early periods carried a "venue gap" computed from **48 TCGplayer sales against 48,836 eBay sales**.

**The diagnostic.** Count distinct days per venue per period, not just rows, and compare against the calendar:

```sql
CREATE OR REPLACE TABLE cal AS
SELECT unnest(generate_series(DATE '2026-02-16', DATE '2026-08-01', INTERVAL 1 DAY))::DATE d;;
SELECT count(*) missing FROM cal
WHERE d NOT IN (SELECT CAST(sold_at AS DATE) FROM sale WHERE marketplace='tcgplayer');;
```

**The fix.** `pd BETWEEN 6 AND 11` — baked into `scripts/panel.sql`. Re-derive both bounds whenever the data is refreshed; the upper bound moves every time.

---

## 12. Choosing the sparser of two equivalent columns

**What happens.** When two columns encode the same thing, the one with the friendlier name is not necessarily the populated one. `condition='NM'` and `grade_label='raw_nm'` agree on price to within 0.3%, but `grade_label` carries **2.36× more eBay rows**.

Against a measured reliability ceiling of 0.70 — 30% of momentum variance is sampling noise — a 2.4× sample increase beats every model-class change available.

**The diagnostic.** For any two candidate filters, check *both* count and price agreement before picking:

```sql
SELECT marketplace,
  count(*) FILTER (WHERE condition='NM') via_a,
  count(*) FILTER (WHERE grade_label='raw_nm') via_b,
  count(*) FILTER (WHERE condition='NM' AND grade_label='raw_nm') via_both
FROM e GROUP BY 1;;
-- then per card: median(px under A) / median(px under B) should be ~1.000
```

Agreement on price plus disagreement on count means one column is simply more complete. Take the complete one.

---

## Standing sample caveats

State these on any result from this dataset:

- ~6 months of usable history — and only **6 usable 14-day periods** (pd 6–11) for anything cross-venue, after the TCGplayer outage and the newest-period lag are excluded.
- **One regime** — an up-then-cooling episode. No observed drawdown.
- Backtests partly overlap the very episode they evaluate. Strip out `rsv10pt5`/`zsv10pt5` and the continuation evidence gets thin.
- Exogenous drivers (reprints, rotation, tournament meta, a popular video) are absent from every column and are a large share of what actually moves prices. That's an information problem, not a modeling one.

## Preferred model classes

Given effective breadth ~20 sets and one regime:

- **Hierarchical / partial-pooling Bayesian** — cards nested in rarity nested in set; honest about a card with 20 sales.
- **Panel regression with set fixed effects** — separates "this card is special" from "this set is moving."
- **Quantile regression** — predict the distribution, not a point.
- **Survival models on listings** — time-to-sale is a cleaner demand signal than price (blocked until `listings.parquet` is refreshed).

Not: LSTMs, transformers, or gradient boosting on a few hundred correlated rows. They will produce a beautiful backtest and lose money.
