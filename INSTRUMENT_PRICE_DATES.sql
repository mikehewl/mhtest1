/* =============================================================================
Name:                   INSTRUMENT_PRICE_DATES.sql
Version:		1.0

Views used to show Historical price changes

Vn History
1.0   20 Nov 2020  Updated view MHTMP1 so VALUE of 0 is returned as NULL - 
                   otherwise get divide by zero errors for zero value stock
1.01  08 Dec 2020  Updated view MHTMP - Added comments and included another 
                   level to improve performance
============================================================================= */

CREATE OR REPLACE VIEW MHTMP AS
SELECT portfolio, price_date, 
  CASE price_date 
    WHEN date1 THEN 'COL1'--'Latest: ' || TO_CHAR(date1)
    WHEN date2 THEN 'COL2'--'Previous: ' || TO_CHAR(date2)
    WHEN date3 THEN 'COL3'--'1 week: ' ||TO_CHAR(date3)
    WHEN date4 THEN 'COL4'--'1 month: ' || TO_CHAR(date4)
    WHEN date5 THEN 'COL5'--'6 Month: ' || TO_CHAR(date5)
    WHEN date6 THEN 'COL6'--'Earliest: ' || TO_CHAR(date6)
  END label
FROM (
  SELECT  
    ilv.portfolio, ilv.price_date,
    trunc(sysdate) date1,
    --  Most recent (i.e. biggest) date prior to SYSDATE
    max(price_date) keep (dense_rank first order by     case when ilv.price_date < TRUNC(SYSDATE) then ilv.price_date end desc nulls last) over (partition by ilv.portfolio) date2,
    -- Find date nearest to 7 days ago.  Calculate the difference  of the Price date from 7 days ago, and use ORDER BY on the differences to pick the date with the smallest difference
    min(price_date) keep (dense_rank first order by abs(ilv.price_date - (trunc(sysdate) - 7))) over (partition by ilv.portfolio) date3,
    min(price_date) keep (dense_rank first order by abs(price_date - trunc(add_months(sysdate, - 1)))) over (partition by portfolio) date4, 
    min(price_date) keep (dense_rank first order by abs(price_date - trunc(add_months(sysdate, - 6)))) over (partition by portfolio) date5,
    min(price_date) keep (dense_rank first order by price_date) over (partition by portfolio) date6
  FROM (
    SELECT DISTINCT i.portfolio, pr.price_date
    FROM mh_instrument_prices pr
    ,  mh_instruments i
    WHERE i.instrument_id = pr.instrument_id) ilv
  )
WHERE 1 = 1
AND (price_date = date1) OR (price_date = date2) OR (price_date = date3) OR (price_date = date4) OR (price_date = date5) OR (price_date = date6);

SELECT * FROM MHTMP;

CREATE OR REPLACE VIEW mhtmp1 AS
SELECT portfolio, instrument_name, asset, sector, "'COL1'" latest, "'COL2'" previous,
"'COL3'" week, "'COL4'" month, "'COL5'" half_year, "'COL6'" earliest
FROM (
SELECT  i.portfolio, --pr.price_date, 
d.label, 
i.instrument_name, i.asset, i.sector, 
  CASE pr.value WHEN 0 THEN NULL ELSE pr.value END value
FROM mh_instrument_prices pr
, mh_instruments i
, mhtmp d
WHERE i.instrument_id = pr.instrument_id
and pr.price_date = d.price_date
and i.portfolio = d.portfolio
)
pivot
(
sum(value)
for label in ('COL1','COL2','COL3','COL4','COL5','COL6')
)
;

CREATE OR REPLACE VIEW MHTMP3 AS
SELECT
  i.portfolio,
  i.asset,
  i.instrument_id,
  CASE i.asset WHEN 'CASH' THEN i.instrument_name || '-' ||instrument_currency ELSE i.instrument_name END instrument_name,
  pr.price_date - to_number(TO_CHAR(pr.price_date, 'D')) WEEK_STARTING,
  trunc((trunc(sysdate) - (pr.price_date - to_number(TO_CHAR(pr.price_date, 'D')) + 1 )) / 7)  WEEK_NO,
  round(AVG(pr.value),2) value
FROM
  mh_instrument_prices   pr,
  mh_instruments         i
WHERE
  i.instrument_id = pr.instrument_id
  --
AND pr.price_date > add_months(trunc(sysdate,'MON'), -11)
GROUP BY 
  i.portfolio,
  i.asset,
  i.instrument_id,
  CASE i.asset WHEN 'CASH' THEN i.instrument_name || '-' ||instrument_currency ELSE i.instrument_name END,
  pr.price_date - to_number(TO_CHAR(pr.price_date, 'D')),
  trunc((trunc(sysdate) - (pr.price_date - to_number(TO_CHAR(pr.price_date, 'D')) + 1 )) / 7);