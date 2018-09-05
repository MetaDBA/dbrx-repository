set linesize 100 trimspool on pagesize 100
col actual_start_date for a40 trunc
col run_duration for a15 trunc
col status for a10 trunc
select  ACTUAL_START_DATE, RUN_DURATION, status
 from DBA_SCHEDULER_JOB_RUN_DETAILS where job_name = upper('&job_name')
order by 1;
