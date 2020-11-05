-- Populate the cash transactions (when they don't already exist
INSERT INTO mh_cash_transactions (
cash_transaction_id,
instrument_id,
instrument_seq,
transaction_type,
transaction_date,
net_amount,
currency,
description)
SELECT mh_cash_transactions_s.nextval cash_transaction_id,  i.instrument_id
, ext.transaction_type, TO_DATE(ext.transaction_date,'dd/mm/yyyy') transaction_date
, TO_NUMBER(TRIM(REPLACE(ext.net_amount, REGEXP_SUBSTR(ext.net_amount,'[A-Z]+$'))),'9,999,990.00') net_amount
, REGEXP_SUBSTR(ext.net_amount,'[A-Z]+$') currency
, ext.description
FROM mh_cash_transactions_ext ext
, mh_instruments i
WHERE 1 = 1
AND i.portfolio(+) = :portfolio 
AND i.instrument_name(+) = ext.instrument_name
AND i.instrument_currency(+) = REGEXP_SUBSTR(ext.net_amount,'[A-Z]+$')
--
AND NOT EXISTS (
  SELECT NULL
  FROM mh_cash_transactions tr
  , mh_instruments i2
  WHERE 1 = 1
  AND i2.instrument_id = tr.instrument_id
  --
  AND i2.instrument_name = i.instrument_name
  AND i2.portfolio = i.portfolio
  AND tr.transaction_date = TO_DATE(ext.transaction_date,'dd/mm/yyyy')
  AND tr.transaction_type = ext.transaction_type
  AND tr.net_amount = TO_NUMBER(TRIM(REPLACE(ext.net_amount, REGEXP_SUBSTR(ext.net_amount,'[A-Z]+$'))),'9,999,990.00')
  AND tr.currency = REGEXP_SUBSTR(ext.net_amount,'[A-Z]+$')
  AND tr.description = ext.description);
  
-- Populate the Dividends
-- Due to discrepancies in Instrument names some Instruments in the Dividend table may need manual update
INSERT INTO mh_dividends (
  cash_transaction_id, instrument_id, instrument_seq, dividend_type, description, quantity, dividend_date)
WITH new_dividends AS (
SELECT
  csh.cash_transaction_id,
  i.instrument_id,
  csh.transaction_date,
  csh.net_amount,
  csh.description,
  CASE
    WHEN REGEXP_LIKE ( csh.description, '^(Dividend|Interest) on [0-9,\,]+ Valued on ([0-9]){6}/' ) THEN 'DIV'
    WHEN REGEXP_LIKE ( csh.description, '^TAX CREDIT - ' ) THEN 'TAX'
    ELSE 'XXX'
  END dividend_type,
  i.portfolio
FROM
  mh_cash_transactions   csh,
  mh_instruments         cash_acc,
  mh_instruments         i
WHERE
  csh.transaction_type = 'Dividend'
  AND cash_acc.instrument_id = csh.instrument_id
  --
  AND i.portfolio(+) = cash_acc.portfolio
  AND CASE
    WHEN REGEXP_LIKE ( csh.description, '^(Dividend|Interest) on [0-9,\,]+ Valued on ([0-9]){6}/' ) THEN SUBSTR(csh.description,LENGTH(REGEXP_SUBSTR(csh.description, '^(Dividend|Interest) on [0-9,\,]+ Valued on ([0-9]){6}/'))+ 1)
    WHEN REGEXP_LIKE ( csh.description, '^TAX CREDIT - ' ) THEN REPLACE(csh.description, 'TAX CREDIT - ' )
  END LIKE REPLACE(i.instrument_name(+), '  ', ' ') || '%'
  --
  AND NOT EXISTS (
    SELECT NULL
    FROM mh_dividends div
    WHERE div.cash_transaction_id = csh.cash_transaction_id
  )
)
-- ============================================================================
-- Main Query
-- ============================================================================
SELECT d.cash_transaction_id,
  d.instrument_id,
  (SELECT MAX(instrument_seq) + 1 FROM mh_dividends d1 WHERE d1.instrument_id = d.instrument_id) instrument_seq,
  d.dividend_type,
  d.description,
  CASE d.dividend_type
    WHEN 'DIV' THEN TO_NUMBER(REGEXP_SUBSTR(d.description,'[0-9,\,]+',13),'9,999,990')
  END quantity,
  CASE d.dividend_type
    WHEN 'DIV' THEN TO_DATE(REGEXP_SUBSTR(d.description,'([0-9]){6}',LENGTH(regexp_substr(description,'^(Dividend|Interest) on [0-9,\,]+ Valued on '))),'DDMMRR')
    ELSE d.transaction_date
  END dividend_date
FROM new_dividends d
;

INSERT INTO MH_NOTIFICATIONS(notification_id,
  table_name, -- e.g. 'MH_DIVIDENDS' 
  table_id,
  notif_level,  -- 'E' - Error, 'W' - Warning, 'I' - Info 
  message,
  status)    
SELECT mh_notifications_s.NEXTVAL notification_id,
  'MH_INSTRUMENTS' table_name,
  div1.instrument_id,
  'W' notif_level,
  'Please check dividend for ' || div1.instrument_name || '(' || div1.epic_code 
    || '). Paid on ' || div1.dividend_date || ' for amount ' || TO_CHAR(div1.dividend_amount) 
    || ' - Forecast on ' || frc.forecast_date || ' for amount ' || TO_CHAR(frc.forecast_amount) message,
  'A' status
FROM mh_dividend_forecast frc,
  (SELECT div.instrument_id, div.instrument_seq, i.instrument_name, i.epic_code, div.dividend_date, SUM(csh.net_amount) dividend_amount
   FROM mh_dividends div,
     mh_cash_transactions csh,
     mh_instruments i  
   WHERE csh.cash_transaction_id = div.cash_transaction_id
   --
   AND i.instrument_id = div.instrument_id
   GROUP BY  div.instrument_id, div.instrument_seq, i.instrument_name, i.epic_code, div.dividend_date) div1
--
WHERE div1.instrument_id = frc.instrument_id
AND div1.instrument_seq = frc.instrument_seq
AND NOT (ABS(div1.dividend_amount - frc.forecast_amount) < 0.01 AND div1.dividend_date = frc.forecast_date);

-- ============================================================================
-- Delete any Forecasts for Dividends just created
-- ============================================================================
DELETE FROM mh_dividend_forecast frc
WHERE EXISTS (
  SELECT NULL
  FROM mh_dividends div
  WHERE frc.instrument_id = div.instrument_id
  AND frc.instrument_seq = div.instrument_seq);
  
-- Populate any 'Purchase' transactions
-- ================================================================================================
-- On any 'Brand' new purchase must manually update the Event type => 'Initial Purchase'
-- Otherwise results in 'double counting' when displaying graph of Performance  growth vs FTSE
-- (the Purchase is included in both the 'Initial' value plus the 'Purchase' value)
-- ================================================================================================
INSERT INTO mh_instrument_history (
  instrument_history_id,
  instrument_id,
  cash_transaction_id,
  event_type,
  event_date,
  description,
  quantity,
  unit_price,
  fee )
SELECT
  mh_instrument_history_s.nextval,
  (
    SELECT instrument_id FROM mh_instruments i WHERE tr.description LIKE '%' || i.instrument_name|| '%') instrument_id,
  tr.cash_transaction_id,
  'Purchase' event_type,
  transaction_date event_date,
  tr.description,
  to_number(regexp_substr(tr.description, '[0-9,\,]+', 10)) quantity,
  to_number(regexp_substr(tr.description, '([0-9,\.])+$')) unit_price,
  abs(tr.net_amount) - round(to_number(regexp_substr(tr.description, '[0-9,\,]+', 10)) * to_number(regexp_substr(tr.description, '([0-9,\.])+$')), 2) fee
FROM
  mh_cash_transactions tr
WHERE
  tr.transaction_type = 'Cash Movement'
  AND tr.description LIKE 'Purchase:%'
--
  AND NOT EXISTS (
    SELECT NULL
    FROM mh_instrument_history ih
    WHERE ih.cash_transaction_id = tr.cash_transaction_id
    AND ih.event_type IN ('Purchase','Initial Purchase'));

COMMIT;