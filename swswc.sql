-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swswc.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 19-nov-98
-- * Last Update	: 19-nov-98
-- * Description	: Show Session Wait Summary/Count
-- * Usage		: start swswc.sql
-- ********************************************************************

def osm_prog="swswc.sql"
def osm_title="Session Wait Real Time w/Counts"
start osmtitle

col event  format     a40  heading "Wait Event" wrap
col siw    format    999,999,999,990  heading "Waited So Far (sec)"
col xcnt   format    99,990  heading "Num. Sess.|Waiting"

select event,
       sum(seconds_in_wait) siw,
       count(event) xcnt
from   v$session_wait
where  state = 'WAITING'
group by event
order by 3 desc,2 desc,1
/

start osmclear

