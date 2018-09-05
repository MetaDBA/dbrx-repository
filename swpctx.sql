------------------------------------------------------------
-- file		swpctx.sql
-- desc		Session wait statitics CHANGE percentage reporting.
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		03-aug-00
-- lst upt	03-aug-00 
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
def old_inst_num=&instnum noprint

col val1 new_val tot_time_waited 
col val2 new_val tot_total_waits

col val3 new_val instnum

select to_char(instance_number) val3 from v$instance;

select		sum(time_waited) val1,
		sum(total_waits) val2
from		v$system_event a
where
       a.event not like 'SQL%'
  and  a.event not like 'KXFX%'
  and  a.event not like 'slave wait'
  and  a.event not like 'PL%'
  and  a.event not like 'Wait for slaves%'
  and  a.event not like 'Parallel%Qu%Idle%Sla%'
  and  a.event not like 'refresh controfile%'
  and  a.event not like 'PX Deq Credit:%'
  and  a.event not like 'PX Deq: Exec%'
  and  a.event not like 'PX Deq: Signal%'
  and  a.event not like 'PX Deq: Table Q%'
  and  a.event not like 'PX Deque%'
  and  a.event not in (
'reliable message',
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'control file sequential read',
'refresh controlfile command',
'Null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'wakeup time manager',
'PX Idle Wait',
'i/o slave wait',
'jobq slave wait',
'pipe get',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client',
'wait for unread message on broadcast channel',
'Streams AQ: qmn coordinator idle wait',
'Streams AQ: waiting for messages in the queue',
'Streams AQ: qmn slave idle wait',
'Streams AQ: waiting for time management or cleanup tasks',
'class slave wait',
'shared server idle wait',
'DIAG idle wait',
'Space Manager: slave idle wait',
'PING',
'ASM background timer',
'gcs remote message',
'ges remote message',
'GCR sleep',
'jobq slave wait')
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
	from system_event_snap_date&instnum a, v$sysstat b
 where b.name = 'CPU used by this session' ; 
set heading on

start osmtitle

col event	format a35	heading "Wait Event" trunc
col tw	 	format 9999990.000	heading "Time Waited|(sec)"
col time_pct 	format 990.00	heading "% Time|Waited"
col wc	 	format 9999990	heading "Waits"
col cnt_pct 	format 9990.00	heading "% Waits"

--	&tot_time_waited-&old_tot_time_waited "Delta",
--	&tot_total_waits-&old_tot_total_waits "Delta",

select 	b.event,
	((b.time_waited-a.time_waited)/100) tw,
	100*((b.time_waited-a.time_waited)/(&tot_time_waited+.000001-&old_tot_time_waited)) time_pct,
	(b.total_waits-a.total_waits) wc,
	100*((b.total_waits-a.total_waits)/(&tot_total_waits+.000001-&old_tot_total_waits)) cnt_pct
from   v$system_event b,
       system_event_snap&instnum a
where  b.event = a.event
  and  b.total_waits > nvl(a.total_waits,0)
  and  100*((b.time_waited-a.time_waited)/(&tot_time_waited+.000001-&old_tot_time_waited)) > 1
  and  b.event not like 'SQL%'
  and  b.event not like 'KXFX%'
  and  a.event not like 'PL%'
  and  b.event not like 'slave wait'
  and  b.event not like 'Wait for slaves%'
  and  b.event not like 'Parallel%Qu%Idle%Sla%'
  and  b.event not like 'refresh controfile%'
  and  a.event not like 'PX Deq Credit:%'
  and  a.event not like 'PX Deq: Exec%'
  and  a.event not like 'PX Deq: Signal%'
  and  a.event not like 'PX Deq: Table Q%'
  and  a.event not like 'PX Deque%'
  and  b.event not in (
'reliable message',
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'control file sequential read',
'refresh controlfile command',
'Null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'wakeup time manager',
'PX Idle Wait',
'i/o slave wait',
'jobq slave wait',
'pipe get',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client',
'wait for unread message on broadcast channel',
'Streams AQ: qmn coordinator idle wait',
'Streams AQ: waiting for messages in the queue',
'Streams AQ: qmn slave idle wait',
'Streams AQ: waiting for time management or cleanup tasks',
'class slave wait',
'shared server idle wait',
'DIAG idle wait',
'gcs remote message',
'Space Manager: slave idle wait',
'PING',
'ASM background timer',
'ges remote message',
'GCR sleep',
'jobq slave wait')
order by time_pct desc, cnt_pct desc, event asc
/

drop table system_event_snap&instnum purge;
drop table system_event_snap_date&instnum purge;
create table system_event_snap&instnum as select * from v$system_event;
create table system_event_snap_date&instnum (sample_date,cpu)
 as select sysdate, value from v$sysstat
 where name = 'CPU used by this session';

start osmclear

