select substr(nvl(decode(type,'BACKGROUND','SYS ('||b.name||')',
        s.username),substr(p.program,instr(p.program,'('))),1,15) oracle_user,
substr(s.sid,1,4) sid_,
substr(s.serial#,1,6) serial,
substr(s.machine,1,20) machine_,
substr(s.osuser,1,8) osuser_,
substr(to_char(s.logon_time,'MM-DD HH24:MI'),1,12) logon_time,
s.process,
s.status
from v$session s, v$bgprocess b, v$process p
where s.paddr = p.addr
and s.username = 'LISTAPP'
and s.paddr = b.paddr (+)
order by s.logon_time
;
