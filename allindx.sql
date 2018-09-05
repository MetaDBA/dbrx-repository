spool allindex.out

set echo off
set pagesize 68
col table_name format a20
col index_name format a25
col column_name format a25
col column_position heading POS format 999
break on table_name skip 2 on index_name skip 1

select c.table_name, c.index_name, c.column_name, c.column_position
from dba_ind_columns c
where c.table_owner = 'WS_APP_OWNER'
order by c.table_name, c.index_name, c.column_position;

select to_char(sysdate, 'MM-DD-YY HH24:MI') "Stats as of",
	a.name "Database",
	to_char(s.startup_time, 'MM-DD-YY HH24:MI:SS')
			"Instance Startup Time"
from v$database a, v$instance s;


spool off
