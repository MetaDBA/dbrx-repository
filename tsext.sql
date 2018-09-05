col tablespace_name format a20 heading "Tablespace"
col bytesno format 999,999 heading "Bytes(MB)"
col maxbytesno format 999,999 heading "MaxBytes(MB)"
col space format 999,999 heading "Extensible(MB)"

select 
tablespace_name, 
sum(bytes)/1048576 bytesno, 
sum(maxbytes +(greatest(0,(bytes - maxbytes))))/1048576 maxbytesno, 
sum(greatest(0,(maxbytes - bytes)))/1048576 space
from dba_data_files 
group by tablespace_name
order by tablespace_name;
