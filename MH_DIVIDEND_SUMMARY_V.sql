CREATE OR REPLACE VIEW mh_dividend_summary_v AS
SELECT * 
FROM (
  WITH DIVIDENDS AS (
  -- Some dividends paid in installments so need to sum them together
  SELECT  div.instrument_id, div.dividend_date, div.quantity, div.description, SUM(tr.net_amount) dividend_amount, tr.currency 
  FROM mh_dividends div
  , mh_cash_transactions tr
  WHERE 1 = 1
  --
  AND tr.cash_transaction_id = div.cash_transaction_id
  AND tr.transaction_type = 'Dividend'
  --
  GROUP BY div.instrument_id, div.dividend_date, div.quantity, div.description, tr.currency)
  SELECT DISTINCT d.instrument_id, 
    last_value(d.dividend_date) over (partition by d.instrument_id order by d.dividend_date rows between unbounded preceding and unbounded following) latest_dividend_date,
    last_value(d.dividend_amount) over (partition by d.instrument_id order by d.dividend_date rows between unbounded preceding and unbounded following) latest_dividend_amount,
    d.currency,
    count(1) over (partition by d.instrument_id) no_dividends_paid
  FROM dividends d
)
;

DROP VIEW mh_dividend_summary_v;