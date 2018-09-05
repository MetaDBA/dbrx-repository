
set pagesize 0
column username format a10
column sql_text format A64 WRAP OFF
column logon_time format a18
column process format A10
column pid format 9999999
column spid format A10
break on process on logon_time on inst_id on process on pid on spid skip 2
select 
  s.inst_id,
  s.sid||','|| s.serial# process,
  p.pid,
  p.spid,
  s.logon_time,
  t.sql_text sql_text
from gv$session s,
     gv$sqltext t,
     gv$process p
where s.sql_address = t.address and s.inst_id = t.inst_id
  and s.paddr = p.addr and s.inst_id = p.inst_id
  and s.sid = &sid and s.inst_id = &inst_id
  order by process,
           piece
/

set pagesize 10
select pdml_enabled,
       pdml_status,
       pddl_status,
       pq_status 
from gv$session s where s.sid = &&sid and s.inst_id = &&inst_id
/
