-- Top level
SELECT 
pr.price_date, TO_CHAR(sum(pr.value),'9,999,990.00') gbp
FROM MH_instrument_prices pr
WHERE 1 = 1
--
GROUP BY pr.price_date
ORDER BY pr.price_date
;


-- Portfolio performance
SELECT 
i.portfolio, pr.price_date, TO_CHAR(sum(pr.value),'9,999,990.00') gbp
FROM MH_instrument_prices pr
, mh_instruments i
WHERE 1 = 1
AND i.portfolio = :portfolio
--
AND pr.instrument_id = i.instrument_id
--
GROUP BY i.portfolio, pr.price_date
ORDER BY i.portfolio, pr.price_date
;

-- Asset performance 
SELECT 
i.portfolio, i.asset, pr.price_date, TO_CHAR(sum(pr.value),'9,999,990.00') gbp
FROM MH_instrument_prices pr
, mh_instruments i
WHERE 1 = 1
AND i.portfolio = :portfolio
--
AND pr.instrument_id = i.instrument_id
--
GROUP BY i.portfolio, i.asset, pr.price_date
ORDER BY i.portfolio, i.asset, pr.price_date
;