CREATE OR REPLACE VIEW mh_portfolio_performance_v AS
WITH all_data AS (
-- ============================================================================
-- Todays data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'TODAY' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.today = pr.price_date
--
UNION ALL
-- ============================================================================
-- Latest data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'LATEST' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.latest_date = pr.price_date
--
UNION ALL
-- ============================================================================
-- 1 week data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'LAST_WEEK' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.best_1week_date = pr.price_date
--
UNION ALL
-- ============================================================================
-- 1 month data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'LAST_MONTH' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.best_1month_date = pr.price_date
--
UNION ALL
-- ============================================================================
-- 6 Months data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'LAST_6MONTHS' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.best_6month_date = pr.price_date
UNION ALL
-- ============================================================================
-- Earliest data
-- ============================================================================
SELECT i.portfolio, i.asset, i.instrument_name, 'EARLIEST' label, pr.price_date, pr.value 
FROM
  mh_instrument_prices pr
, mh_instruments i
, mh_instrument_price_dates_v  d
where i.instrument_id = pr.instrument_id
--
and d.portfolio = i.portfolio
and d.earliest_date = pr.price_date
)
-- ============================================================================
  SELECT portfolio, asset, instrument_name, price_date, value
  FROM all_data
;