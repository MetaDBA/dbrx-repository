column session format a20
column username format a10
column "session status" format a15
select ''''||sid||','||serial#||'''' "session",s.status "session status",t.status "txn status", username,USED_UBLK,machine,program  from v$session s , v$transaction t
    where s.saddr=t.ses_addr order by "session",machine,program,username;

