set echo on  linesize 140
alter session set nls_date_format = 'dd-mon-yy hh24:mi:ss';
col job_name for a10 tunc
col job_type for a5 tunc 
col start_date for a10 trunc
col next_run_date for a15 trunc
col end_date for a10 trunc
col schedule_name for a30  trunc
select job_name,job_type,enabled,schedule_name,start_date,end_date,next_run_date,state from dba_scheduler_jobs
/
