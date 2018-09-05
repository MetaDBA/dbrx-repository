-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swsessid - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 25-SEP-98
-- * Description	: Show real session waits since connection.
-- * Usage		: start swsessid.sql <sid>
-- ********************************************************************

def sid=&&1

col sid	   format    9999  heading "Sess|ID"
col event  format     a37  heading "Wait Event" trunc
col tws    format 9999999  heading "Total|Waits"
col tt     format  999999  heading "Total|Timouts"
col tw     format 99999999  heading "Time (hs)|Waited"
col avgw   format    9999  heading "Avg (hs)|Wait"

set verify off

def osm_prog="swsessid.sql"
def osm_title="Session Wait Session Event For SID &sid"
start osmtitle

select sid,
       event,
       total_waits tws,
       total_timeouts tt,
       time_waited tw,
       average_wait avgw
from   v$session_event
where  sid = &&sid
  union
select sid,
       'CPU time',
       to_number(null) tws,
       to_number(null) tt,
       value tw,
       to_number(null) avgw
from v$sesstat c, v$statname nc
where nc.statistic# = c.statistic#
and nc.name = 'CPU used by this session'
and sid = &&sid
order by tw desc,event;

undef sid
start osmclear

