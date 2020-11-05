-- Dividends on all Instruments
SELECT i.portfolio, i.instrument_name, div.dividend_date, div.quantity, div.description, tr.net_amount, tr.currency 
FROM mh_dividends div
, mh_instruments i
, mh_cash_transactions tr
WHERE 1 = 1
--
AND i.instrument_id  = div.instrument_id (+)
AND i.asset != 'CASH'
--
AND tr.cash_transaction_id(+) = div.cash_transaction_id
--
ORDER BY i.portfolio, i.instrument_name, div.dividend_date
;

-- Dividend summary per Instrument
SELECT i.portfolio, i.instrument_name, i.asset, i.book_cost, TRIM(TO_CHAR(d.latest_dividend_amount, '9,999,990.00') || ' ' || d.currency) last_dividend_amount, d.latest_dividend_date, d.no_dividends_paid
FROM mh_instruments i,
  mh_dividend_summary_v d
WHERE 1 = 1
  AND i.asset != 'CASH'
  --
  AND d.instrument_id(+) = i.instrument_id
ORDER BY i.portfolio, i.asset, i.instrument_name
;


-- Dividends History
SELECT i.portfolio, TRUNC(div.dividend_date, 'MON') month, sum(tr.net_amount),  tr.currency
FROM mh_dividends div
, mh_instruments i
, mh_cash_transactions tr
WHERE 1 = 1
--
AND i.instrument_id  = div.instrument_id 
AND i.asset != 'CASH'
--
AND tr.cash_transaction_id = div.cash_transaction_id
--
GROUP BY i.portfolio, TRUNC(div.dividend_date, 'MON'), tr.currency
--
ORDER BY i.portfolio, TRUNC(div.dividend_date, 'MON'), tr.currency
;