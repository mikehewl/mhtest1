CREATE TABLE mh_cash_transactions (
cash_transaction_id            NUMBER NOT NULL PRIMARY KEY,
instrument_id                  NUMBER NOT NULL REFERENCES mh_instruments(instrument_id),
transaction_type               VARCHAR2(64) NOT NULL,
transaction_date               DATE NOT NULL,
net_amount                     NUMBER NOT NULL,
currency                       VARCHAR2(8) NOT NULL,
description                    VARCHAR2(256) NOT NULL);

DROP TABLE mh_cash_transactions;

CREATE SEQUENCE mh_cash_transactions_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_cash_transactions_s;

