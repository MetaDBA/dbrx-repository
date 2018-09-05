-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swsw.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 25-SEP-98
-- * Description	: Show real time session wait details.
-- * Usage		: start swsw.sql
-- ********************************************************************

col sid    format    9999  heading "SID"
col event  format     a35  heading "Wait Event" trunc
col state  format     a15  heading "Wait State" trunc
col siw    format   99999  heading "Waited So|Far (sec)"
col wt     format 9999999  heading "Time Waited|(sec)"

def osm_prog="swsw.sql"
def osm_title="Real Time Session Wait Details"

start osmtitle

select sid,
       event,
       state,
       seconds_in_wait siw,
       wait_time wt
from   v$session_wait
order by event, sid;

start osmclear

