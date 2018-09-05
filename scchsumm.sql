select  sum(s1.value) "session cursor cache hits",
 sum(s2.value) "parse count (total)",
 round(100*sum(s1.value)/sum(s2.value)) || '%' "Ratio"
from v$sesstat s1, v$sesstat s2, v$statname n1, v$statname n2
where s1.statistic# = n1.statistic#
and n1.name = 'session cursor cache hits'
and s2.statistic# = n2.statistic#
and n2.name = 'parse count (total)'
and s1.sid = s2.sid;
