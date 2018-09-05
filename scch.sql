select n1.name, s1.value, n2.name, s2.value
from v$sesstat s1, v$sesstat s2, v$statname n1, v$statname n2
where s1.statistic# = n1.statistic#
and n1.name = 'session cursor cache hits'
and s2.statistic# = n2.statistic#
and n2.name = 'parse count (total)'
and s1.sid = s2.sid;
