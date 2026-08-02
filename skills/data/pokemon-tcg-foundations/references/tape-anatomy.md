# Anatomy of a card sales tape

What these datasets contain, which columns carry the signal, and what to profile before writing an analytical query.

Concrete names and numbers live in [`reference-implementation.md`](reference-implementation.md). This file is about **roles**, so it transfers.

---

## The core table

One row per sale. The columns that matter, by role:

| Role | Typical names | Why it matters |
|---|---|---|
| **Sale key** | `sale_id` | Check uniqueness before assuming you need a dedup pass. Also check whether *twins* exist — the same real sale ingested twice under different keys. |
| **Timestamp** | `sold_at` | Often TIMESTAMPTZ, which breaks naive date bucketing (see below). |
| **Price** | `price_usd` | Check the decimal precision distribution — it fingerprints FX conversion. |
| **Venue** | `marketplace`, `source` | Usually two levels: the marketplace and the upstream feed. They are not the same field. |
| **Transaction key** | `tx_id`, `order_id` | Groups multi-card lots. **Absent or ignored is the #1 cause of inflated card prices.** |
| **Card identity** | `tcg_card_id`, `product_id` | The join key. Never join on name+set. |
| **Identity confidence** | `id_confidence` | How the row was mapped to a card. **The most important filter in the table**, and the one most likely to gain a surprise value. |
| **Trade type** | `trade_type` | Separates arms-length resale from issuance, buybacks, burns, transfers. |
| **Grade / condition** | `grade_label`, `condition`, `grader`+`grade_num` | Expect more than one encoding. See `data-quality.md` §1. |
| **Listing text** | `title` | The only route to variant/printing detection — and usually populated on one venue only. |

### Derived fields you will need

- **Period bucket.** 14-day or monthly. Integer arithmetic from a fixed epoch date, not `date_trunc` — timezone-aware timestamps frequently fail in slim analytical environments.
- **Era.** Grouped from the set identifier. See `sparsity-and-eras.md`; this drives more variation than almost anything else.
- **Raw vs graded.** From the grader column, not the condition column.
- **Single-card flag.** `count(*) OVER (PARTITION BY <transaction key>) = 1`.

## Companion tables

Expect some subset, and expect several to be stale or empty. **Check, don't assume.**

| Table | What it gives you | Typical state |
|---|---|---|
| Card rollup / catalogue | Identity — name, set, number, rarity — plus precomputed aggregates | Fresh, but aggregates are usually **unaudited** |
| Population reports | Graded supply by grader and grade | Partial; at least one grader's table is often empty |
| Listings / asks | `ask_price`, `is_active`, `delisted_at` | Frequently stale. **The only true leading indicator** — sales say what cleared, listings say what is about to |
| Reference price series | Precomputed daily/weekly marks | Stale, and circular if you backtest against them |
| Sealed product | — | Usually absent |

**Rule: re-derive from the sale-level tape.** Precomputed rollup columns encode someone else's filter choices, and those choices are exactly what `data-quality.md` says are usually wrong. Use rollups as hints; verify before trusting one in a backtest.

---

## What to profile first

Nine queries, before any analysis. `scripts/profile.sql` runs them all. Profiles 1–5 tell you whether the tape is usable; profiles 6–9 tell you which model classes it can support (`asset-class-properties.md`).

### 1. Venue usability

Two independent gates, and most venues fail one:

```sql
SELECT venue,
       count(*) total,
       round(100.0*count(*) FILTER (WHERE <identity resolved>)/count(*),1) pct_resolved,
       count(*) FILTER (WHERE trade_type='secondary') genuine_secondary
FROM sales GROUP BY 1 ORDER BY total DESC;
```

A venue is usable only if **both** are high. A venue with 500k rows, 0% resolution and 1% secondary contributes nothing, and its raw row count will tempt you into thinking otherwise.

### 2. Condition/grade encodings

Enumerate every candidate column's distinct values **and cross-tabulate them against each other**. You are looking for: competing vocabularies, contradictions, out-of-range grades, and untranslated source-locale strings.

```sql
SELECT col_a, col_b, count(*) FROM sales GROUP BY 1,2 ORDER BY 3 DESC;
```

If distinct-value count is in the hundreds, a parser is leaking non-grades into the field.

### 3. Coverage, per venue, per period

**Count distinct days, not rows.** Rows hide gaps; a venue at 10% of normal volume looks fine on a row count.

```sql
SELECT venue, pd, count(DISTINCT sale_date) days, count(*) n
FROM sales GROUP BY 1,2 ORDER BY 1,2;
```

Compare against the calendar. Set your panel's lower bound at the first period where every venue you need is adequately covered, and its upper bound one period back from the maximum.

**Also profile distinct values of every filter column by month.** A vocabulary that gains a value mid-series is a writer regression (`data-quality.md` §2b), and it is invisible any other way.

### 4. Panel sparsity, by era

```sql
SELECT era,
       count(DISTINCT card_id) cards,
       round(100.0*count(*) FILTER (WHERE n_sales>=8)/count(*),1) pct_cells_filled
FROM card_period_cells GROUP BY 1;
```

If this is below ~50% for any era you care about, a naive panel is not viable there and you need the reconstruction in `sparsity-and-eras.md`. Run it **both** for best-condition-only and for condition-pooled — the gap between them is the value of reconstruction on your tape.

### 5. Measurement noise ceiling

Split each card-period's sales into halves by a hash of the sale key, estimate independently, correlate across cells, and apply Spearman-Brown (`2r/(1+r)`).

This number bounds every result you will ever get. If reliability is 0.70, then 30% of a measured momentum figure is sampling noise and your correlation with *true* momentum cannot exceed √0.70 ≈ 0.84. **Establish it before choosing a model class** — it is usually the reason a fancier estimator doesn't help.

### 6. Observation endogeneity

Regress *presence*, not price. Bucket card-periods by this period's return and by price level, then measure how often the cell reappears next period.

If either curve is not flat, your panel is selected on the outcome and a plain forward-return regression is fit on a biased subsample (`methodology.md` trap 13). **Exclude the final period** — it has no successor in the window, so its survival is mechanically zero.

### 7. Universe churn

What fraction of the cards present at the end of the window did not exist at the start? That is the share of the market a history-requiring model cannot score. In this asset class it is normally double digits per quarter, which is the case for hierarchical models over per-card ones.

### 8. Weighting divergence

Compute equal-weight, dollar-weight and median over the same universe and window. Report which you chose. Confirm the dollar weight uses the price at the **start** of the return window — using the end price is lookahead and reliably flips the sign.

### 9. Chase concentration

Per set, the top 3 cards' share of dollar volume. This is the second breadth collapse: cards move with their set, and the set moves with a handful of cards. It is why `IR = IC × √breadth` should use something near the set count, not the row count.

---

## Filters that matter, in order

1. **Identity confidence** — mandatory. Unmapped rows cannot be joined to a card.
2. **Trade type** — `secondary` only, unless you are deliberately studying issuance. Note this usually also discards auctions, which are arguably the cleanest clearing prices in the tape.
3. **Venue allowlist** — the usable set from profile 1, minus any venue in a different currency/price regime.
4. **Grade/condition** — the *complete* encoding, never the "unknown" bucket.
5. **Single-card transactions** — unless you are reconstructing lot values.
6. **Period bounds** — from profile 3.
7. **Positive price.**

**Do not reflexively filter to best-condition raw.** The rows you drop carry signal that raw prices do not: played-condition sales give the condition-substitution factor, graded sales lead raw prices. Filter them out of your *price estimate*, keep them in your *feature set*. Conflating those two was the single largest analytical error made on the reference implementation.
