set echo off
select 	to_char(sum(s1.value),'999,999,999,999') total_curr_uga
from v$sesstat s1, v$statname n1
   where s1.statistic# = n1.statistic#
    and  n1.name = 'session uga memory'
    ;

select 	to_char(sum(s2.value),'999,999,999,999') total_curr_pga
from v$sesstat s2, v$statname n2
   where s2.statistic# = n2.statistic#
    and  n2.name = 'session pga memory'
    ;

select 	to_char(sum(s1.value),'999,999,999,999') total_max_uga
from v$sesstat s1, v$statname n1
   where s1.statistic# = n1.statistic#
    and  n1.name = 'session uga memory max'
    ;

select 	to_char(sum(s2.value),'999,999,999,999') total_max_pga
from v$sesstat s2, v$statname n2
   where s2.statistic# = n2.statistic#
    and  n2.name = 'session pga memory max'
    ;

set echo on
