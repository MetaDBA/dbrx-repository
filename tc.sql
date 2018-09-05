col table_name form a12
col column_name form a12
col data_type form a12
col buckets form 9999999
col sample_size form 99999999 heading 'Sample|Size'
col buckets form 9999
col num_distinct form 99999999

break on table_name skip 1 

select table_name, column_name, data_type, num_distinct,
 sample_size, to_char(last_analyzed, '     HH24:MI:SS') last_analyzed,
 num_buckets buckets 
from dba_tab_columns 
where table_name in ('FILE_HISTORY','PROP_CAT')
order by table_name, column_id;

