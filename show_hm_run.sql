set linesize 100 pagesize 100
col name for a10 trunc
col check_name for a31 trunc
col end_time for a30 trunc
select  name,check_name,run_mode,status,end_time from v$hm_run order by end_time;
