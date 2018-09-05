
set echo off
set feedback off
set verify off
set termout off
col val1 new_val time_diff noprint

set lines 132

select round(avg(sysdate - a.sample_date)*86400) val1 from commit_snap_date a;

set termout on

col statvalue format 999,999,999 heading "Commits"
col persec    format 9,999.99    heading "Commits|/Sec"
col seconds   format 999,999     heading "Seconds"

select
  v.value - c.commits      statvalue,
  &time_diff    seconds,
  round((v.value - c.commits) / &time_diff, 2) persec
from
  commit_snap c,
  v$statname    n,
  v$sysstat             v
where
  n.statistic# = v.statistic# and
  n.name = 'user commits';

prompt 

drop table commit_snap purge;
drop table commit_snap_date purge;
create table commit_snap as 
  select
  v.value       commits  
from
  v$statname    n,
  v$sysstat             v
where
  n.statistic# = v.statistic# and
  n.name = 'user commits';

create table commit_snap_date (sample_date)
 as select sysdate from dual;

