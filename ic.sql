col index_name form a18
col uniq    format a10 heading 'Uniqueness'  justify c trunc
col indname format a20 heading 'Index Name'  justify c trunc
col dist    format 99,999,999 heading 'Distinct Keys' justify c trunc
col column_name form a12
col table_name form a12

break on indname skip 1 on uniq

select
  ind.table_name,
  ind.uniqueness uniq,
  col.index_name indname,
  col.column_name,
  ind.distinct_keys dist,
  ind.sample_size
from
  dba_ind_columns  col,
  dba_indexes      ind
where
  ind.table_owner = 'TSUTTON'
    and
  ind.table_name in ('FILE_HISTORY','PROP_CAT')
    and
  col.index_owner = ind.owner 
    and
  col.index_name = ind.index_name
    and
  col.table_owner = ind.table_owner
    and
  col.table_name = ind.table_name
order by
  col.table_name,
  col.index_name,
  col.column_position;

