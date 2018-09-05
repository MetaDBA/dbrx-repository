------------------------------------------------------------
-- file		swpctxall.sql
-- desc		Session wait statitics CHANGE percentage reporting.
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		03-aug-00
-- lst upt	19-dec-03  Terry Sutton-- includes "idle" events 
-- copyright	(c)2000 OraPub, Inc.

-- It is possible to get percentages greater than 100% because there
-- is a time lag between the total calculations (which queries
-- from v$system_event) and the report query (which also queries from
-- v$system_event).
------------------------------------------------------------

set echo off
set feedback off
set heading off
set verify off
set pagesize 60

def old_tot_time_waited=&tot_time_waited noprint
def old_tot_total_waits=&tot_total_waits noprint

col val1 new_val tot_time_waited 
col val2 new_val tot_total_waits

select		sum(time_waited) val1,
		sum(total_waits) val2
from		v$system_event a
/

set echo off
set feedback off
set heading on
set verify off

def osm_prog	= 'swpctx.sql'
def osm_title	= 'System Event CHANGE Activity By PERCENT' || interval

set lines 132
set heading off
select 'Sample interval was ' || round(avg(sysdate - a.sample_date)*86400) || ' seconds. CPU used was ' 
	|| avg(b.value - a.cpu)/100 || ' seconds, or ' 
	|| round((avg(b.value - a.cpu))/(avg(sysdate - a.sample_date)*864000))/10 || ' CPUsecs/second.' 
	from system_event_snap_date a, v$sysstat b
 where b.name = 'CPU used by this session' ; 
set heading on

start osmtitle

col event	format a35	heading "Wait Event" trunc
col tw	 	format 9990.000	heading "Time Waited|(sec)"
col time_pct 	format 990.00	heading "% Time|Waited"
col wc	 	format 9999990	heading "Waits"
col cnt_pct 	format 990.00	heading "% Waits"

--	&tot_time_waited-&old_tot_time_waited "Delta",
--	&tot_total_waits-&old_tot_total_waits "Delta",

select 	b.event,
	((b.time_waited-a.time_waited)/100) tw,
	100*((b.time_waited-a.time_waited)/(&tot_time_waited+.000001-&old_tot_time_waited)) time_pct,
	(b.total_waits-a.total_waits) wc,
	100*((b.total_waits-a.total_waits)/(&tot_total_waits+.000001-&old_tot_total_waits)) cnt_pct
from   v$system_event b,
       system_event_snap a
where  b.event = a.event
  and  b.total_waits > nvl(a.total_waits,0)
order by time_pct desc, cnt_pct desc, event asc
/

drop table system_event_snap;
drop table system_event_snap_date;
create table system_event_snap as select * from v$system_event;
create table system_event_snap_date (sample_date,cpu)
 as select sysdate, value from v$sysstat
 where name = 'CPU used by this session';

start osmclear

