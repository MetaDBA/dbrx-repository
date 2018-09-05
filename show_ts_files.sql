set linesize 120 pagesize 100
col file_name for a65 trunc
col mb for     9,999,999.99
col mb_max for 9,999,999.99
select file_name,
       bytes/1024/1024 mb,
       maxbytes/1024/1024 mb_max,
       autoextensible  
 from dba_data_files where tablespace_name = upper('&ts')
/
