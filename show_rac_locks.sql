-- GES LOCK BLOCKERS:
-- This section will show us any sessions that are holding locks that
-- are blocking other users.  The inst_id will show us the instance that
-- the session resides on while the sid will be a unique identifier for
-- the session.  The grant_level will show us how the GES lock is granted to 
-- the user.  The request_level will show us what status we are trying to obtain.
-- The lockstate column will show us what status the lock is in.  The last column 
-- shows how long this session has been waiting.
--
set numwidth 5
column spid for 99999
column state format a16 tru;
column event format a30 tru;
select dl.inst_id, s.sid, p.spid, dl.resource_name1, dl.owner_node,dl.resource_name2,
decode(substr(dl.grant_level,1,8),'KJUSERNL','Null','KJUSERCR','Row-S (SS)',
'KJUSERCW','Row-X (SX)','KJUSERPR','Share','KJUSERPW','S/Row-X (SSX)',
'KJUSEREX','Exclusive',request_level) as grant_level,
decode(substr(dl.request_level,1,8),'KJUSERNL','Null','KJUSERCR','Row-S (SS)',
'KJUSERCW','Row-X (SX)','KJUSERPR','Share','KJUSERPW','S/Row-X (SSX)',
'KJUSEREX','Exclusive',request_level) as request_level, 
decode(substr(dl.state,1,8),'KJUSERGR','Granted','KJUSEROP','Opening',
'KJUSERCA','Canceling','KJUSERCV','Converting') as state,
s.sid, sw.event, sw.seconds_in_wait sec
from gv$ges_enqueue dl, gv$process p, gv$session s, gv$session_wait sw
where blocker = 1
and (dl.inst_id = p.inst_id and dl.pid = p.spid)
and (p.inst_id = s.inst_id and p.addr = s.paddr)
and (s.inst_id = sw.inst_id and s.sid = sw.sid)
order by sw.seconds_in_wait desc;
