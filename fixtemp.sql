REM The select from dual is here so script works in SQLWorksheet

set echo off
set heading off
set feedback off
spool chgtemp.sql

select ';' from dual
union
select 'alter user ' || username || ' temporary tablespace &entertempTSname;'
from dba_users
where temporary_tablespace = 'SYSTEM';

spool off

@chgtemp

set heading on
set feedback on
set echo on
