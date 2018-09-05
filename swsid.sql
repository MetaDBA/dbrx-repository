-- ********************************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename		: swsid 
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 18-jan-01
-- * Description	: Show real time session wait for a given sess.
-- * Usage		: start swsid.sql <sid>
-- ********************************************************************

set verify off

def sid=&1

col event  format     a35  heading "Wait Event" trunc
col state  format     a15  heading "Wait State" trunc
col siw    format  999999  heading "Waited So|Far (secs)"
col wt     format 9999999  heading "Time Waited|(secs)"

def osm_prog="swsid.sql"
def osm_title="Real Time Session Wait For SID=&sid"
start osmtitle

select event,
       state,
       seconds_in_wait siw,
       wait_time wt,
       seq#
from   v$session_wait
where  sid = &sid
order by event;

undef sid
start osmclear

