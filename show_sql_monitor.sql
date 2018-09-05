select 
 STATUS,
 PROCESS_NAME,
 OUTPUT_ROWS
from gv$sql_plan_monitor 
where sid = &sid
and inst_id = &inst_id 
and plan_operation='PX SEND' and sql_id = '&sql_id'
order by key,last_refresh_time, plan_line_id
/
