col oracle_user form a15
col machine_ 	form a22
col osuser_	form a10
col logon_time	form a11
col serial	form a8
col sid_	form a7      heading "Inst:|SID"
col c_process   form a11     heading "Client|Process"
col s_process   form a11     heading "Server|Process"
col last_call_time form a18


select substr(nvl(decode(type,'BACKGROUND','SYS ('||b.name||')',
        s.username),substr(p.program,instr(p.program,'('))),1,15) oracle_user,
s.inst_id || ':' || substr(s.sid,1,4) sid_,
substr(s.serial#,1,6) serial,
substr(s.machine,1,22) machine_,
substr(s.osuser,1,8) osuser_,
substr(to_char(s.logon_time,'MM-DD HH24:MI'),1,12) logon_time,
s.process c_process,
p.spid s_process,
sysdate - s.last_call_et/86400 last_call_time,
s.status
from gv$session s, gv$bgprocess b, gv$process p
where s.paddr = p.addr
and s.inst_id = p.inst_id
and s.paddr = b.paddr (+)
and s.inst_id = p.inst_id (+)
order by sid_ 
;
