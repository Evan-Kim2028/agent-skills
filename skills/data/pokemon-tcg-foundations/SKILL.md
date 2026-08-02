---
name: data-pokemon-tcg-foundations
description: Use when working with a trading-card sales tape — any sale-level dataset of collectible card transactions across multiple venues (Pokémon TCG, sports cards, MTG, or similar) — for price estimation, momentum and value factor construction, set/era-level regime detection, cross-venue basis and anchor-follower models, buy/sell signal design, or backtesting card selection. Encodes the structural defects these tapes reliably have (competing condition encodings, venue coverage gaps, lot-price contamination, FX-converted venues, venues that aren't secondary markets, silent writer regressions), the era structure and panel sparsity that makes naive panels unusable, the cross-grade price reconstruction that fixes it, and the traps that produce wrong-but-plausible results. Includes measured coefficients from a reference implementation. Don't use for TCG game strategy/deckbuilding, general lakehouse engineering (that's data-apache-lakehouse), generic DuckDB syntax (data-duckdb), or non-card asset classes.
---

# Trading-Card Sales Tapes — Foundations

How a card sales tape is shaped, where it is reliably broken, and which analyses on it are wrong in ways that look right.

**This skill is written to be portable.** The structure, defects and traps below recur across card sales tapes because they come from how these markets and pipelines work, not from one vendor. Concrete numbers come from a **reference implementation** and are marked as such:

> **Ref impl** — measured against a Pokémon TCG lakehouse (~9.4M sales, Feb–Aug 2026, DuckDB over Parquet). Connection details, table names and environment quirks: [`references/reference-implementation.md`](references/reference-implementation.md).

Treat ref-impl magnitudes as **order-of-magnitude priors and worked examples**, not constants. Re-measure them on your tape — every section tells you how.

---

## What a card sales tape is

**It is not a price series.** It is a transaction log in which the same card trades simultaneously in several observable markets — a marketplace's raw listings, an auction site's raw sales, graded copies at each grade, off-condition copies — and **those markets do not move at the same time.**

Nearly all exploitable signal lives in the *relationships between* those markets, not in the price history of any one. Card-level price momentum is close to worthless at short horizons; the cross-venue basis is typically the strongest single factor.

The practical consequence: work at **card × venue × period** granularity, with periods of 14 days or a month. Collapsing to a single blended monthly median per card throws away almost all the information and leaves you with a few dozen effective observations.

## The five questions to answer before your first analysis

Any card tape you pick up. In this order:

1. **Which venues are actually usable?** Identity resolution rate per venue, and `trade_type` composition per venue. Most venues fail one or both.
2. **How is condition/grade encoded, and is there more than one encoding?** There usually is. Pick the *complete* one, not the well-named one.
3. **Where does each venue's coverage start and stop?** Per-venue distinct-days-per-period against the calendar.
4. **How sparse is the panel?** Fraction of card×period cells clearing your minimum sale count — broken out by era.
5. **What is the measurement noise ceiling?** Split-half reliability. This bounds every result you will ever get and usually matters more than model choice.

`scripts/profile.sql` runs all five. Do not skip to modeling.

---

## Seven things that will burn you

**1. There is probably no canonical grade column — find the complete one.** Card pipelines accrete condition encodings: a marketplace's own vocabulary, a parsed-from-title vocabulary, a normalized slug vocabulary. They coexist, disagree, and neither dominates. **Check both row count and price agreement before choosing.** Agreement on price plus disagreement on count means one column is simply more complete — take it. Never fold in an "unknown condition" bucket: it is not "probably NM", it is a different, usually pricier population of unparsed listings.

> **Ref impl:** two encodings; the slug one returned **2.36× more rows** at a **median price ratio of 1.000** across 1,826 cards. 678 distinct values across the two columns, 109,314 rows where they contradict, 893 rows on impossible grades (`PSA 172`, `CGC 2006`). Filed upstream as [lake-of-rage#1580](https://github.com/Evan-Kim2028/lake-of-rage/issues/1580).

**2. Assume a silent writer regression is in flight.** A new ingest path lands, emits its own vocabulary for one or two columns, and every downstream consumer's filter silently drops its rows. This is invisible by construction — the rows are *present and correct*, just spelled wrong — so it shows up as an unexplained volume decline, which reads as a demand collapse. **Profile distinct values of every filter column by month.** A vocabulary that gains a new value mid-series is a regression until proven otherwise.

> **Ref impl:** since a specific date, a new writer emitted a fourth vocabulary for *both* the grade and identity-confidence columns. **360,669 fully-identified rows** (card key populated on 100% of them) were invisible to the canonical filter, and the share was still growing. Same window, same venue: old encoding 100% resolved, new encoding **0.0%**.

**3. Drop the newest period, always.** The most recent bar is still filling. A signal built on it reads ingest lag as collapsing demand. This is universal and free to fix.

> **Ref impl:** final-bar volume fell 66% — part lag, part the §2 regression, which alone stripped 43% of that period's rows on one venue.

**4. Venue coverage windows differ, and a short one is usually expected.** Venues get added to a pipeline at different times and backfill to different depths. **Do not read a coverage gap as a market event, and do not file it as an outage** — it is the shape of the data. It only determines where your panel can start: begin at the first period where every venue you need is adequately covered.

> **Ref impl:** the second venue's history is shorter and has a 37-day interior gap. One period before the start bound had **48 sales on one venue against 48,836 on the other** — a "venue gap" computed from that is noise.

**5. Most "venues" are not secondary markets.** A tape that aggregates on-chain and marketplace sources will carry primary issuance, buybacks, burns, internal transfers and vault movements alongside genuine arms-length resale. Filter on trade type explicitly. Headline row counts per venue routinely overstate tradeable volume by 5–10×.

> **Ref impl:** one venue was 98.8% primary/buyback, another mostly burn/transfer, a third had **zero** secondary rows. Genuine secondary across all unresolved venues was **~148k**, not the ~900k the raw counts suggested.

**6. Lot sales stamp the lot price on every card.** Multi-card transactions frequently write the whole lot's price onto each row. Guard with `count(*) OVER (PARTITION BY <transaction key>) = 1`, or reconstruct per-card value. Check this even if it is currently confined to venues you exclude — it goes live the day one of them is resolved.

> **Ref impl:** in 4–10-card transactions, 86% shared one identical price — median $48/row against $5.73 for genuine single-card sales.

**7. Never compare venues unconditionally.** Venues differ in *price formation*, not just level: auction-style venues cluster on psychological ask points, bulk marketplaces are continuous and dominated by sub-dollar volume. A pooled cross-venue comparison measures product mix, not basis. **Only compare per card, with a minimum sale count on both sides.**

> **Ref impl:** same era, same condition, median price by venue: **$0.19 vs $10.00.** All of that 50× is mix.

## Two more rules for aggregation

- **Compute returns within a venue, then volume-weight across.** Venue mix moves violently as pipelines add and lose sources. Pooled medians fabricate large moves that are pure composition.
- **Report within-set IC, not just total IC.** A large share of forward variance is set-level. A factor with high total IC and near-zero within-set IC is a set-beta proxy — it cannot choose between two cards in the same set, which is the only decision that matters when buying one card.

> **Ref impl:** ~34% of forward variance was set-level; one factor scored total IC 0.491 / within-set 0.034.

---

## Sparsity is the binding constraint — reconstruct across conditions

**Most of a card catalogue never trades.** Expect the majority of catalogued cards to have zero sales in any given quarter. Every method question reduces to *"does this buy me more observations per card-period?"*

**And rawness declines with print age.** Older cards mostly did not survive in near-mint, so their tape is dominated by played-condition and graded copies. This is a property of physical card survival, so it should hold on any long-lived card line.

> **Ref impl** — raw-NM share of sales by era: newest 64.8% · recent 64.2% · middle-modern 46.5% · **mid-era 30.3% · vintage 29.4%.** Mid-era tracks vintage, not modern. The same grouping appears independently in the graded premium (vintage 7.5× / mid 7.7× vs modern 1.5–1.8×) and the played-condition discount (0.766 / 0.728 vs 0.895 / 0.924) — three unrelated measurements, same split.

The panel consequence — fraction of card×period cells clearing a minimum sale count:

| Era (ref impl) | NM-only | Condition-pooled |
|---|---|---|
| vintage | 56.0% | 91.3% |
| **mid** | **22.3%** | **83.8%** |
| middle-modern | 49.0% | 85.7% |
| recent | 90.3% | 97.8% |
| newest | 91.2% | 94.6% |

**A best-condition-only panel is not viable on older eras.** The fix is to convert every raw condition to a best-condition-equivalent price using a per-era factor, then pool.

**Condition legs invert cleanly; graded legs do not.** Condition ratios are tight enough for a multiplier; graded premiums vary far too much card-to-card. **Use grades as a directional signal, never as a price level.**

> **Ref impl:** interquartile spread 1.50–1.95 for played conditions vs 3.49–4.25 for graded. Pooling raised split-half reliability in *every* era (mid 0.897 → 0.967) while mid-era usable cells went **3,299 → 17,584 (5.3×)**.

Factor tables, the recipe, and its validation: [`references/sparsity-and-eras.md`](references/sparsity-and-eras.md).

---

## The anchor model

**In a multi-venue card market, one venue is the price anchor and the others error-correct toward it.** With `gap = ln(follower_price / anchor_price)` per card, regress each venue's next-period move on the gap. The anchor's coefficient is ~zero (it is exogenous); the follower's is negative (it closes the gap).

**This turns forecasting into convergence.** You are not predicting what a card will be worth. You are measuring a published anchor, measuring how far a slower venue sits from it, and collecting the gap.

The wider implication: **every unobserved venue — local shops, shows, social marketplaces — prices off the same public anchor and updates more slowly than the observed follower.** So the follower's measured half-life is a *lower bound* on how stale in-person pricing is. That is the mechanism behind in-person arbitrage.

**The anchor migrates with price band.** Expect the bulk marketplace to anchor cheap cards and the liquid auction venue to anchor chase cards, with the crossover somewhere in the middle. **Always fit this per band** — a pooled correction coefficient is a cross-sectional average that matches no individual band.

> **Ref impl** — follower correlation with gap −0.384 vs anchor −0.002; pooled gap decay ρ ≈ 0.78 per 14 days.
>
> | Price band | Follower vol share | β_follower | β_anchor | Anchor's share of correction | Gap half-life |
> |---|---|---|---|---|---|
> | <$10 | 75.2% | −0.282 | 0.013 | **4%** | 28 d |
> | $10–25 | 79.0% | −0.308 | 0.046 | 13% | 22 d |
> | $25–50 | 79.8% | −0.215 | 0.050 | 19% | 32 d |
> | $50–100 | 84.2% | −0.158 | 0.061 | 28% | **40 d** |
> | $100–250 | 86.7% | −0.478 | 0.154 | 24% | 10 d |
> | $250+ | **91.4%** | −0.390 | 0.234 | **38%** | 10 d |
>
> Under $25 the bulk marketplace is truth. Above $100 the auction venue carries 87–91% of volume and the marketplace starts following *it*. Mid-band converges slowest (40-day half-life — the widest window to act in); the top band closes in ~10 days.

**Demean the gap per card.** The universe mean gap is nonzero — one venue runs structurally richer — so the raw sign is not the signal. Deviation from a card's own baseline is.

> **Ref impl:** universe mean gap **+0.16 logs**, i.e. the follower ran ~17% richer.

---

## Factor table

Measured on the ref impl at a 14-day horizon. **The `skip` column is the honest one** (see trap 1). Treat the ranking as a prior, the magnitudes as instance-specific.

| Factor | IC (t+1) | **IC (skip)** | Verdict |
|---|---|---|---|
| **Venue gap** `ln(follower/anchor)` | −0.267 | **−0.247** | Strongest. Survives fully |
| **Volume growth** | +0.117 | **+0.147** | Real; *strengthens* with horizon |
| **Top-grade move → raw** | +0.230 | — | Real (disjoint transactions) |
| **Played/best condition ratio change** | +0.152 | — | Real (disjoint transactions) |
| Cheap-tail (p10) rise | +0.103 | +0.063 | Partly real |
| Price momentum | −0.027 | +0.070 | Noise at this horizon |
| ~~Tail shape~~ | −0.216 | **−0.026** | **Artifact. Do not use** |

**Note the structural pattern, which should transfer:** the factors that survive are the ones built from *disjoint transaction sets* — graded sales are different transactions from raw sales, played sales are different from best-condition. Signals built from the same transactions as the target are exposed to bounce.

Card momentum was negative at 14d and **+0.20 at 60d** — short-horizon reversal, long-horizon continuation. Do not mix horizons in one model.

**Equal-weight composite** (venue gap + volume growth + p10 change, percentile ranks, no fitting): **IC 0.283 next-period, 0.167 skip-tested, within-set 0.225.** Decile 1 → 10 spread −37.8% to +5.0% forward, monotone. **The short side is much stronger than the long side — this is primarily an avoid-list.** That asymmetry is worth checking for on any tape; overpriced cards are easier to identify than underpriced ones.

## Dollar economics

For zero-transaction-cost (in-person) trading the objective is `price × E[%move]`, not `E[%move]`. Cheap cards can have excellent percentage signal and no tradeable spread.

> **Ref impl** — top-decile composite, forward 14 days:
>
> | Band | $ per card | % clearing $2+ |
> |---|---|---|
> | <$5 | $0.18 | 3% |
> | $5–10 | $0.37 | 1% |
> | $10–20 | $1.27 | 25% |
> | **$20–50** | **$2.22** | **43%** |
> | $50+ | $3.37 | 29% |
>
> A price cap is usually the binding constraint on dollar spread, not signal quality.

**And the threshold is channel-specific.** $2 is a real spread in person at ~0% fees and nothing at all on a venue taking ~13%. Always state the channel a dollar figure assumes.

---

## If you are here to build a model

Six properties of this asset class break assumptions that are so safe elsewhere they go unstated. Full treatment and evidence in [`references/asset-class-properties.md`](references/asset-class-properties.md).

- **It is a point process, not a time series.** Every price series here is a grid *you imposed* on event data. Arrival intensity is a signal in its own right — often better than price.
- **Observation is endogenous.** Cards trade *because* someone wanted them. Dropout varies with both the signal and the price: in the reference implementation the top return quintile is 6pp less likely to trade again than a flat card, and $50+ cards drop out at 81.5% vs 93.0% for sub-$2. **Your training set is selected on the outcome, and it loses exactly the expensive names with tradeable spread.**
- **Cold start is the normal case.** New sets arrive continuously with zero history — 14.3% of the ending universe was new over three months. This is why hierarchical models earn their keep.
- **Most of the observed return variance is measurement error.** Reliability ~0.70 means the ceiling on correlation with true momentum is √0.70 ≈ 0.84. Evaluate against that, not against 1.0.
- **Weighting can flip the sign.** Same universe, same window: equal-weight **−7.65%**, dollar-weight **+3.18%**, median 0.00%. State which you chose.
- **You cannot short.** Long-short decile spreads report a number you cannot monetize. Report the long leg separately.

**And you cannot back-fill history.** Venues purge sold data on ~90-day horizons, so deep history exists only where someone was already capturing it. Broad early capture beats every model choice available.

---

## Answer the person, not the panel

Nobody buying cards has a Sharpe ratio. Four personas ask, and they optimize different — sometimes opposite — things:

- **Collector** — buys to keep. Wants a *fairness check* on today's ask, not a return forecast. Reprint risk is their real enemy.
- **Flipper** — wants a buy-under and a sell-over price **in dollars**, plus how long the exit takes. A percentage on a $3 card is not an answer.
- **Vendor** — judged on **turns, not appreciation**. Ranking by expected return without liquidity hands them a shelf of unsellable stock. The avoid-list is worth more to them than the buy-list.
- **Grader** — wants EV of submission. We can supply the graded price distribution; `P(grade)` depends on the physical card and **analysis must defer there.**

**Three things the hobby knows that the tape cannot see** — treat as veto inputs, not features: **reprint risk** (modern supply is elastic; vintage is fixed), **rotation and playability** (a published, exogenous calendar), and **condition in hand** (centering, whitening and print lines appear in no column).

**The most-asked question is the one the data cannot support.** "Is this a good long-term hold?" over a six-period window is not answerable. Decline it rather than extrapolating a 14-day coefficient.

Personas, the lingo→column translation table, market-structure facts and the folk-claims register: [`references/personas-and-decisions.md`](references/personas-and-decisions.md) and [`references/domain-knowledge.md`](references/domain-knowledge.md).

---

## References

- [`references/tape-anatomy.md`](references/tape-anatomy.md) — what a card sales tape contains, the columns that matter, and what to profile first.
- [`references/data-quality.md`](references/data-quality.md) — the defect taxonomy, ordered by damage, each with a diagnostic.
- [`references/sparsity-and-eras.md`](references/sparsity-and-eras.md) — era structure, panel fill rates, the condition/grade ladder, and the cross-grade reconstruction recipe.
- [`references/methodology.md`](references/methodology.md) — the analytical traps. Every one has produced a wrong-but-plausible result.
- [`references/asset-class-properties.md`](references/asset-class-properties.md) — for ML/quant work: what card markets *are* structurally, and which standard modeling assumptions they violate.
- [`references/personas-and-decisions.md`](references/personas-and-decisions.md) — collector / flipper / vendor / grader: what each is optimizing, what output is useful, and how their question translates into ours.
- [`references/domain-knowledge.md`](references/domain-knowledge.md) — the hobby's vocabulary mapped to columns, market-structure facts absent from every tape, and the folk-claims register (confirmed / retracted / untested).
- [`references/findings.md`](references/findings.md) — dated result log from the reference implementation, plus superseded claims.
- [`references/reference-implementation.md`](references/reference-implementation.md) — the concrete instance: connection, tables, columns, environment quirks.
- [`scripts/profile.sql`](scripts/profile.sql) — the five opening questions, as one script.
- [`scripts/panel.sql`](scripts/panel.sql) — canonical panel builder with guards.
- [`scripts/q.sh`](scripts/q.sh) — remote query runner for the reference implementation.

## Known open problems

Generic first, then instance-specific.

- **One regime is the binding limitation on every coefficient here.** All magnitudes were fit in a single up-then-cooling episode with no observed drawdown. Extending identity resolution backwards to reach a second regime is worth more than any modeling improvement.
- **Ask-side data is the only true leading indicator.** Sales say what cleared; listings say what is about to. Time-to-sale beats price as a demand signal. If your tape has a listings table, keep it fresh.
- **Auction closes are arguably the cleanest clearing prices** in any card tape, and a `trade_type='secondary'` filter usually excludes them. That exclusion is a choice, not a given.
- **Exogenous drivers are absent from every column** — reprints, rotation, tournament meta, a popular video. They are a large share of what actually moves prices. That is an information problem, not a modeling one.
- **Population data and sealed product** are usually missing or empty; check rather than assume.

> **Ref impl specifics:** ~810k pre-2026 rows sit at <1% identity resolution; the main auction venue is only 43.9% resolved and the unresolved half is probably non-random (messier titles, bundles), which is where mispricing concentrates; the listings table is stale; the PSA population table is empty (PSA *prices* are not — 1.08M transactions); no sealed-product table exists. Breadth (% of a set's cards up) tested as **coincident, not leading** — do not build an early-warning indicator on it.
