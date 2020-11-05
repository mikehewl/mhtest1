CREATE TABLE mh_portfolios
(account                 VARCHAR2(32) NOT NULL PRIMARY KEY,
 type                    VARCHAR2(64),
 name                    VARCHAR2(128),
 currency                VARCHAR2(8));
 
DROP TABLE mh_portfolios;

INSERT INTO mh_Portfolios values ('VIHE0022', 'General Investment', 'Main Portfolio');