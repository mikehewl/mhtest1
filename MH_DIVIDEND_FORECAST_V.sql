CREATE OR REPLACE VIEW mh_dividend_forecast_v AS
-- ============================================================================
-- Select existing dividends data 'summed' per date to produce 1 row per dividend
-- ============================================================================
WITH lvl1 AS (
  SELECT
    dv.instrument_id,
    dv.dividend_date,
    dv.description,
    SUM(csh.net_amount) net_amount
  FROM
    mh_dividends           dv,
    mh_cash_transactions   csh
  WHERE
    dv.description NOT LIKE 'TAX CREDIT%'
--
    AND csh.cash_transaction_id = dv.cash_transaction_id
--
  GROUP BY
    dv.instrument_id,
    dv.dividend_date,
    dv.description
), 
-- ============================================================================
-- Add columns for 'no of dividends' and 'period' (in days) between dividends
-- ============================================================================
lvl2 AS (
  SELECT
    lvl1.instrument_id,
    lvl1.dividend_date,
    lvl1.description,
    lvl1.net_amount,
    COUNT(1) OVER(
      PARTITION BY lvl1.instrument_id
    ) no_dividends,
    lvl1.dividend_date - LAG(lvl1.dividend_date) OVER(PARTITION BY lvl1.instrument_id ORDER BY lvl1.dividend_date) period_days
  FROM
    lvl1
)
-- ============================================================================
-- Group rows per dividend calculating average period (in days) and average 
-- payment amount.  Add the average period to the latest dividend date to 
-- provide the forecast date.  If the period is NULL this means there is no
-- 
-- ============================================================================
SELECT
  lvl2.instrument_id,
  no_dividends + 1 instrument_seq,
  MAX(dividend_date) last_dividend_date,
  ROUND(AVG(period_DAYS)/30) period_months,
  add_months(MAX(dividend_date), NVL(ROUND(AVG(period_days)/30), 12)) forecast_date,
  round(AVG(net_amount), 2) forecast_amount
FROM
  lvl2
GROUP BY
  lvl2.instrument_id, lvl2.no_dividends;
