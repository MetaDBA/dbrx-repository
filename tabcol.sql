col owner form a15
col data_type form a12
col low_value form a8
col high_value form a8
col table_name form a25
col last_analyzed form a13
col num_distinct form 999999999 heading 'Num|Distinct'
col sample_size form 99999999 heading 'Sample|Size'
col buckts form 999999 heading "Buckts"
break on table_name skip 1 


select owner, table_name, column_name, decode(data_type,'VARCHAR2','VARCHR2',data_type) data_type, num_distinct, sample_size, to_char(last_analyzed, 'MMDDYY HH24:MI') last_analyzed, num_buckets buckts 
from dba_tab_columns 
where table_name = upper('&1')
order by owner, table_name, column_id
/
