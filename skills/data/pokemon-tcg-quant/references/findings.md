# Findings log

Dated results. Append; don't rewrite history. Mark superseded claims rather than deleting them — the record of what was wrong is part of the value.

---

## 2026-08-02 — Anchor / error-correction model

Universe: SV+ME sets, `trade_type='secondary'`, 14-day periods, `n>=4` per card-venue-period, Feb–Aug 2026. 7,091 card-periods.

**TCGplayer is exogenous; eBay error-corrects toward it.**

| | corr with `gap_t` | correction β |
|---|---|---|
| eBay next move | −0.384 | −0.223 |
| TCGplayer next move | −0.002 | −0.001 |

`gap = ln(eBay_median / TCG_median)`. Pooled `ρ = 0.778` per 14 days.
Mean gap **+0.16 logs (eBay ~17% richer on average)** — demean per card before using.

**By price band** (the anchor migrates to eBay with liquidity):

| Band | eBay vol share | β_ebay | β_tcg | TCG share of correction | ρ | half-life |
|---|---|---|---|---|---|---|
| <$10 | 75.2% | −0.282 | 0.013 | 4% | 0.705 | 28 d |
| $10–25 | 79.0% | −0.308 | 0.046 | 13% | 0.646 | 22 d |
| $25–50 | 79.8% | −0.215 | 0.050 | 19% | 0.735 | 32 d |
| $50–100 | 84.2% | −0.158 | 0.061 | 28% | 0.782 | 40 d |
| $100–250 | 86.7% | −0.478 | 0.154 | 24% | 0.367 | 10 d |
| $250+ | 91.4% | −0.390 | 0.234 | 38% | 0.376 | 10 d |

Confirms the practitioner claim that eBay is the better reference for $50–100+ chase cards: volume share reaches 91% and TCGplayer starts following. It never fully flips — eBay remains the larger corrector even at $250+.

**Gap size → forward move (pooled):**

| gap at t | n | TCG px | eBay next | TCG next | $ per card |
|---|---|---|---|---|---|
| eBay >30% cheap | 79 | $17.47 | +4.2% | −8.5% | +$1.77 |
| eBay 18–30% cheap | 298 | $23.93 | +6.1% | −1.4% | +$1.80 |
| eBay 8–18% cheap | 947 | $32.53 | +4.0% | −0.2% | +$1.35 |
| aligned | 2,087 | $55.82 | +1.0% | 0.0% | +$0.21 |
| eBay rich | 3,680 | $17.47 | −4.1% | −1.2% | −$0.68 |

**Cross-venue lead-lag (change→change) is near zero** — `ebay_hk→ebay` 0.083, `ebay→tcgplayer` 0.035, `tcgplayer→ebay` 0.021. Neither anchor leads the other in *changes*; the tradeable structure is error-correction on the *level* gap, not lead-lag on returns.

---

## 2026-08-02 — Microstructure factor panel

24,340 card-periods, 4,571 cards, 13 biweekly periods. Rank IC, skip-tested where possible.

| Factor | IC (t+1) | IC (skip) | Verdict |
|---|---|---|---|
| Venue gap | −0.267 | −0.247 | Real |
| Volume growth | +0.117 | +0.147 | Real, strengthens |
| PSA 10 → raw (n=429) | +0.230 | — | Real (disjoint txns) |
| LP/NM ratio change (n=1,600) | +0.152 | — | Real (disjoint txns) |
| LP/NM ratio level | +0.111 | — | Real |
| p10 rise | +0.103 | +0.063 | Partly real |
| Price momentum (14d) | −0.027 | +0.070 | Noise |
| Tail shape | −0.216 | −0.026 | **Artifact** |

Own-momentum on the PSA subset scores **+0.029** where PSA-leads-raw scores **+0.230** — the graded market is ~8× more informative about raw's next move than raw's own price history.

Collinearity: `corr(p10_rank, momentum_rank)=0.42`, `corr(p75, momentum)=0.685`, `corr(volume, momentum)=−0.021`. Volume is essentially orthogonal to momentum.

**Composite** (equal-weight percentile ranks of venue gap + volume growth + p10 change; no fitting):

- IC 0.287 (t+1), **0.185 (skip)**, **within-set 0.261**
- Per-period IC positive in all 8 periods with meaningful n: 0.148, 0.201, 0.231, 0.317, 0.324, 0.584, plus two small-n early periods
- Time split: train (pd≤8) 0.184, holdout (pd>8) 0.413

Decile sort, forward 14 days:

| Decile | Fwd % | Fwd $ | % ≥$2 |
|---|---|---|---|
| 1 | −37.8% | −$0.99 | 1.9% |
| 5 | −0.3% | +$0.31 | 9.7% |
| 9 | +4.9% | +$1.49 | 21.3% |
| 10 | +5.0% | +$2.02 | 29.5% |

Monotone. **The short side is far stronger than the long side** — primary use is as an avoid-list.

Top decile by price band: <$5 $0.18 · $5–10 $0.37 · $10–20 $1.27 (25% hit $2+) · **$20–50 $2.22 (43%)** · $50+ $3.37 (29%).

**Retrospective test on the Black Bolt / White Flare episode.** The composite ranked `rsv10pt5` and `zsv10pt5` #1 and #2 from period 8 onward and every deeply-negative set went on to lose 20–65% (`sv9` −38%, `me2pt5` −65%, `sv10` −50%, `sv3pt5` −36%). The episode was callable from data that was available the whole time.

---

## 2026-08-02 — Set-level regime state (rare+ only, px ≥ $1, matched-model, venue-neutral)

| Set | n | Median px | Apr | May | Jul | Breadth | Accel |
|---|---|---|---|---|---|---|---|
| rsv10pt5 (White Flare) | 58 | $16.99 | +13.0 | +12.2 | +7.0 | 83% | −5.2 |
| zsv10pt5 (Black Bolt) | 79 | $16.12 | +11.1 | +12.6 | +4.7 | 76% | −8.0 |
| sv6pt5 | 12 | $18.31 | +6.0 | +2.1 | +0.9 | 58% | −1.2 |
| **sv8** | 20 | $10.00 | +6.0 | +0.3 | +1.9 | 55% | **+1.7** |
| sv7 | 15 | $6.86 | +4.4 | +5.6 | 0.0 | 47% | −5.6 |
| sv5 | 30 | $11.36 | +9.2 | +7.0 | 0.0 | 47% | −7.0 |
| sv1 | 18 | $8.10 | +5.7 | +2.0 | 0.0 | 44% | −2.1 |
| sv6 | 25 | $11.50 | +4.8 | 0.0 | 0.0 | 44% | 0.0 |
| sv4 | 37 | $10.74 | +10.0 | +5.2 | 0.0 | 43% | −5.2 |
| sv2 | 43 | $15.00 | +9.1 | +3.9 | 0.0 | 37% | −3.9 |
| sv4pt5 | 70 | $5.99 | +8.2 | −0.3 | −2.2 | 37% | −1.9 |
| sv3 | 14 | $7.85 | +10.2 | −0.1 | −0.1 | 36% | 0.0 |
| sv8pt5 | 33 | $29.99 | +2.8 | 0.0 | 0.0 | 33% | 0.0 |
| sv10 | 15 | $11.99 | −1.6 | 0.0 | −1.8 | 20% | −1.8 |
| sv3pt5 (151) | 18 | $19.50 | +1.2 | −0.1 | −3.1 | 11% | −3.0 |
| me2pt5 | 24 | $61.23 | +0.7 | −3.0 | −6.6 | 4% | −3.6 |

**14 of 16 sets had negative acceleration** — a broad cooling, not a rotation. `sv8` (Surging Sparks) was the only set accelerating (+1.7), on n=20, which is weak evidence.

Regime thresholds (fitted to one cooling episode — re-estimate):

| Regime | Condition |
|---|---|
| Trending | T > +3% and breadth > 65% |
| Cooling | T > 0 and accel < −3 |
| Neutral | breadth 40–60%, \|T\| < 2% |
| Declining | breadth < 35% or T < −2% |

**Set trend is strongly persistent month-to-month (0.76).** This is a trend-following market at the set level.

**Breadth is coincident, not leading.** Predicting next-month set return: breadth 0.737, price 0.761, concurrent breadth-vs-return 0.887. 32 overlapping observations across 16 sets — the level is inflated, the ranking is the point. Do not build an early-warning indicator on breadth.

---

## Superseded / retracted claims

- **"Cheap laggards will mean-revert toward their set."** Retracted 2026-08-02. Backtest gave `corr(trailing, forward) = +0.20` — continuation, not reversion. Under $10, laggards and leaders both returned ~+7% with no spread.
- **"PSA data is missing."** Wrong. `pop_psa.parquet` is empty, so PSA *population* is missing; PSA *prices* are 1.08M transactions and are among the strongest signals available.
- **"~6% R² is the ceiling for prediction here."** Misleading framing. That ceiling applies to *card-level price-history-only* momentum. Set-level trend persistence is 0.76 (R² ≈ 58%), and the microstructure composite reaches within-set IC 0.261. Leading with R² was the wrong frame; IC and breadth are the right ones (IC 0.20 is already 4–10× industry-standard for equity factors).
- **"eBay clears below TCGplayer."** True for the 11 specific IRs examined; false as a general statement. Universe mean gap is +0.16 logs — eBay runs ~17% *richer*. Always demean per card.
- **"Tail shape is the strongest factor" (IC −0.216).** Killed by the skip test (−0.026). Bid-ask bounce.
- **"Momentum-leader selection beats value within a set."** Partially retracted. Within-set, `rel_price_vs_peer` scores IC 0.130 vs momentum gap 0.046 — value is the better within-set selector, which vindicated the original "underrated vs cohort" framing over the momentum-leader pivot.
- **A weekly-median index reading showed the hot sets stalling in weeks 14–17.** Artifact of sticky TCGplayer prices (>50% of cards show exactly 0% WoW). Corrected to "decelerating, not stalled" against monthly matched-model data.
