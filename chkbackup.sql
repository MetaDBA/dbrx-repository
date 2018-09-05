select distinct tablespace_name
from dba_data_files d, v$backup b
where b.file# = d.file_id
and b.status = 'ACTIVE';
