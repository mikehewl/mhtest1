DECLARE
  CURSOR C_1 IS
  SELECT PORTFOLIO ,
    INSTRUMENT ,
    VALUE ,
    QUANTITY ,
    PRICE ,
    BOOK_COST ,
    PROFIT ,
    PERFORMANCE 
  FROM mh_holdings_ext h
  WHERE NVL(h.instrument,'Instrument Name') != 'Instrument Name';  -- Ignore 'Headings' and blank lines
  
  l_portfolio             VARCHAR2(64);
  l_instrument            VARCHAR2(64);
  l_asset                 VARCHAR2(32);
  l_qty_unit              varchar2(32);
  l_quantity              NUMBER;
  l_cost_currency         VARCHAR2(32);
  l_cost                  NUMBER;
BEGIN
  FOR l_row IN C_1 LOOP
    
    -- Set the Asset (careful of 'For Dealing A/C' - looks like an ASSET line)
    IF (l_row.instrument != 'For Dealing A/C') and (l_row.value IS NULL) and (l_row.quantity IS NULL) and (l_row.price IS NULL) THEN
      l_asset := l_row.instrument; 
      CONTINUE; 
    END IF;
    
    l_portfolio := l_row.portfolio;
    l_instrument := l_row.instrument;
    l_qty_unit := NVL(regexp_substr(l_row.quantity,'[A-Z]+'),'Each');
    IF l_qty_unit IN ('GBP','USD') THEN
--        dbms_output.put_line('Quantity: ''' || TO_NUMBER(TRIM(REPLACE(l_row.quantity,l_unit)),'999,999.00') || ''' ' || L_UNIT);
        l_quantity := TO_NUMBER(TRIM(REPLACE(l_row.quantity,l_qty_unit)),'999,999.000000'); 
    ELSE 
--        dbms_output.put_line('Quantity: ''' || TRIM(l_row.quantity) || ''' ' || L_UNIT);
        l_quantity := TO_NUMBER(TRIM(l_row.quantity),'999,999.00');
    END IF;
    IF l_instrument = 'Capital Account' THEN
      l_instrument := l_instrument || ' (' || l_qty_unit || ')';
    END IF;
    l_cost_currency := regexp_substr(l_row.book_cost,'[A-Z]+');
    l_cost := TO_NUMBER(TRIM(REPLACE(l_row.book_cost,l_cost_currency)),'999,999.00000000');
    
    dbms_output.put_line(l_portfolio || ' | ' || l_instrument || ' | ' || l_asset || ' | ' || l_quantity || ' | ' ||
      l_qty_unit || ' | ' || l_cost || ' | ' || l_cost_currency    );
    
    INSERT INTO mh_instruments (
      instrument_id,instrument_name,portfolio,quantity,units,book_cost,currency,asset)
    SELECT mh_instruments_s.nextval, l_instrument, l_portfolio, l_quantity, l_qty_unit, l_cost, l_cost_currency, l_asset
    FROM dual;
  END LOOP;
END;
/

COMMIT;