CREATE SEQUENCE mh_security_transactions_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_security_transactions_s;

CREATE TABLE mh_security_transactions_ext (
  security_transaction_id NUMBER DEFAULT mh_security_transactions_s.nextval NOT NULL PRIMARY KEY,  -- Default value used in APEX import from spreadsheet
  instrument_name    VARCHAR2(64) NOT NULL,
  net_amount         VARCHAR2(16),
  transaction_date   DATE,
  transaction_type   VARCHAR2(64),
  isin               VARCHAR2(32),
  qty                VARCHAR2(16),
  price              VARCHAR2(16),
  description        VARCHAR2(256)
);

DROP TABLE mh_security_transactions_ext;