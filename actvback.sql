select f.tablespace_name, b.status, f.file_name 
from v$backup b, dba_data_files f
where b.file# = f.file_id
order by b.status, f.tablespace_name