CREATE TABLE mh_notifications (
notification_id              NUMBER NOT NULL PRIMARY KEY,
table_name                   VARCHAR2(32), -- e.g. 'MH_DIVIDENDS' 
table_id                     NUMBER,
notif_level                  VARCHAR2(4) NOT NULL,  -- 'E' - Error, 'W' - Warning, 'I' - Info 
message                      VARCHAR2(1024),
status                       VARCHAR2(4)            -- 'A' - Active, 'X' - Inactive 
);
  
DROP TABLE mh_notifications;

CREATE SEQUENCE mh_notifications_s 
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
  
DROP SEQUENCE mh_notifications_s;

