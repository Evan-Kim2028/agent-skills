# Data quality: how the tape is actually built

Audited 2026-08-02 against `card_sales_history.parquet` (9,439,263 Pokémon rows).

This file is the result of interrogating the *plumbing* rather than the prices. Every item here changes what a correct query looks like. They are ordered by how much damage they do.

---

## 1. There are two condition encodings, and the obvious one is the wrong one

`condition` and `grade_label` both describe card condition. They are populated by different upstream parsers and **`grade_label` is substantially more complete.**

SV/ME era, raw secondary sales, since 2026-02-16:

| Venue | `condition='NM'` | `grade_label='raw_nm'` | Ratio |
|---|---|---|---|
| eBay | 187,398 | **442,805** | **2.36×** |
| TCGplayer | 358,634 | **504,628** | 1.41× |

**They do not disagree about price.** Across 1,826 cards with ≥10 sales under each filter, the median ratio of the two price estimates is **1.000** (p25 0.997, p75 1.023). So `grade_label` is a free 2.4× increase in eBay sample size at identical price level.

That matters more here than it sounds. Split-half reliability on this dataset is 0.70 — roughly 30% of a card's measured momentum is sampling noise in the median. Sample size *is* the binding constraint, and this filter change relaxes it more than any modeling choice available.

**Never fold in `raw_unknown`.** It is not "probably NM" — on eBay it medians **$9.90 against $5.99 for `raw_nm`**. It is a different, more expensive population (unparsed higher-end listings), and 522k eBay rows sit in it.

`grade_label` vocabulary: `raw_nm`, `raw_lp`, `raw_mp`, `raw_hp`, `raw_dmg`, `raw_unknown`, the graded ladder (`PSA 10`, `CGC 9.5`, `BGS 9`, …), plus a *second* convention of bare `NM` / `LP` (see §2b). Handle all three.

**Neither column dominates the other, and they contradict.** Whole table: `condition` is NULL on 62.6% of rows with 13 distinct values; `grade_label` is NULL on 16.6% with **678** distinct values.

- 1,032,050 rows have `grade_label='raw_nm'` and `condition` NULL.
- 45,926 rows have `condition='NM'` and `grade_label` NULL.
- 109,314 rows have `condition='NM'` but a `grade_label` that is neither `raw_nm` nor `NM` — **108,162 of them are `raw_unknown`**, i.e. one column knows the condition and the other discarded it.

**893 rows carry impossible grades** — `PSA 172`, `CGC 2006`, `TAG 226`, `BGS 123` — cert or card numbers caught by the grade parser. Trivial by row count but **409 of the 678 distinct values**, which is why the vocabulary cannot be enumerated. Filter graded legs to `1 ≤ grade ≤ 10`.

`condition` also carries untranslated source-locale strings from mercari_jp (`目立った傷や汚れなし`, 2,186 rows, and five others).

All of the above is filed upstream as **lake-of-rage#1580** — there should be a single canonical grade column with a closed vocabulary validated at write time. Until that lands, `grade_label` plus the guards above is the best available answer.

---

## 2. TCGplayer coverage starts at pd 6, not pd 0

**This is expected, not a defect.** TCGplayer's history in this table simply does not extend as far back as eBay's, and there is a coverage gap early on: only **130 distinct days across the 167-day span** from 2026-02-16, with **37 absent days, 2026-03-03 through 2026-04-21**, plus 23 days below a quarter of median volume (the 5th-percentile day has 2 sales). eBay has zero absent days over the same window.

Do not file it as an outage or read it as a market event — it is the shape of the data. The only thing it changes is where the panel can start.

Footprint on the 14-day panel (`pd = floor((date − 2026-02-01)/14)`):

| pd | Starts | TCGplayer | eBay | TCG share |
|---|---|---|---|---|
| ≤5 | — | ~0 | full | **0.1% at pd 5** |
| 6 | 2026-04-26 | 72,550 | 69,133 | 51.2% |
| 7 | 2026-05-10 | 71,283 | 86,996 | 45.0% |
| 8 | 2026-05-24 | 92,277 | 125,324 | 42.4% |
| 9 | 2026-06-07 | 119,426 | 108,229 | 52.5% |
| 10 | 2026-06-21 | 119,866 | 91,392 | 56.7% |
| 11 | 2026-07-05 | 116,510 | 105,871 | 52.4% |
| 12 | 2026-07-19 | 110,794 | **36,455** | 75.2% |

**Any cross-venue factor is undefined before pd 6.** At pd 5 TCGplayer contributes 48 sales against eBay's 48,836. Earlier venue-gap readings were computed on a degenerate sample and should not be trusted.

## 3. The newest period is under-ingested *and* corrupted

At pd 12 eBay volume falls to 36,455 from 105,871 — a 66% collapse with no market event behind it. Two causes, not one:

- **Ingest lag.** The most recent bar is still filling.
- **The `cardindex` writer regression (§2b).** It alone strips 57,790 eBay rows at pd 12 — **43% of what should be available** — by writing an `id_confidence` value the standard filter rejects.

**Always drop `max(pd)`.** A signal built on the newest bar reads both effects as a demand collapse. `scripts/panel.sql` bakes in `pd BETWEEN 6 AND 11`.

---

## 2b. A live writer regression is hiding 360k rows (filed: lake-of-rage#1580)

**Since 2026-06-29**, a `cardindex` writer path emits its own vocabulary for two columns at once: `grade_label='NM'`/`'LP'` instead of `raw_nm`/`raw_lp`, and **`id_confidence='cardindex_card_id'` instead of `'high'`.**

Identical date window (2026-06-29 → 2026-07-30), so recency cannot explain it:

| Venue | Encoding | Rows | % resolved |
|---|---|---|---|
| tcgplayer | `raw_nm`/`raw_lp` | 694,516 | **100.0%** |
| tcgplayer | `NM`/`LP` | 224,389 | **0.0%** |
| ebay | `raw_nm`/`raw_lp` | 262,522 | 73.9% |
| ebay | `NM`/`LP` | 132,674 | **0.0%** |

**Those rows are fully identified** — `tcg_card_id` is populated on 100% of them. Only the confidence tier is misspelled, so the canonical `id_confidence IN ('high','title_verified')` filter silently discards all **360,669**.

It is growing, not migrating: the `raw_*` path holds steady at ~38–40k rows/day while the bare path climbed from 3,883 (2026-06-29) to 14,273 (2026-07-06). Two writers running side by side.

**Until it is fixed, treat any period after pd 9 as under-counted by a growing margin.** If you need those rows before the upstream fix lands, the recovery filter is `id_confidence IN ('high','title_verified','cardindex_card_id')` together with `grade_label IN ('raw_nm','NM')` — but validate prices before trusting it, since that path has had no correctness audit.

---

## 4. Most "venues" are not secondary markets

`trade_type` is not a formality. Broken out:

| Venue | Composition |
|---|---|
| tcgplayer | secondary 2,475,734 · unknown 224,397 |
| ebay | secondary 4,289,688 · unknown 79,535 · fixed 53,926 · auction 16,081 |
| **renaiss** | primary 238,796 · buyback 236,587 · **secondary 5,823** · transfer 4,459 |
| **courtyard** | burn 58,031 · transfer 40,479 · **secondary 38,354** · buyback 13,240 |
| **beezie** | internal 55,829 · primary 42,282 · buyback 41,631 · transfer 533 · **secondary 0** |

This **retires the "900k blocked sales" figure.** Those venues are dominated by primary issuance, buybacks, NFT burns and internal transfers — not arms-length resale. Summing genuine `secondary` across every unresolved venue gives roughly **148k sales**, not 900k. Identity resolution there is still worth fixing, but it is a ~148k-row prize, and beezie/renaiss are nearly worthless for price discovery at any resolution rate.

Note also that `trade_type='secondary'` on eBay **discards 16,081 auctions and 53,926 fixed-price sales.** Auction closes are arguably the cleanest clearing prices in the dataset. The default filter is right for consistency, but that exclusion is a choice, not a given.

---

## 5. Lot sales exist, and their price is the *lot* price

`tx_id` groups multi-card transactions. 8,803,135 distinct transactions, 377,344 rows with no `tx_id`.

| Cards in tx | Transactions | Sales | All rows share one price | Median tx total |
|---|---|---|---|---|
| 1 | 8,746,869 | 8,746,869 | — | $5.73 |
| 2–3 | 26,448 | 60,281 | 27.7% | $125.99 |
| **4–10** | 28,680 | **198,990** | **85.9%** | $336.00 |
| 11–50 | 648 | 20,476 | 1.9% | $601.30 |
| 50+ | 490 | 35,303 | 0.0% | — |

In the 4–10 bucket, 86% of transactions stamp **one identical `price_usd` on every card in the lot** — median $48 per row against $5.73 for a genuine single-card sale. Treating those as individual sale prices inflates a card's median by roughly an order of magnitude.

**Currently harmless, structurally dangerous.** Multi-card transactions are 0.0% of eBay, TCGplayer and ebay_hk; they live entirely on beezie (40% multi-card, 3.03 cards/tx), courtyard (8.2%) and renaiss (6.7%) — venues already excluded for 0% identity resolution. **If the pipeline ever resolves those venues, this becomes an active contaminant on day one.** Guard with `count(*) OVER (PARTITION BY tx_id) = 1` before ingesting any new venue.

---

## 6. The two main venues have different price-formation processes

Modal prices since 2026-02-16:

| eBay | n | TCGplayer | n |
|---|---|---|---|
| $1.99 | 137,658 | $0.01 | 113,295 |
| $2.99 | 75,868 | $0.25 | 83,085 |
| $3.99 | 53,382 | $0.10 | 80,193 |
| $4.99 | 50,628 | $0.20 | 68,753 |
| $0.99 | 44,262 | $0.15 | 65,329 |

eBay clusters on psychological `.99` endings and is 27.2% whole-dollar — these are **seller-set asks that happened to clear.** TCGplayer's distribution is continuous and 63.6% of it is **under $1** (33.1% under 25¢) — a genuine bulk market.

Consequence: **an unconditional venue comparison is meaningless.** SV/ME raw NM medians by venue: TCGplayer **$0.19**, eBay **$10.00**. That 50× ratio is entirely mix, not basis. The venue gap is only interpretable per card with a minimum count on both sides (`ntcg>=4 AND neb>=4`), which is what `panel.sql` enforces.

It also explains the price stickiness noted in `methodology.md` differently: eBay prices are quantized to a small set of ask points, so week-over-week "no change" is partly a quoting convention rather than an absent market.

---

## 7. Sub-cent precision is an FX fingerprint

Share of rows whose `price_usd` has more than two decimal places:

| Venue | Sub-cent |
|---|---|
| ebay_hk | **99.68%** |
| mercari_jp | 77.81% |
| courtyard | 13.52% |
| renaiss | 13.20% |
| beezie | 3.96% |
| ebay | 0.73% |
| tcgplayer | 0.00% |

Anything above a few percent has been **converted from another currency**, at an unrecorded rate on an unrecorded date. Those prices carry FX noise on top of price noise, and a "move" in them may be a currency move. This is a cheap test to run on any new venue before trusting its levels.

---

## 8. Deep history exists but is not usable

eBay's first row is **2009-11-02**, not 2026. But identity resolution collapses going backwards:

| Year | eBay rows | ebay_hk | TCGplayer | Other | % resolved |
|---|---|---|---|---|---|
| 2021 | 15,451 | 7 | 0 | 2 | **0.1%** |
| 2022 | 59,092 | 22 | 0 | 123 | 0.1% |
| 2023 | 90,964 | 123 | 0 | 670 | 0.3% |
| 2024 | 167,522 | 72 | 0 | 2,360 | 0.4% |
| 2025 | 477,094 | 1,149 | 0 | 12,831 | 10.9% |
| 2026 | 4,620,646 | 368,386 | 2,700,131 | 922,550 | **55.1%** |

~810k pre-2026 eBay rows exist at **under 1% resolution** — present, unmappable, and useless for card-level work. The honest statement is not "the data starts in 2026"; it is **"the data becomes joinable in 2026."** Backfilling identity on 2024–2025 eBay is the only route to a second market regime, and a second regime is the single largest missing ingredient for everything in `findings.md`.

---

## 9. Variant contamination, measured

Multiple printings share one `tcg_card_id`. Now quantified rather than assumed, using eBay titles on SV/ME raw sales:

- **Reverse holos are 7.7% of eBay raw SV/ME sales** (51,142 of 664,845).
- Across 638 cards with ≥10 sales each way, the reverse-vs-base median price ratio is **1.000** (p25 0.905, p75 1.137).
- But **21.9% of those cards differ by more than 30%.**

So contamination is *unbiased in aggregate and severe in the tail*. Pooling is fine for set-level work; for single-card level estimates it is a coin flip whether the card is one of the ~1-in-5 where the two printings are materially different assets sharing an ID.

**Japanese cards are a non-issue in this era.** 6.4% of all Pokémon eBay titles mention Japan, but within SV/ME **no card** reaches 10 Japanese-titled raw sales.

Title mining only works on eBay: **`title` is NULL on 91.7% of TCGplayer rows** and 0.0% of eBay rows.

---

## 10. Identity keys and taxonomy are messier than they look

- **`variant` in `card_rollup` is empty.** One distinct value (the empty string) across 4,692 SV/ME cards, plus 325 NULLs. It cannot be used to separate printings.
- **`name` + `set_id` is not unique.** 5,017 SV/ME cards collapse to 3,762 distinct name+set pairs — ~25% share a name and set with another `tcg_card_id`. Always join on `tcg_card_id`.
- **`rarity` casing is inconsistent.** `MEGA_ATTACK_RARE` (7 cards) sits beside `Mega Hyper Rare` (8 cards) and `Special Illustration Rare`. 420 SV/ME cards have NULL rarity. Any rarity filter must be case- and separator-tolerant.
- `sale_id` **is** unique — 9,439,263 rows, 9,439,263 distinct. No dedup pass needed.

---

## 11. Liquidity is concentrated, and the liquid cards are not raw

SV/ME, resolved secondary sales since 2026-02-01:

| Sales per card | Cards | Sales | % of all sales | % of those sales raw NM |
|---|---|---|---|---|
| <10 | 10 | 20 | 0.0% | 20.0% |
| 10–49 | 61 | 2,382 | 0.1% | 72.2% |
| 50–199 | 1,495 | 230,758 | 14.0% | 55.4% |
| 200–999 | 2,768 | 1,031,521 | 62.4% | 35.4% |
| 1000+ | 266 | 387,936 | 23.5% | **15.5%** |

Note the inversion: **the more a card trades, the less of its volume is raw NM.** The 266 highest-volume cards are 84.5% graded or off-condition. High headline volume therefore does *not* imply a well-measured raw price — the two are anticorrelated.

Only **595 SV/ME cards** carry ≥180 raw NM sales, which is the realistic universe for card-level raw price work at 14-day resolution.

---

## 12. Weekday seasonality is negligible

Volume is flat across weekdays (102.8k–111.2k TCGplayer, 101.4k–122.7k eBay). Saturday runs modestly heavier on eBay with a median of $8.81 against $8.00 elsewhere — consistent with a slight weekend mix shift toward pricier cards. Not worth adjusting for at 14-day resolution; worth remembering if anyone builds a daily model.
