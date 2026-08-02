-- Canonical card x venue x 14-day-period panel for the Pokemon TCG lakehouse.
-- Run with: ./q.sh < panel.sql
-- q.sh splits statements on a doubled semicolon, so never write that token
-- inside a comment or string literal - it will truncate the file mid-statement.
--
-- Produces, in order:
--   era    - SV/ME card identity
--   sale   - filtered sale-level tape
--   cp     - card x period microstructure state (raw NM)
--   psa    - card x period PSA 10 leg
--   lp     - card x period LP leg
--   g      - card x period venue pair + error-correction gap
--   panel  - lagged panel with signal columns and BOTH forward targets
--   sc     - equal-weight composite score
--
-- Append your own analysis statements after this file; each q.sh call is a
-- fresh in-memory DuckDB, so everything must run in ONE invocation.
--
-- AS-OF DATE IS HARDCODED. DuckDB on lor-main has no pytz, so max(sold_at)
-- and date_trunc on a TIMESTAMPTZ both fail. Update these two dates.
--
-- TWO PERIOD FILTERS ARE MANDATORY AND BAKED IN BELOW:
--   pd >= 6  - TCGplayer was absent/degraded before 2026-04-26 (37 missing days
--              Mar 3 - Apr 21). At pd=5 TCGplayer is 0.1% of volume, so any
--              cross-venue factor is undefined before pd=6.
--   drop max(pd) - the newest period is always under-ingested (eBay fell 66%
--              in the final period purely from ingest lag).

CREATE OR REPLACE TABLE era AS
SELECT tcg_card_id, name, set_id, rarity, card_number
FROM 'card_rollup.parquet'
WHERE set_id IN ('sv1','sv2','sv3','sv3pt5','sv4','sv4pt5','sv5','sv6','sv6pt5','sv7','sv8',
                 'sv8pt5','sv9','sv10','rsv10pt5','zsv10pt5','svp',
                 'me1','me2','me2pt5','me3','me4','me5');;

CREATE OR REPLACE TABLE sale AS
SELECT s.tcg_card_id, s.marketplace, s.price_usd, s.grader, s.grade_num, s.grade_label,
  CAST(floor((CAST(s.sold_at AS DATE) - DATE '2026-02-01')/14.0) AS INT) pd
FROM 'card_sales_history.parquet' s JOIN era e USING (tcg_card_id)
WHERE s.game='pokemon' AND s.price_usd>0
  AND s.id_confidence IN ('high','title_verified')   -- mandatory: anything else is unmapped
  AND s.trade_type='secondary'                        -- excludes buyback/primary/burn/internal
  AND s.marketplace IN ('tcgplayer','ebay')           -- ebay_hk is a separate price regime
  AND CAST(s.sold_at AS DATE) >= DATE '2026-02-01';;

-- NM selector. Use grade_label, NOT condition. They agree on price to within
-- 0.3% but grade_label carries 2.4x more eBay rows (443k vs 187k on SV/ME).
-- 'raw_unknown' is NOT near-mint - it medians $9.90 vs $5.99 for raw_nm.

-- Wide 3x IQR fences. Use 1.5x for level estimation; 3x here because the LEFT
-- TAIL IS A SIGNAL (p10 depletion) and 1.5x trims away the thing being measured.
CREATE OR REPLACE TABLE fen AS
SELECT tcg_card_id, quantile_cont(price_usd,0.25) f25, quantile_cont(price_usd,0.75) f75
FROM sale WHERE (grader IS NULL OR grader='RAW') AND grade_label='raw_nm' GROUP BY 1;;

CREATE OR REPLACE TABLE nm AS
SELECT a.* FROM sale a JOIN fen f USING (tcg_card_id)
WHERE (a.grader IS NULL OR a.grader='RAW') AND a.grade_label='raw_nm'
  AND a.price_usd BETWEEN f.f25-3*(f.f75-f.f25) AND f.f75+3*(f.f75-f.f25);;

CREATE OR REPLACE TABLE cp AS
SELECT tcg_card_id, pd, count(*) n,
  quantile_cont(price_usd,0.10) p10, quantile_cont(price_usd,0.25) p25,
  median(price_usd) p50, quantile_cont(price_usd,0.75) p75,
  count(*) FILTER (WHERE marketplace='tcgplayer') ntcg,
  count(*) FILTER (WHERE marketplace='ebay') neb,
  median(price_usd) FILTER (WHERE marketplace='tcgplayer') tcg50,
  median(price_usd) FILTER (WHERE marketplace='ebay') eb50
FROM nm WHERE pd BETWEEN 6 AND 11 GROUP BY 1,2 HAVING count(*)>=8;;

-- PSA 10 leg. Disjoint transactions from raw, so it is structurally immune to
-- bid-ask bounce against a raw-price target.
CREATE OR REPLACE TABLE psa AS
SELECT tcg_card_id, pd, count(*) npsa, median(price_usd) psa50
FROM sale WHERE grader='PSA' AND grade_num=10 AND pd BETWEEN 6 AND 11 GROUP BY 1,2 HAVING count(*)>=4;;

-- LP leg: condition substitution / supply exhaustion. Also disjoint from NM.
CREATE OR REPLACE TABLE lp AS
SELECT tcg_card_id, pd, count(*) nlp, median(price_usd) lp50
FROM sale WHERE (grader IS NULL OR grader='RAW') AND grade_label='raw_lp' AND pd BETWEEN 6 AND 11
GROUP BY 1,2 HAVING count(*)>=4;;

-- Error-correction pair: both venues present in the same card-period.
CREATE OR REPLACE TABLE g AS
SELECT tcg_card_id, pd, tcg50 tcg, eb50 eb, ln(eb50/tcg50) gap
FROM cp WHERE ntcg>=4 AND neb>=4 AND tcg50>1 AND eb50>1;;

-- Lagged panel. ret_next is the naive target; ret_skip is the honest one
-- (t+1 -> t+2, no shared transactions -> bounce cannot survive).
CREATE OR REPLACE TABLE panel AS
SELECT c1.tcg_card_id, c1.pd, c1.p50 px,
  ln(c2.p50/c1.p50) ret_next,
  ln(c3.p50/c2.p50) ret_skip,
  ln(c1.p50/c0.p50) dp50,
  ln(c1.p10/c0.p10) dp10,
  ln(c1.n*1.0/c0.n) dvol,
  ln(c1.eb50/c1.tcg50) venuegap,
  (c1.p50-c1.p10)/nullif(c1.p75-c1.p10,0) tailshape,   -- ARTIFACT: kept for regression testing only
  c1.p75/nullif(c1.p10,0) spread
FROM cp c1
JOIN cp c0 ON c0.tcg_card_id=c1.tcg_card_id AND c0.pd=c1.pd-1
JOIN cp c2 ON c2.tcg_card_id=c1.tcg_card_id AND c2.pd=c1.pd+1
JOIN cp c3 ON c3.tcg_card_id=c1.tcg_card_id AND c3.pd=c1.pd+2
WHERE c1.p50>=1 AND c1.p10>0 AND c0.p10>0;;

CREATE OR REPLACE TABLE pj AS
SELECT p.*, e.set_id, e.rarity, e.name,
  ln(a.psa50/b.psa50) dpsa,
  ln(l.lp50/p.px) lpratio
FROM panel p JOIN era e USING (tcg_card_id)
LEFT JOIN psa a ON a.tcg_card_id=p.tcg_card_id AND a.pd=p.pd
LEFT JOIN psa b ON b.tcg_card_id=p.tcg_card_id AND b.pd=p.pd-1
LEFT JOIN lp  l ON l.tcg_card_id=p.tcg_card_id AND l.pd=p.pd
WHERE p.venuegap IS NOT NULL;;

-- Validated composite: venue gap (inverted) + volume growth + p10 rise.
-- Equal weights on within-period percentile ranks. NO FITTING - do not tune
-- these weights on this sample; there is only one regime in it.
CREATE OR REPLACE TABLE sc AS
SELECT *,
    (percent_rank() OVER (PARTITION BY pd ORDER BY venuegap)-0.5)*-2
  + (percent_rank() OVER (PARTITION BY pd ORDER BY dvol)-0.5)*2
  + (percent_rank() OVER (PARTITION BY pd ORDER BY dp10)-0.5)*2 AS score
FROM pj;;

SELECT 'card-periods' k, count(*) v FROM cp
UNION ALL SELECT 'distinct cards', count(DISTINCT tcg_card_id) FROM cp
UNION ALL SELECT 'periods', count(DISTINCT pd) FROM cp
UNION ALL SELECT 'panel rows', count(*) FROM sc
UNION ALL SELECT 'ec pairs', count(*) FROM g;;

-- Sanity: composite IC on the grade_label panel, total and within-set.
CREATE OR REPLACE TABLE ws AS
SELECT *, ret_next - avg(ret_next) OVER (PARTITION BY set_id, pd) resid,
          score   - avg(score)   OVER (PARTITION BY set_id, pd) dscore
FROM sc;;

SELECT round(corr(a,b),3) ic_next FROM (
  SELECT rank() OVER (ORDER BY ret_next) a, rank() OVER (ORDER BY score) b FROM sc);;
SELECT round(corr(a,b),3) ic_skip FROM (
  SELECT rank() OVER (ORDER BY ret_skip) a, rank() OVER (ORDER BY score) b
  FROM sc WHERE ret_skip IS NOT NULL);;
SELECT round(corr(a,b),3) ic_within_set FROM (
  SELECT rank() OVER (ORDER BY resid) a, rank() OVER (ORDER BY dscore) b FROM ws);;
