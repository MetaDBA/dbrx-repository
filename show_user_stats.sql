
select  sn.NAME stastic,
	VALUE usage
from 	v$session ss, 
	v$sesstat se, 
	v$statname sn
where  	se.STATISTIC# = sn.STATISTIC#
and  	se.SID = ss.SID
and	se.VALUE > 0
and     sn.name = 'rows processed'
and     se.sid = &sid
-- order  	by se.VALUE desc
 order  	by sn.name
/
