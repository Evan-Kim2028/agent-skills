# Sparsity, era structure, and cross-grade reconstruction

Three facts that interlock on any long-lived card line: **the tape is sparse**, **the sparsity is unevenly distributed across print eras**, and **the fix for both is to reconstruct each card's price from every condition it trades in rather than from best-condition alone.**

The mechanism is physical, so it should transfer: older cards mostly did not survive in near-mint, and the ones that did were graded. Ref-impl numbers (measured 2026-08-02 over six 14-day periods) show the shape and magnitude to expect.

---

## 1. The catalogue is mostly empty

**Expect the majority of catalogued cards to have zero sales in any given quarter**, and expect the usable universe to thin further with every requirement you add.

> **Ref impl:**
>
> | Requirement | Cards |
> |---|---|
> | Catalogued | 66,855 |
> | ≥1 resolved sale in 12 weeks | 23,570 (35%) |
> | ≥30 sales in 12 weeks | 20,135 |
> | ≥180 best-condition raw sales (one era) | 595 |

**Sparsity, not model class, is the binding constraint.** Read every design decision as *"does this buy me more observations per card-period?"* That is why the encoding choice in `data-quality.md` §1 mattered so much, and why the reconstruction below matters more.

---

## 2. Rawness declines with print age

Group sets into eras. The exact boundaries are line-specific — use print/production regimes, not calendar years, since manufacturing and distribution changes are what drive the survival differences.

**What to expect: best-condition share of sales falls monotonically as you go back**, and the oldest two eras often collapse onto each other rather than continuing a smooth gradient.

> **Ref impl** (era mapping in [`reference-implementation.md`](reference-implementation.md)):
>
> | Era | Sales | Cards | % raw (any cond) | **% raw NM** | % PSA | Median raw NM |
> |---|---|---|---|---|---|---|
> | 1 vintage | 422,569 | 1,781 | 94.4% | **29.4%** | 3.7% | $6.62 |
> | 2 mid | 384,146 | 3,867 | 95.2% | **30.3%** | 3.0% | $5.00 |
> | 3 middle-modern | 768,173 | 6,312 | 97.1% | 46.5% | 2.2% | $2.11 |
> | 4 recent | 608,247 | 3,668 | 96.3% | 64.2% | 2.5% | $1.54 |
> | 5 newest | 1,126,883 | 4,946 | 94.8% | **64.8%** | 3.9% | $1.99 |
>
> **Mid-era behaves like vintage, not like modern** — 30.3% vs 29.4%, against ~65% for the two newest eras.

**Confirm any era grouping on more than one measurement.** The condition ladder and the graded premium (§4) are independent of sale-share, so if all three produce the same grouping, the eras are real and not an artifact of how you cut the sets.

> **Ref impl:** all three agree. Graded premium clusters vintage+mid (PSA 9 at 7.53× / 7.72× NM) against modern (1.54× / 1.78×); the played-condition discount does the same (LP at 0.766 / 0.728 vs 0.895 / 0.924).

---

## 3. Panel fill rate — where sparsity actually bites

The number that decides whether a panel is viable: **fraction of card×period cells that clear your minimum sale count.** Compute it per era, both best-condition-only and condition-pooled. The gap between the two columns is the value of reconstruction on your tape.

> **Ref impl** — cells clearing 8 sales, cards with ≥30 sales, 6 periods:
>
> | Era | Cards | **Raw NM ≥8** | Any raw condition ≥8 | Gain |
> |---|---|---|---|---|
> | 1 vintage | 1,766 | 56.0% | 91.3% | 1.6× |
> | **2 mid** | 3,691 | **22.3%** | **83.8%** | **3.8×** |
> | 3 middle-modern | 5,913 | 49.0% | 85.7% | 1.7× |
> | 4 recent | 3,647 | 90.3% | 97.8% | 1.1× |
> | 5 newest | 4,466 | 91.2% | 94.6% | 1.0× |
>
> **A best-condition-only panel is not viable before the two newest eras.** Mid-era fills a fifth of its cells on cards that trade plenty — the volume exists, it is just not in NM.

**Fill rate and condition share are different things.** A sparse era can still fill well if its volume concentrates in few cards.

> **Ref impl:** vintage fills 56% vs mid's 22% despite an identical NM share, because vintage volume concentrates — 237 sales/card against 99 for mid.

---

## 4. The price ladder — and the split that dictates method

Compute the median price of each condition and grade leg **relative to the same card's best-condition price**, plus the interquartile spread of that ratio. The spread is what decides whether a leg can be inverted.

> **Ref impl** — cards with ≥6 sales per leg:
>
> | Leg | Cards | Median × NM | p25 | p75 | IQ spread |
> |---|---|---|---|---|---|
> | raw LP | 19,388 | **0.831** | 0.667 | 1.000 | **1.50** |
> | raw MP | 11,792 | **0.561** | 0.400 | 0.728 | 1.82 |
> | raw HP/DMG | 7,797 | **0.368** | 0.253 | 0.494 | 1.95 |
> | PSA 9 | 1,434 | 2.593 | 1.379 | 5.857 | 4.25 |
> | CGC 9+ | 981 | 3.707 | 2.002 | 7.364 | 3.68 |
> | PSA 10 | 1,508 | 9.184 | 4.752 | 16.586 | 3.49 |

**The split is sharp and it dictates method.** Condition legs are *tight* — a multiplier converts them to best-condition-equivalent with acceptable error. Graded legs are *loose*, roughly double the dispersion — the graded premium varies far too much card-to-card for any single multiplier.

**So: pool conditions by conversion. Use grades as a directional signal, never as a price level.** That is consistent with the factor table, where a top-grade *move* predicts raw movement (IC +0.230) while never assuming a level.

### Factors are per-era, not global

**Condition discounts steepen monotonically with age.** A global factor is a real error, not a rounding one.

> **Ref impl** — divide by these to get NM-equivalent:
>
> | Era | LP | MP | HP | DMG |
> |---|---|---|---|---|
> | 1 vintage | 0.766 | 0.537 | 0.346 | 0.292 |
> | 2 mid | 0.728 | 0.500 | 0.327 | 0.299 |
> | 3 middle-modern | 0.782 | 0.536 | 0.375 | 0.340 |
> | 4 recent | 0.895 | 0.727 | 0.507 | 0.453 |
> | 5 newest | 0.924 | 0.750 | 0.584 | 0.589 |
>
> An LP modern card is worth 92% of NM; an LP mid-era card 73% — ~20 points on the LP leg alone.
>
> Graded premium by era: PSA 9 at 7.53× (vintage), 7.72× (mid), 2.81×, 1.54×, 1.78×; PSA 10 at **68.8×**, 26.4×, 9.65×, 6.34×, 9.35×. **For the oldest eras the graded market *is* the market** and the raw price is a thin residual — which is the mechanical reason those eras have so few raw sales to begin with.

---

## 5. Validate reconstruction with a split-half test

Do not take the coverage gain on faith — measure whether the pooled estimate is also *more precise*. Assign sales to halves by a hash of the sale key, estimate each half independently, correlate across card-periods, and apply Spearman-Brown (`2r/(1+r)`).

Run it **twice**:

1. **On identical cells** where both methods are feasible — this isolates precision, holding coverage fixed.
2. **On cells only pooling can fill** — this measures whether the extra coverage is trustworthy or just more rows.

> **Ref impl, test 1** (identical cells):
>
> | Era | Cells | Best-condition only | **Condition-pooled** |
> |---|---|---|---|
> | 1 vintage | 4,837 | 0.960 | **0.980** |
> | **2 mid** | 3,299 | **0.897** | **0.967** |
> | 3 middle-modern | 13,637 | 0.969 | 0.983 |
> | 4 recent | 17,470 | 0.973 | 0.978 |
> | 5 newest | 23,323 | 0.977 | 0.983 |
>
> Pooling wins in every era — in mid-era it cuts noise variance from 10.3% to 3.3%, a **68% reduction**, because that is where the discarded sales are most of the tape.
>
> **Test 2** (cells best-condition-only cannot fill):
>
> | Era | Extra cells unlocked | Reliability there |
> |---|---|---|
> | 1 vintage | 4,202 | 0.948 |
> | **2 mid** | **14,285** | 0.948 |
> | 3 middle-modern | 15,961 | 0.978 |
> | 4 recent | 3,564 | 0.980 |
> | 5 newest | 1,611 | 0.989 |
>
> **Mid-era goes 3,299 → 17,584 usable card-periods (5.3×) while reliability rises.** Not a coverage-for-precision trade — strictly better on both axes, for one join against a five-row factor table.

### Recipe

```sql
-- 1. Estimate factors once, per era, on card-level medians.
--    Use a slice DISJOINT from the one you evaluate on, or you have leaked.
CREATE OR REPLACE TABLE fac AS
SELECT a.era, a.leg, median(a.px/b.px) f
FROM cl a JOIN cl b ON a.card_id = b.card_id AND b.leg = '<best condition>'
WHERE b.px > 0 GROUP BY 1,2;

-- 2. Convert every raw sale to a best-condition-equivalent price.
CREATE OR REPLACE TABLE eq AS
SELECT s.*, s.price / nullif(f.f,0) AS eqpx
FROM sales s JOIN fac f USING (era, leg);

-- 3. Build the panel on median(eqpx) instead of median(price) over best-condition only.
```

**Caveats to carry forward:**

- Factors are medians over one window in one regime. **Re-estimate on every refresh.**
- **Estimate on a disjoint slice** from the one you evaluate.
- **Do not extend this to graded legs** (§4), and keep the "unknown condition" bucket excluded regardless.
- These are **level** reliabilities. Momentum is a difference of two levels, which amplifies noise — do not quote a level reliability as a momentum reliability. Better levels should propagate to better changes, but that has not been measured here.
