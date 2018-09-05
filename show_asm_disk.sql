set pagesize 560 linesize 160
col path for a40 trunc
col name for a25 trunc
col total_mb for 9,999,999,999
col free_mb for 9,999,999,999
col header_status for a8 trunc
col grp for 999
col failgroup for a10 trunc
compute sum of total_mb free_mb on report
break on report

select group_number grp,name,total_mb,free_mb,path,mount_status,header_status,state,failgroup 
 from v$asm_disk order by group_number,name;
