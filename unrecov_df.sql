col file_name form a40
col tablespace_name form a15

select tablespace_name, file_name, unrecoverable_time
  from dba_data_files d, v$datafile v
  where file_id =file#
and unrecoverable_time > (sysdate - 1)
order by 2
/

