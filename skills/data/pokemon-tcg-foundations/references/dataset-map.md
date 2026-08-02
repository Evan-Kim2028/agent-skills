# Dataset map

Location: `~/data/pokemontcg_pipe/gold/` on `lor-main`. Reach it via `lake-vps` → `lor-main` (see `scripts/q.sh`).

Verified 2026-08-02.

## Tables

| Table | Size / rows | Freshness | Use |
|---|---|---|---|
| `card_sales_history.parquet` | 451 MB, **9,439,263** pokemon sales | fresh | **Ground truth.** Sale-level tape. Everything real comes from here |
| `card_rollup.parquet` | 25k+ cards | fresh | Identity (name, set_id, card_number, rarity) + precomputed aggregates |
| `pop_gold.parquet` | 537,829 | — | Population, mixed graders |
| `pkmn_population.parquet` | 147,585 (5,226 on SV/ME) | — | Population |
| `pop_cgc.parquet` | 67,011 | — | CGC population |
| `pop_psa.parquet` | **0 rows** | — | **Empty.** PSA population absent |
| `listings.parquet` | 7,807 | **stale 2026-06-18** | Ask-side. `ask_price_usd`, `is_active`, `delisted_at`, `observed_at`, `quality_score` |
| `reference_price_daily` | — | stale 2026-07-01 | — |
| `market_price_series` | — | stale 2026-07-21 | — |
| sealed product | **does not exist** | — | — |

## `card_sales_history` columns

```
sale_id, sold_at (TIMESTAMPTZ), price_usd, source, marketplace, tx_id,
grader, grade_num, grade_label, condition, url, title, trade_type,
tcg_card_id, game, id_confidence
```

Filters that matter:

- `game='pokemon'`
- `id_confidence IN ('high','title_verified')` — **mandatory**; anything else is unmapped
- `trade_type='secondary'` — excludes `buyback` (291k), `primary` (281k), `burn`, `internal`, `transfer`. Note it also drops 16,081 eBay `auction` and 53,926 eBay `fixed` rows, and 224,397 TCGplayer `unknown`
- raw = `(grader IS NULL OR grader='RAW')`
- **NM = `grade_label='raw_nm'`, not `condition='NM'`** — see `data-quality.md` §1

`tx_id` groups multi-card transactions. Audited: 8,803,135 distinct, 377,344 NULL. Multi-card lots stamp one lot price on every row (86% of 4–10-card txs) but occur **only** on beezie/courtyard/renaiss, all of which are excluded anyway. `data-quality.md` §5.

**`sale_id` is unique** — 9,439,263 rows, 9,439,263 distinct. No dedup pass required.

## Venue coverage and identity resolution

The single most important table in this file. Since 2026-02-01:

| marketplace | source | total sales | resolved | **% resolved** | median px |
|---|---|---|---|---|---|
| ebay | ebay | 4,500,638 | 1,973,710 | **43.9%** | $8.00 |
| tcgplayer | tcgplayer | 2,700,131 | 2,475,734 | **91.7%** | $0.44 |
| renaiss | bsc | 487,191 | 0 | **0%** | $48.00 |
| ebay_hk | ebay | 368,209 | 278,381 | 75.6% | $8.63 |
| courtyard | polygon | 163,496 | 0 | **0%** | $20.30 |
| beezie | base | 140,406 | 0 | **0%** | $46.95 |
| fanatics | fanatics | 65,369 | 0 | **0%** | $28.80 |
| mercari_jp | mercari_jp | 19,271 | 0 | **0%** | $9.32 |
| dyli | abstract | 10,841 | 0 | **0%** | $2.00 |
| alt_xyz | alt_xyz | 5,898 | 0 | **0%** | $105.00 |
| goldin | goldin | 3,079 | 0 | **0%** | $380.64 |
| collector_crypt | solana | 1,921 | 0 | **0%** | $65.00 |
| magic_eden, goldsky_turbo_cc, phygitals, heritageauctions, ebay_ca, rea, ebay_de | — | <2k each | 0 | 0% | — |

**Only three venues are usable: `tcgplayer`, `ebay`, `ebay_hk`.** Everything else is present and unresolvable.

**And most of the rest are not secondary markets at all.** By `trade_type`: renaiss is 98.8% primary/buyback (only 5,823 secondary), courtyard is mostly burn/transfer (38,354 secondary), beezie has **zero** secondary rows. Genuine secondary volume across every unresolved venue totals **~148k sales, not ~900k**. See `data-quality.md` §4.

**History depth vs usable history.** eBay rows go back to 2009-11-02, but identity resolution collapses backwards: 0.1% in 2021–22, 0.3–0.4% in 2023–24, 10.9% in 2025, 55.1% in 2026. ~810k pre-2026 eBay rows are present and unmappable. The data does not *start* in 2026; it becomes *joinable* in 2026.

**Pipeline gaps.** TCGplayer covers only 130 of 167 calendar days — **37 missing days, 2026-03-03 → 2026-04-21**, plus 23 more below quarter-volume. eBay has zero missing days. The newest 14-day period is always under-ingested (eBay −66%). `data-quality.md` §2–3.

`ebay_hk` is a **separate price regime** (~3× lower on comparable cards). Exclude it from US-market work unless you are explicitly studying it. It shows the strongest lead over eBay in the cross-venue matrix (0.083) but on a small, non-comparable base — do not trade it without further work.

## Grader and condition distribution (last 120d)

| grader | n | | condition | n |
|---|---|---|---|---|
| (null) | 3,759,773 | | (null) | 4,343,253 |
| RAW | 2,429,171 | | NM | 2,135,834 |
| PSA | **1,080,224** | | LP | **691,553** |
| CGC | 236,699 | | MP | 234,872 |
| TAG | 27,474 | | DMG | 79,486 |
| BGS | 26,699 | | HP | 72,159 |
| ACE | 19,264 | | unknown | 24,384 |
| SGC, AGS, GMA, … | <5k each | | Japanese strings | ~5k |

Japanese condition strings (`目立った傷や汚れなし` etc.) appear — filter explicitly rather than assuming a closed set.

**Do not filter to NM-raw reflexively.** The 691k LP sales carry the condition-substitution signal (LP/NM ratio change, IC +0.152) and the 1.08M PSA sales lead raw (IC +0.230). Filtering them out was the single largest analytical error made on this dataset.

**`condition` is the wrong column for NM.** It is NULL on 69.0% of eBay rows, 23.9% of TCGplayer, and 100% of renaiss/courtyard/beezie. Use `grade_label` — vocabulary `raw_nm` / `raw_lp` / `raw_mp` / `raw_hp` / `raw_dmg` / `raw_unknown`, plus a secondary bare `NM` / `LP` convention on a minority of rows. Full comparison in `data-quality.md` §1.

## `card_rollup` — precomputed columns

Includes `tvwap_*` (time-weighted VWAP with staleness/confidence/momentum/prediction bands), `psa10_*`/`psa9_*`/`psa8_*` prices and sale counts, rolling `volume_/sales_{7,30,90,180}d`, `nm_price_usd`/`lp_price_usd`/`mp_price_usd`, `rarity`, `set_id`, `variant`, `quality_flags`, `identity_confidence`, `sales_trend_pct`.

These are convenient but **not audited** — the SKILL's measured results all come from re-deriving from `card_sales_history`. Treat rollup columns as hints, verify before trusting in a backtest.

Two rollup identity caveats, both measured on the 5,017 SV/ME cards:

- **`variant` is empty.** One distinct value (the empty string) plus 325 NULLs. It cannot separate printings.
- **`name` + `set_id` is not a key.** 5,017 cards collapse to 3,762 distinct name+set pairs. Always join on `tcg_card_id`.
- **`rarity` casing is inconsistent** — `MEGA_ATTACK_RARE` beside `Mega Hyper Rare`; 420 NULLs. Make rarity filters case- and separator-tolerant.

## SV / Mega Evolution era set IDs

```
sv1, sv2, sv3, sv3pt5, sv4, sv4pt5, sv5, sv6, sv6pt5, sv7, sv8, sv8pt5,
sv9, sv10, rsv10pt5, zsv10pt5, svp, me1, me2, me2pt5, me3, me4, me5
```

`rsv10pt5` = Prismatic/White Flare cohort, `zsv10pt5` = Black Bolt cohort — the two strongest sets in the Feb–Aug 2026 window.

## Card URLs

`https://silphcoanalytics.xyz/card/<tcg_card_id>` (verified 200). `/cards/<id>` 301-redirects there. Frontend route: `~/silphcoanalytics/frontend/src/routes/cards.$id.tsx` on `lake-vps`.

## Environment gotchas

- DuckDB 1.5.3 on `lor-main`, no numpy, **no pytz**. `date_trunc('week', ...)` and `max(sold_at)` on a TIMESTAMPTZ **fail** with "Required module 'pytz' failed to import".
  - Workaround: hardcode the as-of date (`DATE '2026-08-02'`) and use integer arithmetic for buckets:
    `CAST(floor((CAST(sold_at AS DATE) - DATE '2026-02-01')/14.0) AS INT)`. The `floor(.../14.0)` matters — integer division without it yields fractional buckets.
- Each `q.sh` invocation is a **fresh in-memory DuckDB**. Tables do not persist between calls. Append to one script rather than chaining calls.
- Reserved words that fail as aliases: `sets`, `both`, `trailing`, `dec`.
- `q.sh` splits statements on a doubled semicolon. **Never write that token inside a comment or string literal** — it truncates the file mid-statement and produces a confusing parser error.
- `head -n -N script.sql` to truncate trailing statements is fragile — it cuts mid-statement and produces cascading "table does not exist" errors. Find the boundary with `grep -n "^CREATE" script.sql` first.
