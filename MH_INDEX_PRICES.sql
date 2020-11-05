CREATE TABLE mh_index_prices (
index_name                   VARCHAR2(32) NOT NULL,
price_date                   DATE NOT NULL,
open_price                     NUMBER,
close_price               NUMBER,
high_price                        NUMBER,
low_price               VARCHAR2(8),
volume                        NUMBER,
CONSTRAINT mh_index_prices_pk1 PRIMARY KEY(index_name, price_date)
);

DROP TABLE mh_index_prices;