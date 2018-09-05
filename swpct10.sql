------------------------------------------------------------
-- file		swpct.sql
-- desc		Session wait statitics percentage reporting.
-- author	Craig A. Shallahamer, craig@orapub.com
-- orig		14-jul-00
-- lst upt	03-aug-00 : added more waits to exclude.
-- copyright	(c)2000 OraPub, Inc.
------------------------------------------------------------

def filter=&1

set echo off
set feedback off
set heading off
set verify off

col val1 new_val tot_time_waited noprint
col val2 new_val tot_total_waits noprint

select		sum(time_waited) val1,
		sum(total_waits) val2
from		v$system_event a
where 
       a.event not like 'SQL%'
  and  a.event not like 'KXFX%'
  and  a.event not like 'slave wait'
  and  a.event not like 'Wait for slaves%'
  and  a.event not like 'Parallel%Qu%Idle%Sla%'
  and  a.event not like 'refresh controfile%'
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
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client',
'wait for unread message on broadcast channel',
'Streams AQ: qmn coordinator idle wait',
'Streams AQ: waiting for messages in the queue',
'Streams AQ: qmn slave idle wait',
'Streams AQ: waiting for time management or cleanup tasks',
'jobq slave wait')
/

set echo off
set feedback off
set heading on
set verify off

def osm_prog	= 'swpct.sql'
def osm_title	= 'System Event Activity By PERCENT'

start osmtitle

col event	format a35	heading "Wait Event" trunc
col tw	 	format 99999990	heading "Time Waited|(min)"
col time_pct 	format 990.00	heading "% Time|Waited"
col wc	 	format 99999990	heading "Waits (k)"
col cnt_pct 	format 990.00	heading "% Waits"
col wait_class  format a17	heading "Wait Class"

select 	event,
	s.wait_class,
	(time_waited/100)/60 tw,
	100*(time_waited/&tot_time_waited) time_pct,
	total_waits/1000 wc,
	100*(total_waits/&tot_total_waits) cnt_pct
from   v$system_event s, v$event_name
where  event = name
  and  event like '&filter%'
  and  event not like 'SQL%'
  and  event not like 'KXFX%'
  and  event not like 'slave wait'
  and  event not like 'Wait for slaves%'
  and  event not like 'Parallel%Qu%Idle%Sla%'
  and  event not like 'refresh controfile%'
  and  event not in (
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
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client',
'wait for unread message on broadcast channel',
'Streams AQ: qmn coordinator idle wait',
'Streams AQ: waiting for messages in the queue',
'Streams AQ: qmn slave idle wait',
'Streams AQ: waiting for time management or cleanup tasks',
'jobq slave wait')
order by time_pct desc, cnt_pct desc, event asc
/

start osmclear

