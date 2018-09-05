REM To find an oracle session using the UNIX process number

select substr(s.username,1,15) user_,
substr(s.osuser,1,8) "OS User",
substr(to_char(logon_time,'MM-DD HH24:MI'),1,14) logon_time,
s.process "Prog Proc",
p.spid "OS Proc", 
substr(sid,1,4) sid_, s.serial#,
s.status,
substr(s.machine,1,20) machine_
from sys.v_$session s, sys.v_$process p
where p.spid = --Put UNIX process number here-- 
and p.addr(+)=s.paddr






