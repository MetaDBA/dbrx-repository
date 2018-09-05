set linesize 140 pagesize 30000 colsep  '~'
col program for a15 trunc
col module for a20 trunc
col sample_time for a18 trunc
col event for a20 trunc
col action for a15 trunc
select sample_time,
      program,
      module,
      time_waited ,
      blocking_session_status,
      event,
      action,
      sql_id
from gv$active_session_history 
where sample_time between '05-JUL-13 12.19.58.201 PM' and '05-JUL-13 02.19.58.201 PM'
   and time_waited > 10
   and session_type = 'FOREGROUND'
order by sample_time;