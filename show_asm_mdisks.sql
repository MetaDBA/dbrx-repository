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
select substr(path,1,13) cell,
count(1)
 from v$asm_disk 
group by substr(path,1,13) 
order by 1;
