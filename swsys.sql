-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swsys - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 25-SEP-98
-- * Description	: Show system event session wait information
-- * Usage		: start swsys.sql
-- ********************************************************************

col event  format        a37  heading "Wait Event" trunc
col tws    format   99999999  heading "Total|Waits"
col tt     format   99999999  heading "Total|Timouts"
col tw     format    99999.0  heading "Time(sec)|Waited"
col avgw   format   9990.000  heading "Avg (sec)|Wait"

def osm_prog="swsys.sql"
def osm_title="System Event Session Information"
start osmtitle

select event,
       total_waits tws,
       total_timeouts tt,
       time_waited/100 tw,
       average_wait/100 avgw
from   v$system_event
order by time_waited desc;

start osmclear

