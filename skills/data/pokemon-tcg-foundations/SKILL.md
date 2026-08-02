---
name: data-pokemon-tcg-foundations
description: Use when working with the Pokémon TCG sales lakehouse (silphcoanalytics / lake-of-rage gold tables on lor-main) — reading or writing any query against card_sales_history / card_rollup, card price prediction, momentum and value factor construction, set-level regime detection, cross-venue basis and anchor-follower models, buy/sell signal design, or backtesting card selection. Encodes the dataset's real shape and defects (two competing condition encodings, a 7-week TCGplayer outage, lot-price contamination, FX-converted venues, venues that aren't secondary markets), the era structure and severe panel sparsity in pre-SWSH sets, the cross-grade/condition price reconstruction that fixes it, plus measured results (venue error-correction coefficients, factor ICs, anchor-by-price-band). Don't use for TCG game strategy/deckbuilding, general lakehouse engineering (that's data-apache-lakehouse), generic DuckDB syntax (data-duckdb), or non-Pokémon collectibles.
---

# Pokémon TCG Lakehouse — Foundations

Everything needed to query this dataset correctly and to know what has already been measured on it. Read this before writing the first query; most of the obvious analyses here are wrong in ways that look right.

> **Verified 2026-08-02** against `~/data/pokemontcg_pipe/gold/` on `lor-main`, DuckDB 1.5.3.
> Structural facts (which venue anchors, where the defects are) age slowly. Magnitudes were measured over Feb–Aug 2026 in **a single up-then-cooling regime** and should be re-measured.

## What this dataset is

**Not a price series.** It is a 9.4M-row transaction tape in which the same card trades simultaneously in several observable markets — TCGplayer raw, eBay raw, PSA 10, raw LP — and those markets do not move at the same time. Nearly all the exploitable signal lives in the *relationships between* those markets, not in the price history of any one of them. Card-level price momentum is close to worthless at 14 days; the cross-venue basis is the strongest single factor measured.

The practical consequence: work at **card × venue × 14-day-period** granularity. Collapsing to monthly medians throws away ~99.9% of the information and leaves ~20 effective observations.

## Shape of the tape

| | |
|---|---|
| Pokémon rows | 9,439,263 (`sale_id` unique — no dedup needed) |
| Usable venues | **`tcgplayer`, `ebay`, `ebay_hk`** — everything else is 0% identity-resolved |
| Joinable history | **2026 onward.** eBay rows exist back to 2009 but are <1% resolved before 2025 |
| Identity resolution | TCGplayer 91.7% · eBay 43.9% · ebay_hk 75.6% · all others 0% |
| Usable panel periods | **pd 6–11** (2026-04-26 → 2026-07-19) for anything cross-venue |
| Realistic card universe | ~595 SV/ME cards with ≥180 raw NM sales |

`ebay_hk` is a **separate price regime** (~3× lower, 99.7% FX-converted). Exclude from US-market work.

## The canonical filter

Start every query from this. Each clause is load-bearing; the reasons are in [`references/data-quality.md`](references/data-quality.md).

```sql
WHERE game = 'pokemon'
  AND price_usd > 0
  AND id_confidence IN ('high','title_verified')   -- mandatory; else unmapped
  AND trade_type = 'secondary'                     -- excludes primary/buyback/burn/internal/transfer
  AND marketplace IN ('tcgplayer','ebay')          -- ebay_hk is a different regime
  AND grade_label = 'raw_nm'                       -- NOT condition='NM'  (see rule 1)
  AND CAST(sold_at AS DATE) >= DATE '2026-02-01'
-- then: keep pd BETWEEN 6 AND 11
```

## Seven things that will burn you

**1. Use `grade_label`, not `condition`.** Two condition encodings exist. `grade_label='raw_nm'` returns **2.36× more eBay rows** than `condition='NM'` (443k vs 187k on SV/ME) at a **median price ratio of 1.000**. Since ~30% of measured momentum is sampling noise, this is the single largest free improvement available. Never fold in `raw_unknown` — it medians $9.90 against $5.99 for `raw_nm`.

**2. TCGplayer is missing 37 days (2026-03-03 → 2026-04-21).** At pd 5 it contributes 48 sales against eBay's 48,836. **No cross-venue factor exists before pd 6.** eBay has zero missing days.

**3. Drop the newest period, always.** eBay volume falls 66% in the final period from ingest lag alone. A signal built on the last bar reads the lag as a demand collapse.

**4. Most "venues" are not secondary markets.** renaiss is 98.8% primary/buyback; courtyard is mostly burn/transfer; beezie has **zero** secondary sales. Genuine secondary volume across all unresolved venues is ~148k rows, not the ~900k their raw counts suggest.

**5. Lot sales stamp the lot price on every card.** In 4–10-card transactions, 86% share one identical `price_usd` — median $48/row against $5.73 for real single-card sales. Confined today to the excluded venues, but it goes live the moment any of them is resolved. Guard with `count(*) OVER (PARTITION BY tx_id) = 1`.

**6. Never compare venues unconditionally.** SV/ME raw NM medians: TCGplayer **$0.19**, eBay **$10.00**. That 50× gap is pure mix — TCGplayer is 64% sub-$1 bulk, eBay clusters on `.99` ask points. Only compare per card with ≥4 sales on both sides.

**7. Skip-a-period test every new signal.** Build it from *t*, measure the return *t+1 → t+2*. Sharing transactions between signal and target manufactures correlation from median noise. This killed the best-looking factor found so far (tail shape: IC −0.216 → −0.026).

## Sparsity is the binding constraint — reconstruct across conditions

**Two thirds of the catalogue never trades.** 66,855 cards are listed; only 23,570 record a resolved sale in a 12-week window. Every method question here reduces to "does this buy me more observations per card-period?"

**And rawness collapses with age.** Raw NM share of sales: SV/ME 64.8% · SWSH 64.2% · BW–XY–SM 46.5% · **mid-era (EX–DP–HGSS) 30.3% · vintage (WotC) 29.4%.** Mid-era behaves like vintage, not like modern — old cards mostly don't survive in NM, so their tape is LP/MP/HP and graded copies. The same grouping appears independently in the PSA 9 premium (vintage 7.5× / mid 7.7× vs modern 1.5–1.8×) and the LP discount (0.766 / 0.728 vs 0.895 / 0.924).

The panel consequence, fill rate of card×period cells at ≥8 sales:

| Era | Raw NM only | Condition-pooled |
|---|---|---|
| vintage | 56.0% | 91.3% |
| **mid** | **22.3%** | **83.8%** |
| BW–XY–SM | 49.0% | 85.7% |
| SWSH | 90.3% | 97.8% |
| SV–ME | 91.2% | 94.6% |

**A raw-NM-only panel is not viable before SWSH.** The fix is to convert every raw condition to an NM-equivalent price using a per-era factor (LP/MP/HP/DMG), then pool. Split-half reliability *rises* in every era (mid 0.897 → 0.967) while mid-era usable cells go **3,299 → 17,584 (5.3×)**.

Condition legs invert cleanly (IQ spread 1.5–1.95). **Graded legs do not** (3.5–4.25) — use PSA/CGC as a directional signal, never as a price level. Factor tables and the recipe: [`references/sparsity-and-eras.md`](references/sparsity-and-eras.md).

## Two more rules for aggregation

- **Compute returns within a venue, then volume-weight across.** Marketplace mix moves violently (TCGplayer 117k→443k monthly while eBay 198k→137k). Pooled medians fabricate large moves that are pure composition.
- **Report within-set IC, not just total IC.** ~34% of forward variance is set-level. A factor at total IC 0.49 / within-set 0.034 is a set-beta proxy that cannot choose between two cards in the same set — which is the only decision that matters when buying one card.

## The anchor model (central finding)

TCGplayer is the **price anchor**; eBay is a **follower that error-corrects toward it**. With `gap = ln(eBay_median / TCG_median)`:

| | Correlation with gap | Correction coefficient |
|---|---|---|
| eBay's next move | **−0.384** | **−0.223** |
| TCGplayer's next move | −0.002 | −0.001 |

TCGplayer's response is zero to three decimals — it is exogenous. The gap decays at **ρ ≈ 0.78 per 14 days**, entirely from the follower side.

**This turns forecasting into convergence.** You are not predicting what a card will be worth. You are measuring a published anchor, measuring how far a slow venue sits from it, and collecting the gap. Every unobserved venue — local shops, shows, Facebook, Discord — prices off the same anchor and updates *slower* than eBay, so eBay's half-life is a lower bound on how stale in-person pricing is.

### The anchor migrates with price

| Price band | eBay volume share | β_ebay | β_tcg | **TCG share of correction** | Gap half-life |
|---|---|---|---|---|---|
| <$10 | 75.2% | −0.282 | 0.013 | **4%** | 28 d |
| $10–25 | 79.0% | −0.308 | 0.046 | 13% | 22 d |
| $25–50 | 79.8% | −0.215 | 0.050 | 19% | 32 d |
| $50–100 | 84.2% | −0.158 | 0.061 | 28% | **40 d** |
| $100–250 | 86.7% | −0.478 | 0.154 | 24% | 10 d |
| $250+ | **91.4%** | −0.390 | 0.234 | **38%** | 10 d |

- **Under $25, treat TCGplayer as truth** — it does 4–13% of the correcting.
- **Above $100, eBay carries 87–91% of volume and TCGplayer starts following it.** For chase cards eBay is the better liquidity-weighted reference.
- **$50–100 converges slowest (40-day half-life)** — the widest window to act in. $100+ closes in ~10 days: sharper edge, a third of the time.
- Pooled ρ=0.78 exceeds most individual bands (cross-sectional heterogeneity). **Use band-level ρ.**

Universe mean gap is **+0.16 logs — eBay runs ~17% richer.** The signal is deviation from a card's own baseline, not the raw sign. Demean per card.

## Factor table (measured)

Rank IC, 14-day horizon, SV/ME. The `skip` column is the honest one.

| Factor | IC (t+1) | **IC (skip)** | Verdict |
|---|---|---|---|
| **Venue gap** `ln(eb/tcg)` | −0.267 | **−0.247** | Strongest. Survives fully |
| **Volume growth** | +0.117 | **+0.147** | Real; *strengthens* with horizon |
| **PSA 10 move → raw** | +0.230 | — | Real (disjoint transactions) |
| **LP/NM ratio change** | +0.152 | — | Real (disjoint transactions) |
| p10 (cheap-tail) rise | +0.103 | +0.063 | Partly real |
| Price momentum | −0.027 | +0.070 | Noise at this horizon |
| ~~Tail shape~~ | −0.216 | **−0.026** | **Artifact. Do not use** |

Card momentum is negative at 14d and **+0.20 at 60d** — short-horizon reversal, long-horizon continuation. Do not mix horizons in one model.

**Equal-weight composite** (venue gap + volume growth + p10 change, percentile ranks, no fitting), rebuilt 2026-08-02 on the `grade_label` panel with the pd 6–11 guards: **IC 0.283 next-period, 0.167 skip-tested, within-set 0.225** over 4,236 card-periods. Decile 1 → 10 spread runs −37.8% to +5.0% forward, monotone. **The short side is much stronger than the long side — this is primarily an avoid-list.**

## Dollar economics

For zero-transaction-cost (in-person) trading the objective is `price × E[%move]`, not `E[%move]`. Top-decile composite, forward 14 days:

| Band | $ per card | % clearing $2+ |
|---|---|---|
| <$5 | $0.18 | 3% |
| $5–10 | $0.37 | 1% |
| $10–20 | $1.27 | 25% |
| **$20–50** | **$2.22** | **43%** |
| $50+ | $3.37 | 29% |

A $20 price cap is usually the binding constraint on dollar spread, not signal quality.

## References

- [`references/data-quality.md`](references/data-quality.md) — how the tape is built and where it is broken. Twelve audited defects with counts.
- [`references/sparsity-and-eras.md`](references/sparsity-and-eras.md) — era taxonomy, panel fill rates, the condition/grade ladder, and the cross-grade reconstruction recipe with its split-half validation.
- [`references/dataset-map.md`](references/dataset-map.md) — tables, columns, venue coverage, resolution rates, staleness, environment gotchas.
- [`references/methodology.md`](references/methodology.md) — the analytical traps, each with its diagnostic.
- [`references/findings.md`](references/findings.md) — dated result log, set-level regime state, and superseded claims.
- [`scripts/q.sh`](scripts/q.sh) — remote query runner (double-hop SSH → DuckDB).
- [`scripts/panel.sql`](scripts/panel.sql) — canonical panel builder, guards included. Verified end-to-end.

## Known open problems

- **Identity backfill on 2024–2025 eBay is the highest-value fix.** ~810k rows exist at <1% resolution. It is the only route to a **second market regime**, and one regime is the binding limitation on every coefficient in this skill.
- ~148k genuine secondary sales across 9 venues sit at 0% resolution. Smaller than it first appeared, but still the follower venues the anchor model wants.
- **eBay is only 43.9% resolved** — 2.5M sales discarded, and the unresolved half is probably non-random (messier titles, bundles), which is where mispricing concentrates.
- `listings.parquet` is stale since 2026-06-18. It carries `ask_price_usd`/`is_active`/`delisted_at` — the only true leading indicator here. Sales say what cleared; listings say what is about to.
- `pop_psa.parquet` is empty. PSA *population* is missing; PSA *prices* are not (1.08M transactions).
- No sealed-product table exists.
- Breadth (% of a set's cards up) is **coincident, not leading** — it predicts next-month set return worse than price itself (0.737 vs 0.761, concurrent 0.887). Do not build an early-warning indicator on it.
- eBay **auctions are excluded** by `trade_type='secondary'` (16,081 rows). Auction closes may be the cleanest clearing prices in the dataset; nobody has looked.
