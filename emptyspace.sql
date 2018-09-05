clear breaks

col blank form a2 heading " "
col suhwm form 999.99 heading "%SU/HWM"
col space_used form 9,999,999,999
col owner form a15 heading "Owner"
col space_used format 999,999,999,999 heading "Space Used"
col high_water_mark format 999,999,999,999 heading "High Water Mark"
col table_name form a30
col tablespace_name form a15

select substr(owner,1,12) Owner,
 table_name,
 num_rows*avg_row_len space_used,
 blocks*(select p.value from v$parameter p
where p.name = 'db_block_size') high_water_mark,
 (100*num_rows*avg_row_len)/((blocks*(select p.value from v$parameter p
where p.name = 'db_block_size'))+.000001) suhwm,
'  ' blank, last_analyzed, tablespace_name
from dba_tables 
where owner not in ('SYS','SYSTEM')
and blocks > 100
and (num_rows*avg_row_len)/((blocks*(select p.value from v$parameter p
where p.name = 'db_block_size'))+.000001) < .7
order by (num_rows*avg_row_len)/((blocks*(select p.value from v$parameter p
where p.name = 'db_block_size'))+.000001);
