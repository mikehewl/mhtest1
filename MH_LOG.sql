CREATE SEQUENCE mh_log_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;

CREATE TABLE mh_log (
log_id                NUMBER DEFAULT mh_log_s.nextval NOT NULL PRIMARY KEY, 
curr_date             DATE DEFAULT SYSDATE NOT NULL ,
message               VARCHAR2(512),
page                  NUMBER,
label                 VARCHAR2(32));
  
DROP TABLE mh_log;

DROP SEQUENCE mh_instruments_s;

CREATE OR REPLACE PROCEDURE MHLOG(
  p_msg                 IN     VARCHAR2,
  p_page                IN     NUMBER DEFAULT NULL,
  p_label               IN     VARCHAR2 DEFAULT NULL)
AS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO mh_log(
    message, page, label)
  VALUES (
    p_msg, p_page, p_label);

  COMMIT;

END;
/