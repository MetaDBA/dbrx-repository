col tabname format a12 heading 'Table'       
col uniq    format a10 heading 'Uniqueness'  justify c trunc
col indname format a20 heading 'Index Name'  justify c trunc
col colname format a12 heading 'Column Name' justify c trunc
col dist    format 999,999,999 heading 'Distinct Keys' justify c trunc
col segsize format 99,999      heading 'Size (MB)'     justify c trunc
col tsname  format a15 heading 'Tablespace'  justify c trunc
col samp    format 99999999999 heading 'Sample Size' 

break on tabname skip 1 on indname skip 1 on uniq

select
  ind.table_name                  tabname,
  ind.uniqueness                  uniq,
  col.index_name                  indname,
  col.column_name                 colname,
  ind.distinct_keys               dist,
  ind.sample_size                 samp
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
  col.column_position
/
