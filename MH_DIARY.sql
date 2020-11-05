CREATE SEQUENCE mh_diary_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_diary_s;

CREATE TABLE mh_diary (
diary_id                     NUMBER DEFAULT mh_diary_s.nextval NOT NULL PRIMARY KEY,  -- Default value required by APEX Interactive grid
diary_date                   DATE NOT NULL,
end_date                     DATE,
portfolio                    VARCHAR2(32),
asset                        VARCHAR2(32), 
instrument_id                NUMBER,
title                        VARCHAR2(32),
message                      VARCHAR2(1024),
CONSTRAINT mh_diary_fk1 FOREIGN KEY (portfolio) REFERENCES mh_portfolios (account),
CONSTRAINT mh_diary_fk2 FOREIGN KEY (portfolio, asset) REFERENCES mh_portfolio_assets (portfolio, asset),
CONSTRAINT mh_diary_fk3 FOREIGN KEY (instrument_id) REFERENCES mh_instruments (instrument_id)
);
  
DROP TABLE mh_diary;