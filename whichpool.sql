col ordr noprint

select a.name, to_char(a.value,'999,999,999,999')  "Pool Size"
from v$parameter a
 where a.name in ('db_keep_cache_size','db_recycle_cache_size');

select 1 ordr, 'Total' "Total", 'Tables' "Segmnts", 'Keep' "Pool", to_char(sum((select value from v$parameter
        where name = 'db_block_size') * blocks),'999,999,999,999') "Size"
 from dba_tables
where buffer_pool = 'KEEP'
union
select 2 ordr, 'Total', 'Indexes', 'Keep', to_char(sum((select value from v$parameter
        where name = 'db_block_size') * leaf_blocks),'999,999,999,999') "Size"
  from dba_indexes
where buffer_pool = 'KEEP'
union
select 3 ordr, 'Total', 'Tables', 'Recycle', to_char(sum((select value from v$parameter
        where name = 'db_block_size') * blocks),'999,999,999,999') "Size"
 from dba_tables
where buffer_pool = 'RECYCLE'
union
select 4 ordr, 'Total', 'Indexes', 'Recycle', to_char(sum((select value from v$parameter
        where name = 'db_block_size') * leaf_blocks),'999,999,999,999') "Size"
  from dba_indexes
where buffer_pool = 'RECYCLE';

select 1 ordr, substr(owner,1,10) "OWNER", 'Table  ' || table_name  "Object Name", 
 buffer_pool "Pool",
 to_char(((select value from v$parameter 
        where name = 'db_block_size') * blocks),'999,999,999,999') "Size"
 from dba_tables
where buffer_pool <> 'DEFAULT'
union
select 2 ordr, substr(owner,1,10) "OWNER", 'Index  ' || index_name  "Object Name",
 buffer_pool "Pool",
 to_char(((select value from v$parameter 
        where name = 'db_block_size') * leaf_blocks),'999,999,999,999') "Size"
  from dba_indexes
where buffer_pool <> 'DEFAULT'
order by 4, 1;
