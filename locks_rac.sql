set lines 120
set pagesize 999
column inst_id format 99 heading INST
column Username format A15 
column Sid format 9990 heading SID
column stat format a4
column spid format a7
column source format a25 truncate
column event format a19 truncate heading "WAIT EVENT"
column l_r format a5
column act format a5
break on Id1 skip 1 dup
SELECT /*+ ORDERED USE_NL(l,s) */
l.inst_id,DECODE(l.request,0,'HOLD','Wait') stat, LPAD(p.spid,7) spid, l.sid, s.serial#, s.username||'('||s.osuser||')'||
decode(substr(s.machine,1,25),NULL,decode(substr(s.terminal,1,7),NULL,'unknown',substr(s.terminal,1,7)),
substr(s.machine,1,decode(instr(s.machine,'.'),0,16,instr(s.machine,'.') -1))) source, 
decode(w.event,'SQL*Net message from client','SQL*Net msg client',w.event) event, l.id1, l.id2, l.lmode||'>'||
l.request l_r, l.type ty,SUBSTR(s.status,1,1)||ROUND(l.ctime/60) Act
FROM gv$lock l , gv$session s, gv$process p, gv$session_wait w
WHERE (l.id1, l.id2) IN (SELECT id1, id2 FROM gv$lock WHERE request>0) 
and l.sid = s.sid and s.sid=w.sid AND s.paddr = p.addr and s.inst_id=p.inst_id 
and l.inst_id=p.inst_id and w.inst_id=l.inst_id
ORDER BY l.id1, l.id2,l.request;

