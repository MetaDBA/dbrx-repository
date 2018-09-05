select distinct tablespace_name from dba_data_files
where file_id in
(SELECT file# FROM v$datafile
where unrecoverable_time > &input_date)
order by tablespace_name;

