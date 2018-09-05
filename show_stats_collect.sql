set linesize 100 pagesize 100
col job_start_time for a30 trunc
col job_info for a30 trunc
select job_status,
       job_start_time,
       job_info 
 from dba_autotask_job_history 
  where client_name  = 'auto optimizer stats collection' 
   order by client_name,window_start_time;
