set echo off
set feedback off
set verify off
set termout off
--col val1 new_val time_diff noprint

set lines 132

/* select round(avg(sysdate - a.sample_date)*86400) val1 from transex_snap_date a; */

set termout on
col statvaluec format 999,999,999 heading "Commits"
col statvaluee format 999,999,999 heading "Execs"
col cpersec    format 9,999.99    heading "Commits|/Sec"
col epersec    format 9,999.99    heading "Execs|/Sec"
col seconds   format 999,999      heading "Seconds"
col expercom  format 999,999      heading "Execs/|Trans"

select
  round((sysdate - t.sample_date)*86400) seconds,
  v1.value - t.commits      statvaluec,
  round((v1.value - t.commits) / ((sysdate - t.sample_date)*86400), 2) cpersec,
  v2.value - t.execs   statvaluee,
  round((v2.value - t.execs) / ((sysdate - t.sample_date)*86400), 2) epersec,
 round((v2.value - t.execs)/(v1.value - t.commits)) expercom 
from
  transex_snap t,
  v$statname    n1,
  v$sysstat             v1,
  v$statname    n2,
  v$sysstat             v2
where
  n1.statistic# = v1.statistic# and
  n1.name = 'user commits' and
  n2.statistic# = v2.statistic# and
  n2.name = 'execute count';

prompt

--drop table transex_snap_date;
drop table transex_snap purge;

--create table transex_snap_date (sample_date)
-- as select sysdate from dual;

create table transex_snap as
select
  sysdate sample_date,
  v1.value commits,
  v2.value execs
from
  v$statname    n1,
  v$sysstat             v1,
  v$statname    n2,
  v$sysstat             v2
where
  n1.statistic# = v1.statistic# and
  n1.name = 'user commits' and
  n2.statistic# = v2.statistic# and
  n2.name = 'execute count';

