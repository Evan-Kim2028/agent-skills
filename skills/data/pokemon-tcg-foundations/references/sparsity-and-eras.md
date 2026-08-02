# Sparsity, cross-grade reconstruction, and era structure

Measured 2026-08-02 over periods pd 6–11 (2026-04-26 → 2026-07-19), resolved secondary sales on TCGplayer + eBay.

Three facts that interlock: **the tape is sparse**, **the sparsity is unevenly distributed across eras**, and **the fix for both is to reconstruct a card's price from every grade and condition it trades in rather than from raw NM alone.**

---

## 1. The catalogue is mostly empty

`card_rollup.parquet` lists **66,855 cards across 605 sets**. In a 12-week window, only **23,570 (35%) record a single resolved sale.** Roughly two thirds of the catalogue is unpriceable at any horizon.

It thins further with every requirement you add:

| Requirement | Cards |
|---|---|
| Catalogued | 66,855 |
| ≥1 resolved sale in 12 weeks | 23,570 |
| ≥30 sales in 12 weeks | 20,135 |
| SV/ME with ≥180 raw NM sales | 595 |

**Sparsity, not model class, is the binding constraint on this dataset.** Every design decision should be read as "does this buy me more observations per card-period?" — which is why the `grade_label` fix in `data-quality.md` §1 mattered so much, and why the reconstruction below matters more.

---

## 2. Era structure: vintage and mid-era barely trade raw

Era mapping used throughout (by `set_id` prefix):

| Era | Prefixes |
|---|---|
| `1_vintage_wotc` | base, gym, neo, si, ecard |
| `2_mid_ex_dp` | ex, pop, np, dp, pl, hgss, hsp, col |
| `3_bw_xy_sm` | bw, xy, g1, sm, det |
| `4_swsh` | swsh, cel, pgo |
| `5_sv_me` | sv, me |

`9_other` catches ~3k cards, mostly Japanese-set IDs (`SM8b`, `S1W`, `CP6`, `SV4a`) and One Piece promos (`OP-PR`) — a different market. Exclude it.

**Raw NM share of sales collapses as you go back:**

| Era | Sales | Cards | % raw (any cond) | **% raw NM** | % PSA | Median raw NM |
|---|---|---|---|---|---|---|
| 1 vintage (WotC) | 422,569 | 1,781 | 94.4% | **29.4%** | 3.7% | $6.62 |
| 2 mid (EX–DP–HGSS) | 384,146 | 3,867 | 95.2% | **30.3%** | 3.0% | $5.00 |
| 3 BW–XY–SM | 768,173 | 6,312 | 97.1% | 46.5% | 2.2% | $2.11 |
| 4 SWSH | 608,247 | 3,668 | 96.3% | 64.2% | 2.5% | $1.54 |
| 5 SV–ME | 1,126,883 | 4,946 | 94.8% | **64.8%** | 3.9% | $1.99 |

**Mid-era behaves like vintage, not like modern** — 30.3% vs 29.4% raw NM, against ~65% for SWSH/SV. Old cards mostly don't survive in near mint, so their tape is dominated by LP/MP/HP/DMG and by graded copies.

This shows up independently in the price ladder (§4): the LP discount and the PSA premium both cluster vintage with mid and separate them from modern. Three unrelated measurements, same grouping.

---

## 3. Panel fill rate — where the sparsity actually bites

Fraction of the 6 possible (card × period) cells that clear 8 sales, for cards with ≥30 sales in the window:

| Era | Cards | **Raw NM ≥8** | Any raw condition ≥8 | Gain |
|---|---|---|---|---|
| 1 vintage | 1,766 | 56.0% | 91.3% | 1.6× |
| **2 mid** | 3,691 | **22.3%** | **83.8%** | **3.8×** |
| 3 BW–XY–SM | 5,913 | 49.0% | 85.7% | 1.7× |
| 4 SWSH | 3,647 | 90.3% | 97.8% | 1.1× |
| 5 SV–ME | 4,466 | 91.2% | 94.6% | 1.0× |

**A raw-NM-only panel is simply not viable before SWSH.** Mid-era fills 22% of its cells — four times sparser than SV/ME, on cards that trade plenty overall. The volume is there; it is just not in NM.

Note vintage fills better than mid (56% vs 22%) despite an identical NM share, because vintage volume concentrates in far fewer cards: 237 sales/card against 99 for mid.

---

## 4. The price ladder is stable enough to invert

Median price of each leg relative to the same card's raw NM, cards with ≥6 sales per leg:

| Leg | Cards | Median × NM | p25 | p75 | IQ spread |
|---|---|---|---|---|---|
| raw LP | 19,388 | **0.831** | 0.667 | 1.000 | **1.50** |
| raw MP | 11,792 | **0.561** | 0.400 | 0.728 | 1.82 |
| raw HP/DMG | 7,797 | **0.368** | 0.253 | 0.494 | 1.95 |
| PSA 9 | 1,434 | 2.593 | 1.379 | 5.857 | 4.25 |
| CGC 9+ | 981 | 3.707 | 2.002 | 7.364 | 3.68 |
| PSA 10 | 1,508 | 9.184 | 4.752 | 16.586 | 3.49 |

**The split is sharp and it dictates method.** Condition legs are *tight* (IQ spread 1.5–1.95) — a global multiplier converts them to NM-equivalent with acceptable error. Graded legs are *loose* (3.5–4.25) — the PSA 10 premium varies far too much card-to-card for a single multiplier to be safe.

**So: pool conditions by conversion. Use grades as a separate signal, not as price observations.** That is consistent with the factor table — PSA 10 *movement* predicts raw movement at IC +0.230, which uses the graded leg for direction while never assuming a level.

### Per-era condition factors (divide by these to get NM-equivalent)

| Era | LP | MP | HP | DMG |
|---|---|---|---|---|
| 1 vintage | 0.766 | 0.537 | 0.346 | 0.292 |
| 2 mid | 0.728 | 0.500 | 0.327 | 0.299 |
| 3 BW–XY–SM | 0.782 | 0.536 | 0.375 | 0.340 |
| 4 SWSH | 0.895 | 0.727 | 0.507 | 0.453 |
| 5 SV–ME | 0.924 | 0.750 | 0.584 | 0.589 |

**Condition discounts steepen monotonically with age.** An LP modern card is worth 92% of NM; an LP mid-era card is worth 73%. Using one global factor across eras is a real error — roughly 20 points of price on the LP leg alone.

### Graded premium by era

| Era | PSA 9 × NM | PSA 10 × NM |
|---|---|---|
| 1 vintage | **7.53** | **68.8** |
| 2 mid | **7.72** | 26.4 |
| 3 BW–XY–SM | 2.81 | 9.65 |
| 4 SWSH | 1.54 | 6.34 |
| 5 SV–ME | 1.78 | 9.35 |

Vintage PSA 10s trade at **69× the raw NM price**. For vintage and mid, the graded market *is* the market and the raw price is a thin residual — which is the mechanical reason those eras have so few raw NM sales to begin with. Note again that mid and vintage agree on PSA 9 (7.72 vs 7.53) while modern sits near 1.5–1.8.

---

## 5. Reconstruction works: it is more reliable *and* wider

Split-half test. Sales are assigned to halves by `hash(sale_id) % 2`, each half's price estimated independently, and the two correlated across card-periods (Spearman-Brown corrected). Compared on **identical cells** where both methods are feasible, so this isolates precision, not coverage:

| Era | Cells | Reliability, NM only | **Reliability, condition-pooled** |
|---|---|---|---|
| 1 vintage | 4,837 | 0.960 | **0.980** |
| **2 mid** | 3,299 | **0.897** | **0.967** |
| 3 BW–XY–SM | 13,637 | 0.969 | 0.983 |
| 4 SWSH | 17,470 | 0.973 | 0.978 |
| 5 SV–ME | 23,323 | 0.977 | 0.983 |

Pooling wins in every era. In mid-era it cuts noise variance from 10.3% to 3.3% — a **68% reduction** — because that is where the discarded non-NM sales are most of the tape.

And it does not merely improve the cells you already had. On cells where **NM-only is infeasible** (≥8 raw sales but fewer than 4 NM in a half), the pooled estimate still achieves:

| Era | Extra cells unlocked | Reliability there |
|---|---|---|
| 1 vintage | 4,202 | 0.948 |
| **2 mid** | **14,285** | 0.948 |
| 3 BW–XY–SM | 15,961 | 0.978 |
| 4 SWSH | 3,564 | 0.980 |
| 5 SV–ME | 1,611 | 0.989 |

**Mid-era goes from 3,299 usable card-periods to 17,584 — 5.3× — while reliability rises.** That is the single largest expansion of usable panel available in this dataset, and it costs one join against a five-row factor table.

### Recipe

```sql
-- 1. Estimate factors once, per era, on card-level medians (not on the panel you will test).
CREATE OR REPLACE TABLE fac AS
SELECT a.era, a.leg, median(a.px/b.px) f
FROM cl a JOIN cl b ON a.tcg_card_id=b.tcg_card_id AND b.leg='raw_nm'
WHERE b.px>0 GROUP BY 1,2;;

-- 2. Convert every raw sale to an NM-equivalent price.
CREATE OR REPLACE TABLE eq AS
SELECT s.*, s.price_usd / nullif(f.f,0) AS eqpx
FROM s JOIN fac f USING (era, leg);;

-- 3. Build the panel on median(eqpx) instead of median(price_usd) over raw_nm only.
```

**Caveats.** The factors are medians over one 12-week window in one regime; re-estimate them on refresh. Estimate them on a different slice than the one you evaluate on, or you have leaked. Do not extend this to graded legs — their dispersion is roughly double, and `raw_unknown` must stay excluded regardless (it medians $9.90 against $5.99 for `raw_nm`).

These are **level** reliabilities. The 0.70 figure quoted elsewhere in this skill is for *momentum* — a difference of two levels, which amplifies noise. Better levels do propagate to better changes, but the momentum reliability has not been re-measured under pooling.
