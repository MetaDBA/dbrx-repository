set heading on
def table_name=&&1

col owner       form a12
col iot_type 	form a8 
col owner	form a20
col table_name	form a20
col last_analyzed form a18
col MB form 999999

select owner, table_name, num_rows, blocks,
round(blocks*(select avg(value) from v$parameter
  where name = 'db_block_size')/1048576) MB,
tablespace_name, last_analyzed
from dba_tables
where table_name = upper('&table_name');
