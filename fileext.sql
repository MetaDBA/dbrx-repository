break on tablespace_name
compute sum LABEL Total_Extensible_MB of space on tablespace_name

col file_name format a60 heading "File Name"
col tablespace_name format a21 heading "Tablespace"
col bytesno format 999,999 heading "Bytes(MB)"
col maxbytesno format 999,999 heading "MaxBytes|(MB)"
col space format 999,999 heading "Extnsble|(MB)"
col aut format a3 heading "Aut"
col fid format 9999

select file_name,
tablespace_name, 
bytes/1048576 bytesno, 
maxbytes/1048576 maxbytesno, 
greatest(0,(maxbytes - bytes))/1048576 space,
autoextensible aut,
file_id fid
from dba_data_files where tablespace_name like upper('&1%')
order by tablespace_name, file_name
/
