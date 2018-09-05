set lines 160 pages 300 feedback on
col username for a12;
col osuser for a12;
col program for a15;
col machine for a25 trunc;
col sid for 9999;
col logontime for a16;
col serial# for 99999;
col event for a30 trunc;
col inst for 999;
col seconds for 99999;
col dbsrv for a5;
col apsrv for 99999;
col username for a15 trunc
col bs heading 'Blkg|Sess' for 9999

break on inst skip 1;

select a.inst_id "inst", b.spid dbsrv,a.sid,a.serial#,to_char(a.LOGON_TIME,'DD-MON hh24:mi:SS') logontime,
      a.machine, a.username, c.event,c.SECONDS_IN_WAIT seconds, a.blocking_session bs
from   gv$session a, gv$process b, gv$session_wait c
where  a.username is not null
and    a.paddr = b.addr
and    a.sid = c.sid
and    a.status = 'ACTIVE'
and    c.event not like 'SQL*Net%' 
and    c.event not like 'wait for unread message on bro%'
and    c.event <> 'pipe get'
and    c.event <> 'db file sequential read'
and    c.state='WAITING'
--and    c.event='enqueue'
order  by 1,a.logon_time
;
