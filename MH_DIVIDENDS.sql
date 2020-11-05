CREATE TABLE mh_dividends (
cash_transaction_id            NUMBER NOT NULL REFERENCES mh_cash_transactions (cash_transaction_id),
instrument_id                  NUMBER REFERENCES mh_instruments (instrument_id),
dividend_type                  VARCHAR2(8),   -- 'DIV' - Dividend, 'TAX' - Tax Credit, 'XXX' - Unknown
description                    VARCHAR2(256),
quantity                       NUMBER,
dividend_date                  DATE, 
CONSTRAINT mh_dividends_pk     PRIMARY KEY (CASH_TRANSACTION_ID)
);

DROP TABLE mh_dividends;