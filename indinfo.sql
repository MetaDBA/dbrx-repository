set heading on
def index_name=&&1

col owner       format a15
col table_name  format a20
col index_name  format a25
col tablespace  format a12

select owner, table_name, index_name, round(num_rows/1000000) "ROWS(M)", leaf_blocks,
round(leaf_blocks*(select avg(value) from v$parameter
  where name = 'db_block_size')/1048576) MB,
tablespace_name tablespace, to_char(last_analyzed, 'MM:DD:YYYY HH24:MI') analyzed
from dba_indexes
where index_name = upper('&index_name');
