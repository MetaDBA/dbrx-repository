select  to_char(sum(s2.value),'999,999,999,999') total_curr_pga
from v$sesstat s2, v$statname n2
where s2.statistic# = n2.statistic#
and  n2.name = 'session pga memory';
