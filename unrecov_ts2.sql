select tablespace_name, unrecoverable_time
from dba_data_files d, v$datafile v
where file_id =file#
and unrecoverable_time > &input_date
order by tablespace_name;
