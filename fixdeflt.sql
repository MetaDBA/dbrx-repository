REM The select from dual is here so script works in SQLWorksheet
REM Make sure the new tablespace is the correct one (USERS here)

set echo off
set heading off
set feedback off
spool chgdeflt.sql

select ';' from dual
union
select 'alter user ' || username || ' default tablespace USERS;'
from dba_users
where default_tablespace = 'SYSTEM'
and username <> 'SYS';

spool off

@chgdeflt

set heading on
set feedback on
set echo on
