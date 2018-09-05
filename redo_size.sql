select vs.sid "SID", a.value "Redo Size"
from v$sesstat a,  v$statname na,  v$session vs
where na.statistic# = a.statistic#
and na.name like 'redo size%'
and a.sid = vs.sid
and vs.sid = &sid;
