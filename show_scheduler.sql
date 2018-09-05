set linesize 500 pagesize 40
col program_name for a25 trunc
col job_action for a10 trunc
col program_action for a40 trunc
col program_owner for a12 trunc
col last_start_date for a30 trunc
col default_value for a20 trunc
col argument_type for a10 trunc
set echo on

select job_name,job_style,program_owner,program_name,last_start_date,state,run_count,job_action
 from dba_scheduler_jobs where owner = upper('&owner') order by last_start_date;


select  program_type,program_action from dba_scheduler_programs  
where program_name = upper('&program_name');


select argument_name,argument_type,default_value,out_argument from dba_scheduler_program_args 
  where program_name = upper('&&program_name') order by argument_position;
