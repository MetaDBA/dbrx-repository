REM** Note that the db_block_size is here in 4 places.
REM** Make sure you're using the right one.

select substr(owner,1,12) "Owner",
 table_name,
 num_rows*avg_row_len "Space Used",
 blocks*8192 "High Water Mark",
 to_char((100*num_rows*avg_row_len)/((blocks*8192)+.000001),'999.99') "%SU/HWM"
from dba_tables 
where owner not in ('SYS','SYSTEM')
and blocks > 5
and (num_rows*avg_row_len)/((blocks*8192)+.000001) < .7
order by (num_rows*avg_row_len)/((blocks*8192)+.000001);
