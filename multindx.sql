spool multindex.out

set echo off
set pagesize 68
col table_name format a20
col index_name format a29
col column_name format a24
col column_position heading POS format 999
break on table_name skip 2 on index_name skip 1

select c.table_name, c.index_name, c.column_name, c.column_position
from dba_ind_columns c
where table_owner = '&table_owner'
and table_name in
(select a.table_name
from dba_indexes a, dba_indexes b
where a.table_name = b.table_name
and a.index_name <> b.index_name
and a.table_owner = b.table_owner
and a.table_owner = c.table_owner)
order by c.table_name, c.index_name, c.column_position;

select to_char(sysdate, 'MM-DD-YY HH24:MI') "Stats as of",
	a.name "Database",
	to_char(s.startup_time, 'MM-DD-YY HH24:MI:SS')
			"Instance Startup Time"
from v$database a, v$instance s;


spool off
