set linesize 140 pagesize 100
col inst_id for 99
col event for a30 trunc
col "TIME_WAITED (s)" for 9,999,999,999
col "AVG I/O(ms)" for 99,999.99
col wait_class for a15 trunc
select inst_id, event, total_waits, time_waited "TIME_WAITED (s)", 
       ROUND(time_waited_micro/total_waits/1000,2) "AVG I/O(ms)", 
       wait_class
from gv$system_event
where wait_class IN ('System I/O','User I/O') and
      total_waits > 10000 and
      ROUND(time_waited_micro/total_waits/1000,2) > 2
ORDER BY 4 desc;


