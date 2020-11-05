TRUNCATE TABLE mh_security_transactions_ext;

INSERT INTO mh_instruments
SELECT
  mh_instruments_s.nextval instrument_id,
  s.instrument_name instrument_name,
  '&PORTFOLIO' portfolio,
  REGEXP_SUBSTR(s.qty,'[A-Z]+$') instrument_currency,
  ABS(TO_NUMBER(REGEXP_SUBSTR(s.net_amount, '^[^ GBP]+'),'S999,999.99')) book_cost,
  'EQUITY' asset,
  NULL sector,
  NULL country,
  NULL region,
  'Stock' type,
  s.isin isin,
  NULL epic_code,
  NULL market,
  TO_NUMBER(REGEXP_SUBSTR(s.qty,'^[^ ]+'),'999999.99') quantity,
  NULL dividend_period_months,
  NULL tax_credit_period_months,
  NVL(REGEXP_SUBSTR(s.qty,'[A-Z]+'),'EA') quantity_unit
FROM
  mh_security_transactions_ext s
, mh_instruments i
WHERE s.transaction_type = 'Buy'
AND i.instrument_name (+) = s.instrument_name
AND i.instrument_name IS NULL;


-- Insert initial Purchase - Need to manually update Unit Price and fee (calculate it)
INSERT INTO mh_instrument_history
SELECT mh_instrument_history_s.nextval instrument_history_id,
       i.instrument_id,
       csh.cash_transaction_id cash_transaction_id,
       'Initial Purchase' event_type,
       csh.transaction_date EVENT_DATE,
       csh.description description,
       i.quantity quantity,
       null unit_price,
       null fee
FROM mh_instruments i
, mh_instrument_history h
, mh_cash_transactions csh
WHERE i.asset != 'CASH'
--
AND h.instrument_id(+) = i.instrument_id
AND h.instrument_id IS NULL
--
AND csh.description like 'Purchase:%' || I.instrument_name || '%';
