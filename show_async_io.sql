set linesize 140 pagesize 200
col file_name for a40 trunc
select file_id, file_name, file_no, asynch_io 
from dba_data_files, v$iostat_file where file_id=file_no;
