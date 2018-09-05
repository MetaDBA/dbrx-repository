REM The select from dual is here so script works in SQLWorksheet

set echo off
set heading off
set feedback off
spool end_backup_TS.sql

select ';' from dual
union
select 'alter tablespace ' || 
a.tablespace_name || ' end backup;'
from dba_tablespaces a
where a.tablespace_name in 
(select distinct d.tablespace_name
from dba_data_files d, v$backup b
where b.file# = d.file_id
and b.status = 'ACTIVE');

spool off

@end_backup_TS

set heading on
set feedback on
set echo on