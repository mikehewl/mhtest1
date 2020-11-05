INSERT INTO mh_instrument_prices (
instrument_id,
price_date,
quantity,
price,
value)
WITH prices AS (
  SELECT 
    ext.portfolio,
    ext.price_date,
    CASE TRIM(ext.instrument) WHEN 'Earnings A/C' THEN 'Earnings A/C For Dealing A/C' ELSE ext.instrument END instrument,
    ext.QUANTITY,
    regexp_substr(ext.quantity,'[A-Z]+$') quantity_units,
    ext.PRICE ,
    ext.VALUE 
  FROM mh_holdings_ext ext
  WHERE NVL(ext.instrument,'Instrument Name') != 'Instrument Name'   -- Ignore 'Headings' and blank lines (Instrument IS NULL)
)
SELECT 
  i.instrument_id, 
  TO_DATE(pr.price_date, 'mm/dd/yyyy')price_date,
  TO_NUMBER(TRIM(REPLACE(pr.quantity,i.instrument_currency)),'999,999.000000') quantity,
  TO_NUMBER(TRIM(REPLACE(pr.price,i.price_unit)),'999,999.00000000') price,
  TO_NUMBER(TRIM(REPLACE(pr.value,p.currency)),'999,999.00000000') value
FROM 
  prices pr
,  mh_portfolios p
,  mh_instruments i
WHERE 1 = 1
--
AND p.account = pr.portfolio
--
AND i.portfolio = p.account
AND i.instrument_name = pr.instrument
AND NVL(i.instrument_currency,'XXX') = NVL(pr.quantity_units, 'XXX')
;

COMMIT;