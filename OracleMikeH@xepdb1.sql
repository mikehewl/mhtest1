-- Instrument level
WITH level1 AS (
  SELECT
    i.portfolio,
    i.asset,
    i.instrument_name,
    i.instrument_id,
    LAG(pr.price_date, 1,NULL) OVER (partition by pr.instrument_id ORDER BY pr.price_date) + 1 from_price_date,
    pr.price_date to_price_date,
    pr.price_date - TO_NUMBER(TO_CHAR(pr.price_date, 'D')) week_starting,
    LAST_value(pr.price_date) OVER 
      (PARTITION BY pr.instrument_id, pr.price_date - TO_NUMBER(TO_CHAR(pr.price_date, 'D')) ORDER BY pr.price_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_date_in_week,
    pr.value value,
    FIRST_VALUE(pr.value) OVER (PARTITION BY pr.instrument_id ORDER BY pr.price_date) first_value
  FROM
    mh_instrument_prices   pr,
    mh_instruments         i
  WHERE
    i.instrument_id = pr.instrument_id
--
   AND pr.price_date > add_months(trunc(SYSDATE, 'MON'), - 11)
--
),
-- Restrict query to 'last' price in each week
level2 AS (
  SELECT lvl1.portfolio PORTFOLIO,
    lvl1.asset ASSET,
    lvl1.instrument_name INSTRUMENT_NAME,  
    lvl1.week_starting WEEK_STARTING,
    lvl1.value VALUE,
    lvl1.first_value first_value,
    (SELECT SUM(h.quantity * h.unit_price) F
     FROM mh_instrument_history h
     WHERE h.instrument_id = lvl1.instrument_id
     AND h.event_type = 'Purchase'
     AND h.event_date <= lvl1.from_price_date) purchase
  FROM level1 lvl1
  WHERE lvl1.to_price_date = lvl1.last_date_in_week)
-- 
SELECT lvl2.portfolio, lvl2.asset, --lvl2.instrument_name, 
lvl2.week_starting, SUM(lvl2.value) VALUE, 
ROUND(sum(lvl2.value - lvl2.first_value - NVL(lvl2.purchase,0)) *100 / sum(lvl2.first_value + NVL(lvl2.purchase,0)),2) PCT_CHANGE
from level2 lvl2
WHERE lvl2.asset != 'CASH'
   AND PORTFOLIO = 'VIHE0022'
   AND ASSET = 'FIXED INTEREST'
GROUP BY lvl2.portfolio, lvl2.asset, --lvl2.instrument_name,
lvl2.week_starting
ORDER BY lvl2.portfolio, lvl2.asset, --lvl2.instrument_name, 
lvl2.week_starting
;