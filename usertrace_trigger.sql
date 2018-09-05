CREATE OR REPLACE TRIGGER sys.usertrace
AFTER LOGON
ON DATABASE
BEGIN
   IF SYS_CONTEXT ('USERENV', 'SESSION_USER') = 'SSTRACHAN'
   THEN
     execute immediate 'ALTER SESSION SET events ''10046 trace name context forever, level 8''';
   END IF;
END;
/



