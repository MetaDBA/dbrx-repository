
set echo off
set feedback off
set verify off
set termout off
col val1 new_val time_diff noprint

set lines 132

select round(avg(sysdate - a.sample_date)*86400) val1 from exec_snap_date a;

set termout on

col statvalue format 999,999,999 heading "Execs"
col persec    format 9,999.99    heading "Execs|/Sec"
col seconds   format 999,999     heading "Seconds"

select
  v.value - c.execs      statvalue,
  &time_diff    seconds,
  round((v.value - c.execs) / &time_diff, 2) persec
from
  exec_snap c,
  v$statname    n,
  v$sysstat             v
where
  n.statistic# = v.statistic# and
  n.name = 'execute count';

prompt 

drop table exec_snap purge;
drop table exec_snap_date purge;
create table exec_snap as 
  select
  v.value       execs  
from
  v$statname    n,
  v$sysstat             v
where
  n.statistic# = v.statistic# and
  n.name = 'execute count';

create table exec_snap_date (sample_date)
 as select sysdate from dual;

