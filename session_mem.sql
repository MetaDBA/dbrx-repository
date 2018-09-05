  select s1.sid, to_char(s1.value,'999,999,999,999') sess_max_uga_mem,
                 to_char(s2.value,'999,999,999,999') sess_max_pga_mem
    from v$sesstat s1, v$sesstat s2, v$statname n1, v$statname n2
   where s1.statistic# = n1.statistic#
    and  s2.statistic# = n2.statistic#
    and  n1.name = 'session uga memory max'
    and  n2.name = 'session pga memory max'
    and  s2.sid = s1.sid
        order by s1.sid;

-------------------------------------------------------------------
set echo off
/* Get total current UGA being used */
select  to_char(sum(s1.value),'999,999,999,999') total_curr_uga
from v$sesstat s1, v$statname n1
   where s1.statistic# = n1.statistic#
    and  n1.name = 'session uga memory'
    ;

select  to_char(sum(s2.value),'999,999,999,999') total_curr_pga
from v$sesstat s2, v$statname n2
   where s2.statistic# = n2.statistic#
    and  n2.name = 'session pga memory'
    ;

/* Get max UGA used by current sessions */
select  to_char(sum(s1.value),'999,999,999,999') total_max_uga
from v$sesstat s1, v$statname n1
   where s1.statistic# = n1.statistic#
    and  n1.name = 'session uga memory max'
    ;

select  to_char(sum(s2.value),'999,999,999,999') total_max_pga
from v$sesstat s2, v$statname n2
   where s2.statistic# = n2.statistic#
    and  n2.name = 'session pga memory max'
    ;

set echo on
-------------------------------------------------------------------

/* Get current UGA & PGA memory in use by session */
  select s1.sid, to_char(s1.value,'999,999,999,999') sess_uga_mem,
                 to_char(s2.value,'999,999,999,999') sess_pga_mem,
                substr(to_char(s.logon_time,'    MM-DD HH24:MI'),1,16) "    Logon_time",
                substr('   ' || s.username,1,11) oracle_user,
                substr(s.osuser,1,8) osuser_
    from v$sesstat s1, v$sesstat s2, v$statname n1,
         v$statname n2, v$session s
   where s1.statistic# = n1.statistic#
    and  s2.statistic# = n2.statistic#
    and  n1.name = 'session uga memory'
    and  n2.name = 'session pga memory'
    and  s2.sid = s1.sid
    and  s2.sid = s.sid
        order by s.sid;

/* Get current UGA & max UGA by session */
  select s1.sid, to_char(s1.value,'999,999,999,999') sess_uga_mem,
                 to_char(s2.value,'999,999,999,999') sess_uga_mem_max,
                 substr(to_char(s.logon_time,'    MM-DD HH24:MI'),1,16) "    Logon_time",
                 substr('   ' || s.username,1,11) oracle_user,
                 substr(s.osuser,1,8) osuser_
   from v$sesstat s1, v$sesstat s2, v$statname n1,
        v$statname n2, v$session s
   where s1.statistic# = n1.statistic#
    and  s2.statistic# = n2.statistic#
    and  n1.name = 'session uga memory'
    and  n2.name = 'session uga memory max'
    and  s2.sid = s1.sid
    and  s2.sid = s.sid
       order by s.sid;
