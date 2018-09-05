col oracle_user form a12
col machine_ 	form a22
col osuser_	form a08
col logon_time	form a11
col serial	form a6
col sid_	form a4
col c_process   form a11     heading "Client|Process"
col s_process   form a7      heading "Server|Process"
col last_call_time form a18
col sql_id 	form a15


select substr(nvl(decode(type,'BACKGROUND','SYS ('||b.name||')',
        s.username),substr(p.program,instr(p.program,'('))),1,15) oracle_user,
substr(s.sid,1,4) sid_,
substr(s.serial#,1,6) serial,
substr(s.machine,1,22) machine_,
substr(s.osuser,1,8) osuser_,
substr(to_char(s.logon_time,'MM-DD HH24:MI'),1,12) logon_time,
s.process c_process,
p.spid s_process,
sysdate - s.last_call_et/86400 last_call_time,
s.sql_id
from v$session s, v$bgprocess b, v$process p
where s.paddr = p.addr
and s.status = 'ACTIVE'
and s.paddr = b.paddr (+)
order by last_call_time
;


