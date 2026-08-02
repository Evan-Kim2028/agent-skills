# Reference implementation

**Everything in this file is specific to one deployment.** It is here so the rest of the skill can stay generic: when another file says "the identity-confidence column" or "the anchor venue," this is where that resolves to a concrete name.

If you are working on a different tape, read this as a **worked example of what to go find** in yours — not as configuration.

Verified 2026-08-02.

---

## The instance

A Pokémon TCG market-intelligence lakehouse (`silphcoanalytics` / `lake-of-rage`), DuckDB 1.5.3 over Parquet gold tables.

| | |
|---|---|
| Location | `~/data/pokemontcg_pipe/gold/` on host `lor-main` |
| Access | double-hop SSH: local → `lake-vps` → `lor-main` (wrapped in `scripts/q.sh`) |
| Scale | 9,439,263 Pokémon sales |
| Span | eBay rows from 2009-11-02; **joinable** from 2026 |
| Card catalogue | 66,855 cards across 605 sets |
| Frontend | `https://silphcoanalytics.xyz/card/<tcg_card_id>` |

## Tables

| Table | Size / rows | Freshness | Use |
|---|---|---|---|
| `card_sales_history.parquet` | 451 MB, **9,439,263** | fresh | **Ground truth.** Sale-level tape. Everything real comes from here |
| `card_rollup.parquet` | 66,855 cards | fresh | Identity (name, set_id, card_number, rarity) + precomputed aggregates |
| `pop_gold.parquet` | 537,829 | — | Population, mixed graders |
| `pkmn_population.parquet` | 147,585 | — | Population |
| `pop_cgc.parquet` | 67,011 | — | CGC population |
| `pop_psa.parquet` | **0 rows** | — | **Empty.** PSA population absent (PSA *prices* are not) |
| `listings.parquet` | 7,807 | **stale 2026-06-18** | Ask-side. `ask_price_usd`, `is_active`, `delisted_at`, `observed_at` |
| `reference_price_daily` | — | stale 2026-07-01 | — |
| `market_price_series` | — | stale 2026-07-21 | — |
| sealed product | **does not exist** | — | — |

`card_rollup` also carries `tvwap_*`, `psa10_*`/`psa9_*`/`psa8_*`, rolling `volume_/sales_{7,30,90,180}d`, `nm_/lp_/mp_price_usd`, `quality_flags`, `sales_trend_pct`. **These are convenient but unaudited** — every measured result in this skill was re-derived from `card_sales_history`. Treat rollup columns as hints.

## Column mapping

Generic role → concrete column in `card_sales_history`:

| Generic role (used elsewhere in this skill) | Column here |
|---|---|
| sale key | `sale_id` (unique — 9,439,263 of 9,439,263; no dedup needed) |
| timestamp | `sold_at` (TIMESTAMPTZ) |
| price | `price_usd` |
| venue | `marketplace` (also `source` — upstream feed) |
| transaction key (lot grouping) | `tx_id` (8,803,135 distinct, 377,344 NULL) |
| card identity key | `tcg_card_id` |
| identity confidence | `id_confidence` |
| trade type | `trade_type` |
| grade / condition | **`grade_label`** (use this) and `condition` (do not) |
| grader / numeric grade | `grader`, `grade_num` |
| listing text | `title` (**NULL on 91.7% of TCGplayer rows**, 0.0% of eBay) |

Raw = `(grader IS NULL OR grader='RAW')`. Best condition = `grade_label='raw_nm'`, **not** `condition='NM'`.

## The canonical filter

```sql
WHERE game = 'pokemon'
  AND price_usd > 0
  AND id_confidence IN ('high','title_verified')   -- mandatory; else unmapped
  AND trade_type = 'secondary'                     -- excludes primary/buyback/burn/internal/transfer
  AND marketplace IN ('tcgplayer','ebay')          -- ebay_hk is a different regime
  AND grade_label = 'raw_nm'                       -- NOT condition='NM'
  AND CAST(sold_at AS DATE) >= DATE '2026-02-01'
-- then: keep pd BETWEEN 6 AND 11
```

Every clause is load-bearing; reasons in [`data-quality.md`](data-quality.md).

**Recovery filter while lake-of-rage#1580 is open** — to include the `cardindex` writer's rows, add `'cardindex_card_id'` to the `id_confidence` list and `'NM'` to the grade list. Validate prices before trusting it; that path has had no correctness audit.

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
| alt_xyz | alt_xyz | 5,898 | 0* | **0%*** | $105.00 |
| goldin | goldin | 3,079 | 0 | **0%** | $380.64 |
| collector_crypt | solana | 1,921 | 0 | **0%** | $65.00 |
| magic_eden, goldsky_turbo_cc, phygitals, heritageauctions, ebay_ca, rea, ebay_de | — | <2k each | 0 | 0% | — |

**Only three venues are usable: `tcgplayer`, `ebay`, `ebay_hk`.**

\* **`alt_xyz` is mismeasured by that filter.** Since 2026-07-02 its writer puts a numeric score in `id_confidence` (`'0.85'`, `'1.0'`, `'0.9'` — 4,217 rows), all with `tcg_card_id` populated. It is fully mapped under an encoding the canonical filter does not know. Second breach of this column in five weeks; see [`data-quality.md`](data-quality.md) §2. Any other "0% resolved" row here deserves the same re-check.

- **Anchor** = `tcgplayer` under ~$25; `ebay` above ~$100. **Follower** = the other.
- `ebay_hk` is a **separate price regime** (~3× lower, 99.7% FX-converted). Exclude from US-market work. It shows the strongest lead over eBay in the cross-venue matrix (0.083) but on a small, non-comparable base.
- Genuine `secondary` volume across all unresolved venues totals **~148k**, not the ~900k raw counts suggest.

**Resolution collapses backwards in time:** 0.1% (2021–22), 0.3–0.4% (2023–24), 10.9% (2025), 55.1% (2026). ~810k pre-2026 eBay rows are present and unmappable. The data does not *start* in 2026; it becomes *joinable* in 2026.

## Period definition

`pd = floor((date − 2026-02-01) / 14)`. **Usable range: `pd BETWEEN 6 AND 11`** (2026-04-26 → 2026-07-19).

- Lower bound: TCGplayer coverage. At pd 5 it contributes 48 sales against eBay's 48,836.
- Upper bound: newest-period ingest lag plus the #1580 regression.

**Re-derive both bounds on every refresh** — the upper one moves every time.

## Era mapping (by `set_id` prefix)

| Era | Prefixes |
|---|---|
| `1_vintage_wotc` | base, gym, neo, si, ecard |
| `2_mid_ex_dp` | ex, pop, np, dp, pl, hgss, hsp, col |
| `3_bw_xy_sm` | bw, xy, g1, sm, det |
| `4_swsh` | swsh, cel, pgo |
| `5_sv_me` | sv, me |

```sql
CASE
  WHEN regexp_matches(set_id,'^(base|gym|neo|si|ecard)') THEN '1_vintage_wotc'
  WHEN regexp_matches(set_id,'^(ex|pop|np|dp|pl|hgss|hsp|col)') THEN '2_mid_ex_dp'
  WHEN regexp_matches(set_id,'^(bw|xy|g1|sm|det)') THEN '3_bw_xy_sm'
  WHEN regexp_matches(set_id,'^(swsh|cel|pgo)') THEN '4_swsh'
  WHEN regexp_matches(set_id,'^(sv|me)') THEN '5_sv_me'
  ELSE '9_other' END era
```

`9_other` ≈ 3k cards: Japanese set IDs (`SM8b`, `S1W`, `CP6`, `SV4a`), One Piece promos (`OP-PR`), plus 14,032 cards with blank `set_id`. Different markets — exclude.

**SV / Mega Evolution set IDs:**
```
sv1, sv2, sv3, sv3pt5, sv4, sv4pt5, sv5, sv6, sv6pt5, sv7, sv8, sv8pt5,
sv9, sv10, rsv10pt5, zsv10pt5, svp, me1, me2, me2pt5, me3, me4, me5
```
`rsv10pt5` = Prismatic/White Flare cohort, `zsv10pt5` = Black Bolt cohort — the two strongest sets in the Feb–Aug 2026 window.

## Identity caveats

- **`variant` is empty** — one distinct value (empty string) plus 325 NULLs across 4,692 SV/ME cards. Cannot separate printings.
- **`name` + `set_id` is not a key** — 5,017 SV/ME cards collapse to 3,762 distinct pairs. Always join on `tcg_card_id`.
- **`rarity` casing is inconsistent** — `MEGA_ATTACK_RARE` beside `Mega Hyper Rare`; 420 NULLs. Make rarity filters case- and separator-tolerant.

## Environment gotchas

- DuckDB 1.5.3 on `lor-main`, **no numpy, no pytz.** `date_trunc('week', ...)` and `max(sold_at)` on a TIMESTAMPTZ **fail** with `Required module 'pytz' failed to import`.
  - Workaround: hardcode the as-of date and bucket with integer arithmetic —
    `CAST(floor((CAST(sold_at AS DATE) - DATE '2026-02-01')/14.0) AS INT)`.
    The `/14.0` matters; integer division yields fractional buckets.
- Each `q.sh` invocation is a **fresh in-memory DuckDB.** Tables do not persist between calls — append to one script rather than chaining.
- `q.sh` splits statements on a **doubled semicolon.** Never write that token inside a comment or string literal; it truncates the file mid-statement and produces a confusing parser error.
- Reserved words that fail as aliases: `sets`, `both`, `trailing`, `dec`, `rows`, `days`.
- `q.sh` also executes the **trailing fragment after the last `;;`**. A comment-only tail errors with `'NoneType' object has no attribute 'description'`. Put closing notes above the final statement.
- `SET enable_progress_bar=false` as the first statement, or the progress bar pollutes captured output.
- `head -n -N script.sql` to drop trailing statements is fragile — it cuts mid-statement and cascades "table does not exist". Find boundaries with `grep -n "^CREATE"` first.

## Open upstream issues

- [lake-of-rage#1580](https://github.com/Evan-Kim2028/lake-of-rage/issues/1580) — no canonical grade column; `cardindex` writer regression hiding 360,669 rows. **Live.**
- #993 — grade_label backfill + requality sweep.
- #1249 — BGS Black Label / CGC Pristine collapse to plain 10s.
