CREATE TABLE mh_security_transactions_ext (
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