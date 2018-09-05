col owner for a10
col job_name for a40 trunc
col log_date for a40 trunc
set linesize 100
select log_id,owner,job_name,status,log_date from dba_scheduler_job_log
where log_date > sysdate - .5 and status <> 'SUCCEEDED' order by log_date
/

