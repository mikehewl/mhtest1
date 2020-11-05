CREATE TABLE mh_dividend_forecast (
dividend_forecast_id           NUMBER NOT NULL PRIMARY KEY,
instrument_id                  NUMBER REFERENCES mh_instruments (instrument_id),
dividend_type                  VARCHAR2(8),
quantity                       NUMBER,
forecast_date                  DATE,
forecast_amount                NUMBER,
currency                       VARCHAR2(8)
);

DROP TABLE mh_dividend_forecast;


CREATE SEQUENCE mh_dividend_forecast_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_dividend_forecast_s;
