/* =============================================================================
Name:                   MH_INSTRUMENTS.sql
Version:		1.0

Create table MH_INSTRUMENTS to store individual instrument details

Vn History
1.0   05 Nov 2020  Added Header
1.01  23 Nov 2020  Added DEFAULT clause for col INSTRUMENT_ID
============================================================================= */
CREATE SEQUENCE mh_instruments_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_instruments_s;

CREATE TABLE mh_instruments (
instrument_id                NUMBER DEFAULT MIKEH.MH_INSTRUMENTS_S.NEXTVAL NOT NULL PRIMARY KEY,
instrument_name              VARCHAR2(64) NOT NULL,
portfolio                    VARCHAR2(32) NOT NULL,
instrument_currency          VARCHAR2(8),
book_cost                    NUMBER,
asset                        VARCHAR2(32),
sector                       VARCHAR2(32),
country                      VARCHAR2(32),
region                       VARCHAR2(32),
type                         VARCHAR2(32),
isin                         VARCHAR2(32),
quantity                     NUMBER,  -- No of Shares
quantity_unit                VARCHAR2(8), -- 'EA' Each, 'GBP' or 'USD'
dividend_period_months       NUMBER,
tax_credit_period_months     NUMBER,
CONSTRAINT mh_instruments_u2 UNIQUE (portfolio, instrument_name, instrument_currency),
CONSTRAINT mh_instruments_fk1 foreign key (portfolio, asset)   REFERENCES mh_portfolio_assets (portfolio, asset));
  
DROP TABLE mh_instruments;

