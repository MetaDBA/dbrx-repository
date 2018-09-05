SET PAGESIZE 0 LONG 405000 TRIMSPOOL ON LINESIZE 500 FEEDBACK OFF VERIFY OFF
exec dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
COLUMN src FORMAT A500
ACCEPT type PROMPT 'Object Type :'
ACCEPT object PROMPT 'Object Name :'
ACCEPT owner PROMPT 'Owner :'
spool &&object-&&type..sql
SELECT dbms_metadata.get_ddl(RTRIM(UPPER('&&type')), RTRIM(UPPER('&&object')),RTRIM(UPPER('&&owner'))) src FROM dual;
spool off

