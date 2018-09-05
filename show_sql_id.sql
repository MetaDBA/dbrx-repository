select 
 INST_ID,
 SQL_ID,
 SQL_CHILD_NUMBER,
 SQL_EXEC_ID,
 PREV_SQL_ID,
 PREV_CHILD_NUMBER,
 PREV_EXEC_ID 
from gv$session
where sid = &sid;

select distinct SQL_ID,
 SQL_CHILD_NUMBER,
 TOP_LEVEL_SQL_ID,
 SESSION_STATE
from gv$active_session_history 
where session_id = &&sid
and SAMPLE_TIME > sysdate -.01;
