CREATE TABLE mh_instrument_history (
instrument_history_id          NUMBER NOT NULL PRIMARY KEY,
instrument_id                  NUMBER NOT NULL REFERENCES mh_instruments(instrument_id),
cash_transaction_id            NUMBER REFERENCES mh_cash_transactions(cash_transaction_id),
event_type                     VARCHAR2(64) NOT NULL,
event_date                     DATE NOT NULL,
description                    VARCHAR2(256) NOT NULL,
quantity                       NUMBER,
unit_price                     NUMBER,
fee                            NUMBER);

DROP TABLE mh_instrument_history;

CREATE SEQUENCE mh_instrument_history_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_instrument_history_s;

