SELECT
  i.portfolio,
  p.price_date,
  i.asset,
  i.instrument_name,
  CASE WHEN i.instrument_currency IS NOT NULL THEN TO_CHAR(p.quantity, '9,999,990.00') ELSE TO_CHAR(p.quantity) END quantity,
  i.instrument_currency quantity_unit,
  TO_CHAR(p.price,'9,999,990.00') price,
  i.price_unit,
  TO_CHAR(p.value,'9,999,990.00') value_gbp
FROM
  mh_instrument_prices   p,
  mh_instruments         i
WHERE
  i.instrument_id = p.instrument_id
ORDER BY
  i.portfolio,
  p.price_date DESC,
  i.asset,
  i.instrument_name
  ;