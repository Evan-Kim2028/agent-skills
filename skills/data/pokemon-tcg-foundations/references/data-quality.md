# Data quality: how card tapes break

A defect taxonomy, ordered by how much damage each does. Every item changes what a correct query looks like.

These recur because they come from how card marketplaces and ingest pipelines work — aggregating heterogeneous venues, parsing free-text listings, resolving fuzzy identities — not from one vendor's mistakes. **Expect each of these until you have checked.**

Each section gives the general pattern, its diagnostic, and evidence from the reference implementation (audited 2026-08-02, 9,439,263 rows). Ref-impl numbers illustrate magnitude; they are not constants.

---

## 1. Several columns encode condition, and the obvious one is usually the wrong one

**The pattern.** Condition/grade arrives from multiple upstream parsers — a marketplace's own field, a title parser, a normalizer — and each writes its own column or its own vocabulary. They coexist. Neither dominates. **The one with the friendlier name is not the populated one.**

**Why it matters more than it sounds.** Against a measurement-noise ceiling (see `methodology.md` §7), sample size is the binding constraint on every result. A column choice that changes sample size by 2× beats every model-class change available to you.

**The diagnostic.** For any two candidate filters, check *both* count and price agreement:

```sql
SELECT venue,
  count(*) FILTER (WHERE col_a = 'NM')      via_a,
  count(*) FILTER (WHERE col_b = 'raw_nm')  via_b,
  count(*) FILTER (WHERE col_a = 'NM' AND col_b = 'raw_nm') via_both
FROM sales GROUP BY 1;
-- then per card: median(px under A) / median(px under B) should be ~1.000
```

**Agreement on price plus disagreement on count means one column is simply more complete.** Take the complete one. Disagreement on *price* means they are measuring different things — stop and find out which.

**Never fold in the "unknown condition" bucket.** It is not "probably best condition." It is typically unparsed higher-end listings — a different, pricier population.

> **Ref impl.** `condition` vs `grade_label`, both describing condition, populated by different parsers.
>
> | Venue | `condition='NM'` | `grade_label='raw_nm'` | Ratio |
> |---|---|---|---|
> | eBay | 187,398 | **442,805** | **2.36×** |
> | TCGplayer | 358,634 | **504,628** | 1.41× |
>
> Median price ratio **1.000** (p25 0.997, p75 1.023) across 1,826 cards — pure sample loss, not a definitional difference.
>
> Neither dominates: `condition` NULL on 62.6% of rows (13 distinct values), `grade_label` NULL on 16.6% (**678** distinct values). 1,032,050 rows have `grade_label` only; 45,926 have `condition` only. **109,314 rows contradict**, of which 108,162 are `condition='NM'` + `grade_label='raw_unknown'` — one column knows, the other discarded it. `raw_unknown` medians $9.90 against $5.99 for `raw_nm`.
>
> Filed upstream as [lake-of-rage#1580](https://github.com/Evan-Kim2028/lake-of-rage/issues/1580) — there should be a single canonical grade column with a closed vocabulary validated at write time.

### 1b. Parsers leak non-grades into the grade field

Graded scales top out at 10. Any value above that is a cert number or card number captured by the parser. **Range-check graded legs to `1 ≤ grade ≤ 10`.**

Row damage is usually trivial; *vocabulary* damage is not, which is why the field looks unenumerable.

> **Ref impl:** 893 rows on impossible grades (`PSA 172`, `CGC 2006`, `TAG 226`, `BGS 123`) — but **409 of the 678 distinct values**.

### 1c. Source-locale strings reach the analytical layer

Non-English marketplaces write condition in their own language, unnormalized.

> **Ref impl:** `目立った傷や汚れなし` (2,186 rows) and five others from a Japanese venue.

---

## 2. Silent writer regressions

**The pattern — and it is the nastiest one here.** A new ingest path ships. It emits its own vocabulary for one or more filter columns. Every downstream consumer's `WHERE` clause silently drops its rows.

**This is invisible by construction.** The rows are present, priced, and correctly identified — just *spelled* differently. Nothing errors. Row counts fall, which reads as declining market activity. Analysts then explain the decline with a market narrative.

**The diagnostic — run it on every refresh.** Distinct values of every filter column, by month:

```sql
SELECT date_trunc('month', sale_date) m, id_confidence, count(*)
FROM sales GROUP BY 1,2 ORDER BY 1,2;
```

**A filter column that gains a new distinct value mid-series is a regression until proven otherwise.** Then confirm with a same-window head-to-head, so recency cannot explain the difference:

```sql
SELECT venue, <encoding>, count(*) n,
       round(100.0*count(*) FILTER (WHERE <resolved>)/count(*),1) pct_resolved
FROM sales WHERE sale_date BETWEEN <onset> AND <end> GROUP BY 1,2;
```

**The structural fix, worth pushing upstream:** closed vocabularies validated at write time, rows that fail quarantined rather than coerced, and a canary that alerts when distinct-value count exceeds the vocabulary size. That catches this class on day one.

> **Ref impl (live).** Since **2026-06-29** a `cardindex` writer emits `id_confidence='cardindex_card_id'` and `grade_label='NM'` instead of `'high'`/`'raw_nm'`.
>
> Identical window (2026-06-29 → 2026-07-30), so recency is excluded:
>
> | Venue | Encoding | Rows | % resolved |
> |---|---|---|---|
> | tcgplayer | `raw_nm`/`raw_lp` | 694,516 | **100.0%** |
> | tcgplayer | `NM`/`LP` | 224,389 | **0.0%** |
> | ebay | `raw_nm`/`raw_lp` | 262,522 | 73.9% |
> | ebay | `NM`/`LP` | 132,674 | **0.0%** |
>
> **360,669 rows invisible**, `tcg_card_id` populated on 100% of them. Growing, not migrating: the old path held at ~38–40k rows/day while the new one climbed from 3,883 to 14,273/day within a week. Two writers side by side.
>
> Panel impact: at the newest period it stripped **57,790 eBay rows — 43% of what should be available.** Until fixed, treat later periods as under-counted by a widening margin.
>
> **Second instance, found by running the canary in `scripts/profile.sql`.** Since **2026-07-02** the `alt_xyz` writer emits a *numeric score* into the same column — `'0.85'` (3,287 rows), `'1.0'` (929), `'0.9'` (1). All 4,217 have `tcg_card_id` populated. That venue is recorded as "0% resolved" in the venue table; it is actually **fully mapped under an unrecognized encoding**. Small in rows, but it makes the point: the same column was breached twice by two unrelated writers in five weeks, and neither breach errored.
>
> **The generalizable lesson:** once one writer breaches a vocabulary, assume others have too. Enumerate the column's *full* value set, not just the value you went looking for — and re-check any venue you previously wrote off as unresolvable, because "0% resolved" and "resolved under a name your filter doesn't know" are indistinguishable from the outside.

---

## 3. The newest period is always under-ingested

**The pattern.** The most recent bar is still filling when you query it. Universal, and free to fix: **always drop `max(period)`.**

A signal built on the newest bar reads ingest lag as a demand collapse. Bake the guard into your panel builder rather than remembering it.

Note that lag and a §2 regression **look identical** and can coexist. Do not stop at the first explanation.

> **Ref impl:** eBay volume fell 66% in the final period — part lag, part the `cardindex` regression, which alone accounted for 43%. `scripts/panel.sql` bakes in the upper bound.

---

## 4. Venue coverage windows differ — and that is expected

**The pattern.** Venues enter a pipeline at different times and backfill to different depths. Interior gaps happen too. **This is the shape of the data, not an outage** — do not read it as a market event and do not file it as a bug.

The only thing it determines is **where your panel can start**: the first period where every venue you need is adequately covered.

**The diagnostic — count distinct days, not rows.** A venue running at 10% of normal volume looks healthy on a row count:

```sql
SELECT venue, pd, count(DISTINCT sale_date) days, count(*) n
FROM sales GROUP BY 1,2 ORDER BY 1,2;
```

Cross-venue factors are **undefined** in any period where one venue is degenerate. Check the *ratio* of per-venue counts within each period, not just their presence.

> **Ref impl:** TCGplayer covers 130 of 167 calendar days — 37 absent (2026-03-03 → 2026-04-21) plus 23 below quarter-volume; eBay has zero absent days. One period before the start bound carried a "venue gap" computed from **48 TCGplayer sales against 48,836 eBay sales.** Usable range: `pd BETWEEN 6 AND 11`. Re-derive both bounds on every refresh.

---

## 5. Most "venues" are not secondary markets

**The pattern.** Aggregated tapes — especially ones spanning on-chain vaults and custodial marketplaces — carry primary issuance, buybacks, burns, internal transfers and vault movements alongside genuine arms-length resale. **Headline row counts routinely overstate tradeable volume by 5–10×.**

**The diagnostic.** Cross-tabulate venue against trade type before believing any per-venue volume figure. A venue that is 99% primary issuance is not a price signal at any identity-resolution rate, and is not worth prioritizing for a pipeline fix.

Note also that a `trade_type='secondary'` filter usually **excludes auctions**, which are arguably the cleanest clearing prices in the tape. That exclusion is a defensible choice for consistency — but it is a choice.

> **Ref impl.**
>
> | Venue | Composition |
> |---|---|
> | tcgplayer | secondary 2,475,734 · unknown 224,397 |
> | ebay | secondary 4,289,688 · unknown 79,535 · fixed 53,926 · auction 16,081 |
> | **renaiss** | primary 238,796 · buyback 236,587 · **secondary 5,823** · transfer 4,459 |
> | **courtyard** | burn 58,031 · transfer 40,479 · **secondary 38,354** · buyback 13,240 |
> | **beezie** | internal 55,829 · primary 42,282 · buyback 41,631 · **secondary 0** |
>
> This retired an internal "900k blocked sales" figure: genuine secondary across every unresolved venue is **~148k**.

---

## 6. Lot sales stamp the lot price on every card

**The pattern.** Multi-card transactions frequently write the whole lot's price onto each constituent row. Treating those as individual sale prices inflates a card's median by roughly an order of magnitude.

**The diagnostic.** Group by transaction key, bucket by cards-per-transaction, and check what fraction of multi-card transactions share one identical price across all rows:

```sql
SELECT n_cards, count(*) txs,
       round(100.0*count(*) FILTER (WHERE min_px = max_px)/count(*),1) pct_identical
FROM (SELECT tx_id, count(*) n_cards, min(price) min_px, max(price) max_px
      FROM sales GROUP BY 1) GROUP BY 1;
```

**Guard with `count(*) OVER (PARTITION BY tx_id) = 1`.**

**Check this even if it is currently confined to venues you exclude.** It goes live the day one of them is resolved, and by then it is in your backtest.

> **Ref impl:** in 4–10-card transactions, **85.9% stamp one identical price on every row** — median $48/row against $5.73 for genuine single-card sales. Confined today to three excluded venues (beezie 40% multi-card, courtyard 8.2%, renaiss 6.7%) and **0.0%** of the two usable venues.

---

## 7. Venues have different price-formation processes

**The pattern.** Venues differ in *how prices are made*, not just their level. Auction and fixed-price consumer venues cluster on psychological ask points; bulk marketplaces are continuous and dominated by sub-dollar volume. They therefore also carry **different product mixes**.

**Consequence: an unconditional venue comparison measures mix, not basis.** Only compare per card, with a minimum sale count on both sides.

**A second consequence worth knowing:** ask-point quantization means week-over-week "no change" is partly a quoting convention, not an absent market. This interacts with the sticky-price trap (`methodology.md` §4).

> **Ref impl.** eBay's modal prices are `$1.99 / $2.99 / $3.99` and 27.2% whole-dollar — seller-set asks that cleared. TCGplayer's distribution is continuous, 63.6% under $1 and 33.1% under 25¢ — a genuine bulk market. Same era, same condition, median price: TCGplayer **$0.19** vs eBay **$10.00**. All 50× of that is mix. `panel.sql` enforces `n_a >= 4 AND n_b >= 4` per card.

---

## 8. Sub-cent precision is an FX fingerprint

**The pattern.** A venue whose prices carry more than two decimal places has been **converted from another currency**, at an unrecorded rate on an unrecorded date. Those prices carry FX noise on top of price noise, and an apparent "move" may be a currency move.

**The diagnostic — cheap, run it on every new venue before trusting its levels:**

```sql
SELECT venue, round(100.0*count(*) FILTER (WHERE price*100 != floor(price*100))/count(*),2) pct_subcent
FROM sales GROUP BY 1 ORDER BY 2 DESC;
```

Anything above a few percent is converted. Treat such a venue as a **separate price regime** — not a comparable venue — unless you are explicitly modelling FX.

> **Ref impl:** ebay_hk 99.68% · mercari_jp 77.81% · courtyard 13.52% · renaiss 13.20% · beezie 3.96% · ebay 0.73% · tcgplayer 0.00%. `ebay_hk` also runs ~3× lower on comparable cards.

---

## 9. Deep history exists but is not joinable

**The pattern.** Raw sale rows often go back a decade, but **identity resolution collapses going backwards** — older listings have messier titles and the catalogue they'd map to didn't exist yet. The honest statement is rarely "the data starts in year X"; it is **"the data becomes joinable in year X."**

**Why it is the highest-value fix on most tapes.** Backfilling identity on older rows is usually the only route to a **second market regime** — and a single regime is the binding limitation on every coefficient you will estimate. It beats any modeling improvement.

> **Ref impl:** eBay's first row is 2009-11-02. Resolution by year: 0.1% (2021–22), 0.3% (2023), 0.4% (2024), 10.9% (2025), **55.1% (2026)**. ~810k pre-2026 rows are present and unmappable.

---

## 10. Variant contamination

**The pattern.** Multiple printings — reverse holos, alternate arts, regional and language variants, promo reprints — map to one card identity, producing a bimodal price distribution and a meaningless median.

**Measure it rather than assuming it.** Mine listing titles on whichever venue populates them, split by printing, and compare per-card medians.

The finding to expect: **unbiased in aggregate, severe in the tail.** Pooling is fine for set-level work; for a single card's level estimate it is a meaningful chance you are averaging two materially different assets.

**Gate for level estimation:** interquartile dispersion `q75/q25 ≤ ~1.7–1.8` over a trailing window. Cards above that are contaminated — exclude them from *level* work only. This is a filter, not a signal, and it must not be applied when the distribution's shape is what you are studying (`methodology.md` §5, §9).

> **Ref impl:** reverse holos are **7.7%** of eBay raw SV/ME sales (51,142 of 664,845). Across 638 cards with ≥10 sales each way the reverse-vs-base median ratio is **1.000** (p25 0.905, p75 1.137) — but **21.9% of cards differ by more than 30%.** Japanese printings were a non-issue in that era (no card reached 10 Japanese-titled raw sales). Title mining is eBay-only: `title` is NULL on 91.7% of TCGplayer rows.

---

## 11. Identity keys are messier than they look

**Check all four before joining anything:**

- **Is the sale key unique?** If not, find out whether duplicates are twins (same real sale, two ingests) or genuine.
- **Is name + set a key?** Almost never. Always join on the card identity column.
- **Does the variant column actually carry values?** Often it is present but empty, which is worse than absent because it looks usable.
- **Is the rarity taxonomy consistent?** Expect mixed casing and separators. Make rarity filters case- and separator-tolerant.

> **Ref impl:** `sale_id` is unique (9,439,263 of 9,439,263). `variant` has one distinct value (the empty string) plus 325 NULLs — unusable. 5,017 SV/ME cards collapse to 3,762 distinct name+set pairs (~25% collide). `rarity` mixes `MEGA_ATTACK_RARE` with `Mega Hyper Rare`; 420 NULLs.

---

## 12. Liquidity is concentrated, and the liquid cards are not raw

**The pattern, and it is counterintuitive: the more a card trades, the smaller the raw share of its volume.** High-volume cards are chase cards, and chase cards get graded. So **headline volume does not imply a well-measured raw price — the two are anticorrelated.**

Consequence: the universe of cards with enough *raw* sales for card-level work at a short horizon is far smaller than the universe of cards with enough sales overall. Size it explicitly before designing a strategy around it.

> **Ref impl**, SV/ME:
>
> | Sales per card | Cards | % of all sales | % of those sales raw NM |
> |---|---|---|---|
> | 10–49 | 61 | 0.1% | 72.2% |
> | 50–199 | 1,495 | 14.0% | 55.4% |
> | 200–999 | 2,768 | 62.4% | 35.4% |
> | 1000+ | 266 | 23.5% | **15.5%** |
>
> Only **595 cards** carry ≥180 raw NM sales — the realistic universe for 14-day card-level raw price work.

---

## 13. Weekday seasonality — check, then ignore

Worth one query so you can rule it out. Expect it to be negligible at 14-day or monthly resolution, with a mild weekend mix shift toward pricier cards. It matters only if someone builds a daily model.

> **Ref impl:** volume flat across weekdays; Saturday eBay median $8.81 vs $8.00 elsewhere.
