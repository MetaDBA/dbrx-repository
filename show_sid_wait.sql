set linesize 100

select sid, event, time_waited, round(time_waited_micro/1000000,1) sec
  from gv$session_event where sid=&sid and inst_id=&inst_id
  order by 3;

