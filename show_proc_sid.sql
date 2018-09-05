SELECT  p.program, p.spid, s.saddr, s.sid, s.serial#, s.username,
        s.osuser, s.machine, s.program, s.logon_time, s.status
FROM v$session s, v$process p
WHERE s.paddr = p.addr
AND p.spid = '&proc';


