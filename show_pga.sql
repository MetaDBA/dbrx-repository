set pagesize 40
col name format A45
col value format 9,999,999,999,999
set linesize 190 pagesize 5000
col pga_used_mem format 999,999,999,999
col machine for a30 trunc
compute sum label 'total sid' avg label 'avg sid' of pga_used_mem on inst_id
compute sum label 'total db' avg label 'avg db' of pga_used_mem on report
break on inst_id on report
select
  s.inst_id,
  s.sid,
  s.username,
  s.machine,
  s.logon_time,
  p.pga_used_mem
from gv$session s,
     gv$process p
where s.paddr = p.addr and
      s.inst_id = p.inst_id
order by s.inst_id,pga_used_mem
/
select * from v$pgastat
/
-- select from v$pga_target_advice after changing parm

select name, round(value/(1024*1024*1024),1) "size(g)" 
from v$pgastat
/

