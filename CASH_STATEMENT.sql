WITH statement_lines AS (
  SELECT tr.cash_transaction_id, i.portfolio, i.instrument_id, i.instrument_name, tr.transaction_date, tr.transaction_type, tr.description, tr.net_amount, tr.currency
  , SUM(tr.net_amount) OVER(partition by i.instrument_id ORDER BY tr.transaction_date, CASE tr.transaction_type WHEN 'Cash Withdrawal' THEN 1 ELSE 0 END
  , tr.cash_transaction_id RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) balance
  FROM 
    mh_instruments i
  , mh_cash_transactions tr
  WHERE 1 = 1
  AND i.asset = 'CASH'
--
  AND tr.instrument_id = i.instrument_id
  --
  UNION ALL
  --
  SELECT NULL cash_transaction_id, i.portfolio, i.instrument_id, i.instrument_name, pr.price_date, 'BALANCE' transaction_type, '*** From Unit Prices - Should reconcile with previous line ***' description
  , NULL net_amount, 'GBP' currency,  pr.value balance
  FROM mh_instruments i
  , mh_instrument_prices pr
  , mh_instrument_price_dates_v d
  WHERE 1 = 1
  AND i.asset = 'CASH'
--
  AND pr.instrument_id = i.instrument_id
--
  AND d.portfolio = i.portfolio
  AND NVL(d.earliest_date, d.today) = pr.price_date
)
SELECT l.portfolio, l.instrument_id, l.instrument_name, l.transaction_date, l.transaction_type, l.description, l.net_amount, l.currency, l.balance
FROM statement_lines l
--
ORDER BY l.portfolio, l.instrument_id, l.transaction_date, CASE l.transaction_type WHEN 'Cash Withdrawal' THEN 1 WHEN 'BALANCE' THEN 2 ELSE 0 END, l.cash_transaction_id NULLS FIRST
;
