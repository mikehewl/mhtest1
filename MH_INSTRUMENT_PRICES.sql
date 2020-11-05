CREATE TABLE mh_instrument_prices (
instrument_id                NUMBER NOT NULL,
price_date                   DATE NOT NULL,
quantity                     NUMBER,
quantity_unit                VARCHAR2(8),
price                        NUMBER,
price_currency               VARCHAR2(8),
value                        NUMBER,
value_currency               VARCHAR2(8),
CONSTRAINT mh_instrument_prices_pk1 PRIMARY KEY(instrument_id, price_date),
CONSTRAINT mh_instrument_prices_fk1 FOREIGN KEY (instrument_id) REFERENCES mh_instruments (instrument_id)
);

DROP TABLE mh_instrument_prices;