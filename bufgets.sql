select vs.sid "SID", a.value + b.value "Buffer Gets", c.value "Physical Reads"
from v$sesstat a, v$sesstat b, v$sesstat c, v$statname na, v$statname nb, v$statname nc, v$session vs
where na.statistic# = a.statistic#
and na.name like 'consistent gets%'
and nb.statistic# = b.statistic#
and nb.name like 'db block gets%'
and nc.statistic# = c.statistic#
and nc.name like 'physical reads%'
and nc.name not like 'physical reads direct%'
and a.sid = vs.sid
and b.sid = vs.sid
and c.sid = vs.sid
and vs.audsid = userenv('SESSIONID');
