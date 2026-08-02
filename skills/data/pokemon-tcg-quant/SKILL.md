---
name: data-pokemon-tcg-quant
description: Use when doing quantitative research on the Pokémon TCG sales lakehouse (silphcoanalytics / lake-of-rage gold tables) — card price prediction, momentum/value factor construction, set-level regime detection, cross-venue basis and anchor-follower models, buy/sell signal design, backtesting card selection, or interpreting card_sales_history / card_rollup. Encodes measured coefficients (venue error-correction, factor ICs, anchor-by-price-band), the dataset's real coverage and staleness, and the specific methodological traps that produce false results here (bid-ask bounce, venue mix shift, lookahead in outlier fences, sticky-price medians). Don't use for TCG game strategy/deckbuilding, general lakehouse engineering (that's data-apache-lakehouse), generic DuckDB syntax (data-duckdb), or non-Pokémon collectibles.

---

# Pokémon TCG Quantitative Research

Domain skill for signal research on the Pokémon TCG transaction lakehouse. It exists because this dataset has a specific structure — **a multi-venue, multi-condition, multi-grade transaction tape for the same underlying asset** — and most of the obvious analyses on it are wrong in ways that look right.

> **Verified:** 2026-08-02 against `~/data/pokemontcg_pipe/gold/` on `lor-main`, DuckDB 1.5.3.
> Coefficients are measured over Feb–Aug 2026 on the SV/ME era in **a single up-then-cooling regime**.
> Structural facts (which venue anchors, what the traps are) age slowly. Magnitudes should be re-measured.

## When to invoke this skill

- Building or evaluating a buy/sell signal for singles.
- Any question of the form "which cards/sets are undervalued / trending / about to move."
- Cross-venue, cross-grade, or cross-condition relative value.
- Set-level regime or momentum work.
- Interpreting an existing result off these tables — especially a *surprisingly good* one.

## The one-paragraph orientation

This is **not a price series dataset**. It is a transaction tape where the same card trades simultaneously in up to four observable markets (TCGplayer raw, eBay raw, PSA 10, raw LP), and those markets do not move at the same time. Nearly all the exploitable signal is in the *relationships between those markets*, not in the price history of any one of them. Card-level price momentum is close to worthless at short horizons; the cross-venue basis is the strongest single factor measured.

## The five rules

**1. Never model the median path alone.** Collapsing 7.5M transactions to monthly medians throws away ~99.9% of the information and leaves you with ~20 effective observations. Work at card × venue × 14-day-period granularity; that panel has ~24,000 rows.

**2. Compute returns within a venue, then aggregate.** Marketplace mix shifts violently (TCGplayer 117k→443k monthly while eBay 198k→137k, Jun→Jul 2026). A pooled median across venues will fabricate large moves that are pure composition. Always: log-return inside each marketplace → volume-weight across.

**3. Use matched-model changes.** Week-over-week for the *same card* in the *same venue*, aggregated by median. Anything else drifts with which cards happened to trade.

**4. Skip-a-period test every new signal.** See "The bounce trap" below. This is not optional; it killed the best-looking factor found so far.

**5. Report the within-set IC, not just the total IC.** ~34% of forward variance is set-level. A factor with total IC 0.49 and within-set IC 0.034 is a set-beta proxy that cannot pick one card over another. See [`references/methodology.md`](references/methodology.md).

## The anchor model (the central finding)

TCGplayer is the **price anchor**; eBay is a **follower that error-corrects toward it**. Measured on 7,091 card-periods:

| | Correlation with gap | Correction coefficient |
|---|---|---|
| eBay's next move | **−0.384** | **−0.223** |
| TCGplayer's next move | −0.002 | −0.001 |

TCGplayer's response is zero to three decimals — it is exogenous. Define `gap = ln(eBay_median / TCG_median)`; it decays at **ρ ≈ 0.78 per 14 days**, and the entire adjustment comes from the follower side.

**This flips the problem from forecasting to convergence.** You are not predicting what a card will be worth. You are measuring a published anchor, measuring how far a slow venue sits from it, and collecting the gap. Every unobserved venue (local shops, shows, Facebook, Discord) prices off the same anchor and updates *slower* than eBay, so eBay's measured half-life is a lower bound on how stale in-person pricing is.

### The anchor shifts with price

Anchor dominance is **not constant** — price discovery migrates to eBay as cards get expensive, because that is where the liquidity is:

| Price band | eBay volume share | β_ebay | β_tcg | **TCG share of correction** | Gap half-life |
|---|---|---|---|---|---|
| <$10 | 75.2% | −0.282 | 0.013 | **4%** | 28 d |
| $10–25 | 79.0% | −0.308 | 0.046 | 13% | 22 d |
| $25–50 | 79.8% | −0.215 | 0.050 | 19% | 32 d |
| $50–100 | 84.2% | −0.158 | 0.061 | 28% | **40 d** |
| $100–250 | 86.7% | −0.478 | 0.154 | 24% | 10 d |
| $250+ | **91.4%** | −0.390 | 0.234 | **38%** | 10 d |

Practical readings:

- **Under $25, treat TCGplayer as truth.** It does 4–13% of the correcting; eBay does the rest.
- **Above $100, eBay carries 87–91% of volume and TCGplayer starts following it** — TCG does ~a quarter to over a third of the adjustment. For chase cards eBay is the better liquidity-weighted reference, which matches practitioner intuition.
- **$50–100 has the slowest convergence (40-day half-life)** — the widest window to act in. $100+ closes in ~10 days: more efficient, sharper, less time.
- The pooled ρ=0.78 is higher than most individual bands (cross-sectional heterogeneity). **Use band-level ρ, not the pooled number.**

Mean gap across the universe is **+0.16 in logs — eBay runs ~17% richer than TCGplayer on average.** The signal is deviation from a card's own baseline, not the raw sign of the gap. Demean per card.

## Factor table (measured)

Rank IC, 14-day horizon, SV/ME era. The `skip` column is the honest one — signal from *t*, return measured *t+1 → t+2*, no shared transactions.

| Factor | IC (t+1) | **IC (skip)** | Verdict |
|---|---|---|---|
| **Venue gap** `ln(eb/tcg)` | −0.267 | **−0.247** | Strongest. Survives fully |
| **Volume growth** | +0.117 | **+0.147** | Real; *strengthens* with horizon |
| **PSA 10 move → raw** | +0.230 | — | Real (disjoint transactions) |
| **LP/NM ratio change** | +0.152 | — | Real (disjoint transactions) |
| p10 (cheap-tail) rise | +0.103 | +0.063 | Partly real |
| Price momentum | −0.027 | +0.070 | Noise at this horizon |
| ~~Tail shape~~ | −0.216 | **−0.026** | **Artifact. Do not use** |

Longer-horizon (60d) card momentum is +0.20 — momentum works at 60d and not at 14d. Short-horizon reversal, long-horizon continuation. Do not mix the two horizons in one model.

**Equal-weight composite** (venue gap + volume growth + p10 change, percentile ranks, no fitting): IC **0.287** next-period, **0.185** skip-tested, **within-set IC 0.261**. Positive in all 8 periods with meaningful sample. Decile 1 → decile 10 spread: −37.8% vs +5.0% forward, monotone. The short side is much stronger than the long side — this is primarily an **avoid-list**.

## Dollar economics

For zero-transaction-cost (in-person) trading, the objective is `price × E[%move]`, not `E[%move]`. Top-decile composite, forward 14 days:

| Band | $ per card | % clearing $2+ |
|---|---|---|
| <$5 | $0.18 | 3% |
| $5–10 | $0.37 | 1% |
| $10–20 | $1.27 | 25% |
| **$20–50** | **$2.22** | **43%** |
| $50+ | $3.37 | 29% |

A $20 price cap is usually the binding constraint on dollar spread, not signal quality.

## Detail references

- [`references/dataset-map.md`](references/dataset-map.md) — tables, columns, venue coverage, identity-resolution rates, what's stale, what's empty.
- [`references/methodology.md`](references/methodology.md) — the traps in full, with the diagnostic for each.
- [`references/findings.md`](references/findings.md) — dated result log including set-level regime state and superseded claims.
- [`scripts/q.sh`](scripts/q.sh) — remote query runner (double-hop SSH → DuckDB).
- [`scripts/panel.sql`](scripts/panel.sql) — canonical card × venue × period panel builder.

## Known open problems

- **~900k sales across 9 follower venues have 0% identity resolution** (renaiss, courtyard, beezie, fanatics, mercari_jp, dyli, alt_xyz, goldin, collector_crypt). These are exactly the follower venues the anchor model needs. Highest-value pipeline fix.
- **eBay is only 43.9% resolved** — 2.5M sales discarded, and the unresolved half is probably non-random (messier titles, bundles), which is where mispricing concentrates.
- `listings.parquet` is stale since 2026-06-18. It carries `ask_price_usd`/`is_active`/`delisted_at` — the only true leading indicator in the lakehouse. Sales tell you what cleared; listings tell you what's about to.
- `pop_psa.parquet` is empty. PSA *population* is missing; PSA *prices* are not (1.08M transactions).
- No sealed-product table exists.
- Breadth (% of set's cards up) is **coincident, not leading** — it predicts next-month set return worse than price itself does (0.737 vs 0.761, concurrent 0.887). Do not build an early-warning indicator on it.
