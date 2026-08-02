-- Profile a card sales tape before writing a single analytical query.
-- Implements the five profiles in references/tape-anatomy.md.
--
-- THIS IS REFERENCE-IMPLEMENTATION CODE. The table and column names below are
-- specific to the lakehouse in references/reference-implementation.md. On
-- another tape, substitute using the generic-role -> column map in that file:
--
--   card_sales_history -> your sale-level table
--   sale_id            -> sale key
--   sold_at            -> timestamp
--   price_usd          -> price
--   marketplace        -> venue
--   tx_id              -> transaction key (lot grouping)
--   tcg_card_id        -> card identity key
--   id_confidence      -> identity confidence
--   trade_type         -> trade type
--   grade_label        -> grade / condition (and `condition`, the rival encoding)
--
-- Run with: ./q.sh < profile.sql
-- q.sh splits statements on a doubled semicolon, so never write that token
-- inside a comment or string literal - it truncates the file mid-statement.
--
-- AS-OF DATE IS HARDCODED (no pytz on lor-main). Update EPOCH below to your
-- own window start, and re-derive every bound this script reports.

SET enable_progress_bar=false;;

CREATE OR REPLACE VIEW s AS
SELECT *,
       CAST(sold_at AS DATE) AS d,
       CAST(floor((CAST(sold_at AS DATE) - DATE '2026-02-01')/14.0) AS INT) AS pd
FROM 'card_sales_history.parquet'
WHERE game = 'pokemon' AND CAST(sold_at AS DATE) >= DATE '2026-02-01';;

-- 0. Sale-key uniqueness. If these differ, you need a dedup pass before
--    anything else, and you should also look for twins - the same real sale
--    ingested twice under different keys.
SELECT count(*) n_rows, count(DISTINCT sale_id) distinct_keys FROM s;;

-- 1. VENUE USABILITY. Two independent gates; most venues fail one.
--    A venue is usable only if BOTH pct_resolved and genuine_secondary are
--    high. Raw row count is a trap - a 500k-row venue at 0% resolution and
--    1% secondary contributes nothing.
SELECT marketplace, source,
       count(*) total,
       round(100.0*count(*) FILTER (WHERE id_confidence IN ('high','title_verified'))
             /count(*),1) pct_resolved,
       count(*) FILTER (WHERE trade_type='secondary') genuine_secondary,
       round(median(price_usd),2) median_px,
       -- sub-cent precision fingerprints FX conversion -> separate price regime
       round(100.0*count(*) FILTER (WHERE price_usd*100 <> floor(price_usd*100))
             /count(*),2) pct_subcent
FROM s GROUP BY 1,2 ORDER BY total DESC;;

-- 2a. CONDITION / GRADE ENCODINGS. Enumerate every candidate column.
--     Hundreds of distinct values means a parser is leaking non-grades in.
SELECT 'grade_label' col, count(DISTINCT grade_label) n_distinct,
       round(100.0*count(*) FILTER (WHERE grade_label IS NULL)/count(*),2) pct_null FROM s
UNION ALL
SELECT 'condition', count(DISTINCT condition),
       round(100.0*count(*) FILTER (WHERE condition IS NULL)/count(*),2) FROM s;;

-- 2b. CROSS-TABULATE the rival encodings. You are looking for contradictions,
--     out-of-range grades, and untranslated source-locale strings.
SELECT condition, grade_label, count(*) n
FROM s GROUP BY 1,2 ORDER BY 3 DESC LIMIT 40;;

-- 2c. WHICH ENCODING TO PICK. Agreement on price plus disagreement on count
--     means one column is simply more complete - take the fuller one.
SELECT marketplace,
       count(*) FILTER (WHERE grade_label='raw_nm') n_grade_label,
       count(*) FILTER (WHERE condition='NM')      n_condition,
       round(median(price_usd) FILTER (WHERE grade_label='raw_nm'),2) px_grade_label,
       round(median(price_usd) FILTER (WHERE condition='NM'),2)       px_condition
FROM s WHERE marketplace IN ('tcgplayer','ebay') GROUP BY 1;;

-- 3a. COVERAGE, per venue, per period. COUNT DISTINCT DAYS, NOT ROWS.
--     Rows hide gaps; a venue at 10% of normal volume looks fine on a count.
--     Set the panel's lower bound at the first period where every venue you
--     need is adequately covered, and the upper bound one period back from max.
SELECT marketplace, pd, min(d) first_day, max(d) last_day,
       count(DISTINCT d) n_days, count(*) n
FROM s WHERE marketplace IN ('tcgplayer','ebay')
GROUP BY 1,2 ORDER BY 1,2;;

-- 3b. WRITER-REGRESSION CANARY. Distinct values of every filter column, by
--     month. A vocabulary that GAINS a value mid-series is a new writer
--     emitting an unknown encoding, and correct rows are silently invisible
--     to your filter. This is invisible any other way. See data-quality.md 2.
SELECT date_trunc('month', d) mo, id_confidence, count(*) n
FROM s GROUP BY 1,2 ORDER BY 1,3 DESC;;

-- 4. PANEL SPARSITY, BY ERA - best-condition-only vs condition-pooled.
--    The gap between the two columns is the value of reconstruction on your
--    tape (sparsity-and-eras.md). Below ~50% for an era you care about means
--    a naive best-condition panel is not viable there.
CREATE OR REPLACE VIEW se AS
SELECT *, CASE
  WHEN regexp_matches(set_id,'^(base|gym|neo|si|ecard)') THEN '1_vintage_wotc'
  WHEN regexp_matches(set_id,'^(ex|pop|np|dp|pl|hgss|hsp|col)') THEN '2_mid_ex_dp'
  WHEN regexp_matches(set_id,'^(bw|xy|g1|sm|det)') THEN '3_bw_xy_sm'
  WHEN regexp_matches(set_id,'^(swsh|cel|pgo)') THEN '4_swsh'
  WHEN regexp_matches(set_id,'^(sv|me)') THEN '5_sv_me'
  ELSE '9_other' END era
FROM s JOIN 'card_rollup.parquet' USING (tcg_card_id)
WHERE id_confidence IN ('high','title_verified')
  AND trade_type='secondary' AND price_usd > 0
  AND marketplace IN ('tcgplayer','ebay')
  AND pd BETWEEN 6 AND 11;;

CREATE OR REPLACE TABLE cell AS
SELECT era, tcg_card_id, pd,
       count(*) FILTER (WHERE grade_label='raw_nm') n_best,
       count(*) FILTER (WHERE grade_label LIKE 'raw_%'
                          AND grade_label <> 'raw_unknown') n_pooled
FROM se GROUP BY 1,2,3;;

SELECT era,
       count(DISTINCT tcg_card_id) cards,
       round(100.0*count(*) FILTER (WHERE n_best   >= 8)/count(*),1) pct_best_filled,
       round(100.0*count(*) FILTER (WHERE n_pooled >= 8)/count(*),1) pct_pooled_filled
FROM cell GROUP BY 1 ORDER BY 1;;

-- 5. MEASUREMENT NOISE CEILING. Split each card-period's sales in half by a
--    HASH of the sale key (timestamp parity is not random), estimate each half
--    independently, correlate, and apply Spearman-Brown 2r/(1+r).
--    This bounds every result you will ever get from this tape: at reliability
--    R, your correlation with the true quantity cannot exceed sqrt(R).
--    ESTABLISH IT BEFORE CHOOSING A MODEL CLASS.
CREATE OR REPLACE TABLE half AS
SELECT era, tcg_card_id, pd,
       median(price_usd) FILTER (WHERE hash(sale_id) % 2 = 0) a,
       median(price_usd) FILTER (WHERE hash(sale_id) % 2 = 1) b,
       count(*) FILTER (WHERE hash(sale_id) % 2 = 0) na,
       count(*) FILTER (WHERE hash(sale_id) % 2 = 1) nb
FROM se WHERE grade_label='raw_nm' GROUP BY 1,2,3;;

-- NOTE: this is LEVEL reliability. Momentum is a difference of two noisy
-- levels and is materially lower - measure it separately on ln(px_t/px_t-1)
-- before quoting any momentum result. Never quote one as the other.
-- (Keep this comment ABOVE the final statement: q.sh executes the trailing
--  fragment after the last doubled semicolon, and a comment-only fragment
--  errors with "NoneType object has no attribute description".)
SELECT era, count(*) cells,
       round(corr(ln(a), ln(b)),3) r,
       round(2*corr(ln(a), ln(b))/(1+corr(ln(a), ln(b))),3) reliability
FROM half WHERE na >= 4 AND nb >= 4 AND a > 0 AND b > 0
GROUP BY 1 ORDER BY 1;;

-- ===========================================================================
-- 6-9: ASSET-CLASS DIAGNOSTICS (references/asset-class-properties.md).
-- These do not describe defects in the tape; they describe properties of the
-- market that break standard modeling assumptions. Run them before you commit
-- to a model class - each one has changed a modeling decision in practice.
-- ===========================================================================

CREATE OR REPLACE TABLE px AS
SELECT tcg_card_id, pd, median(price_usd) p, count(*) n
FROM se WHERE grade_label = 'raw_nm' GROUP BY 1,2;;

-- one row per card-period transition, carrying the STARTING price p0, the
-- realized return, and whether the card is still observable one period later.
CREATE OR REPLACE TABLE ret AS
SELECT a.tcg_card_id, a.pd, b.p p0, ln(a.p/b.p) r,
       CASE WHEN c.tcg_card_id IS NOT NULL THEN 1 ELSE 0 END survives
FROM px a
JOIN px b ON a.tcg_card_id = b.tcg_card_id AND a.pd = b.pd + 1 AND b.n >= 4
LEFT JOIN px c ON a.tcg_card_id = c.tcg_card_id AND c.pd = a.pd + 1 AND c.n >= 4
WHERE a.n >= 4 AND a.p > 0 AND b.p > 0
  -- the LAST period has no successor IN WINDOW, so survival there is
  -- mechanically 0. Including it depresses every bucket by a constant and
  -- makes the tape look far leakier than it is. Drop it.
  AND a.pd < 11;;

-- 6a. OBSERVATION ENDOGENEITY, BY RETURN. Does what the price just did predict
--     whether the card is measured AT ALL next period? If this is not flat,
--     your backtest drops observations non-randomly and you are selecting on
--     the dependent variable. Model the hazard, do not filter it away.
SELECT q, round(100*min(r),1) lo_pct, round(100*max(r),1) hi_pct,
       count(*) cells, round(100.0*avg(survives),1) pct_trading_next
FROM (SELECT *, ntile(5) OVER (ORDER BY r) q FROM ret) GROUP BY 1 ORDER BY 1;;

-- 6b. OBSERVATION ENDOGENEITY, BY PRICE. Hold sales-per-cell roughly constant
--     and watch dropout rise with price: the panel sheds exactly the expensive
--     cards that carry tradeable dollar spread.
SELECT CASE WHEN p0 < 2 THEN '1_lt2' WHEN p0 < 10 THEN '2_2to10'
            WHEN p0 < 50 THEN '3_10to50' ELSE '4_50plus' END band,
       count(*) cells, round(100.0*avg(survives),1) pct_trading_next
FROM ret GROUP BY 1 ORDER BY 1;;

-- 7. UNIVERSE CHURN. How much of the ending universe never existed at the
--    start? That fraction is the share of the market a history-requiring model
--    cannot score. Cold start is the normal case here, not an edge case.
WITH f AS (SELECT DISTINCT tcg_card_id FROM px WHERE pd = 6  AND n >= 4),
     l AS (SELECT DISTINCT tcg_card_id FROM px WHERE pd = 11 AND n >= 4)
SELECT (SELECT count(*) FROM f) start_cards,
       (SELECT count(*) FROM l) end_cards,
       round(100.0*(SELECT count(*) FROM f JOIN l USING (tcg_card_id))
             /(SELECT count(*) FROM f),1) pct_start_surviving,
       round(100.0*(SELECT count(*) FROM l WHERE tcg_card_id NOT IN
             (SELECT tcg_card_id FROM f))/(SELECT count(*) FROM l),1) pct_end_new;;

-- 8. WEIGHTING DIVERGENCE. Same universe, same window, three defensible
--    aggregations. If they disagree in SIGN, that divergence is the finding
--    and no single headline number is honest. Always state the weighting.
SELECT count(*) n,
       round(100*avg(r),2) equal_wt_pct,
       round(100*sum(r*p0)/sum(p0),2) dollar_wt_pct,
       round(100*median(r),2) median_pct,
       -- WRONG ON PURPOSE: weighting by the ENDING price is lookahead. It
       -- hands the winners the weight and can flip the sign of the headline.
       -- Shown here because it is an easy mistake to make silently.
       round(100*sum(r*p0*exp(r))/sum(p0*exp(r)),2) endwt_lookahead_pct
FROM ret;;

-- 9. CHASE CONCENTRATION. A set index is frequently a three-card index. With
--    IR = IC * sqrt(breadth), this is the second breadth collapse: not only do
--    cards move with their set, the set moves with a handful of cards.
CREATE OR REPLACE TABLE dv AS
SELECT set_id, tcg_card_id, sum(price_usd) v FROM se GROUP BY 1,2;;

-- (Comment kept above the final statement: q.sh executes the trailing fragment
--  after the last doubled semicolon, and a comment-only fragment errors.)
WITH rk AS (SELECT set_id, v,
                   row_number() OVER (PARTITION BY set_id ORDER BY v DESC) k,
                   sum(v) OVER (PARTITION BY set_id) tot FROM dv),
     sh AS (SELECT set_id, sum(v) FILTER (WHERE k <= 3)/max(tot) AS share
            FROM rk GROUP BY 1)
SELECT count(*) n_sets, round(100*median(share),1) median_top3_pct,
       round(100*min(share),1) min_pct, round(100*max(share),1) max_pct
FROM sh;;
