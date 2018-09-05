col name for a30 trunc
col usable_file_mb for 9,999,999,999
col total_mb for 9,999,999,999,999
col free_mb for 9,999,999,999,999
set linesize 100 pagesize 100
break on report
compute sum of usable_file_mb on report
compute sum of free_mb on report
compute sum of total_mb on report
select group_number,name,total_mb,usable_file_mb,free_mb from v$asm_diskgroup order by name
/
