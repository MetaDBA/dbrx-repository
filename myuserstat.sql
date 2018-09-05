def stat_name = &1

select vs.sid "SID", c.value, nc.name
from v$sesstat c, v$statname nc, v$session vs
where nc.statistic# = c.statistic#
and nc.name like '&stat_name%'
and c.sid = vs.sid
and vs.audsid = userenv('SESSIONID');
