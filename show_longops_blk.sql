set linesize 140 pagesize 300
col message for a70 trunc
col opname for a15 trunc
col remaining format a10
col username for a15 trunc
select inst_id, 
        sid, 
        username,
         ROUND(time_remaining/60) || ':' || MOD(time_remaining,60) remaining,
         opname, 
         message
from gv$session_longops
where sofar != totalwork
order by inst_id,username,4
/



