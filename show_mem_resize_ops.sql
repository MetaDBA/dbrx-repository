select component, 
       oper_type, 
       to_char(end_time,'DD-MON-YYYY HH24:MI:SS') "END_TIME",
       round(initial_size/(1024*1024*1024),1) "INITIAL_SIZE(G)",
       round(final_size/(1024*1024*1024),1) "FINAL_SIZE(G)"
from v$memory_resize_ops
where final_size > 0 AND
      end_time > SYSDATE - 6/24
order by start_time;
