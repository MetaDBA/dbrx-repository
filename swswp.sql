-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: swswp.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 25-SEP-98
-- * Last Update	: 05-nov-98
-- * Description	: Show Session Wait Realtime w/Parameters
-- * Usage		: start swswp.sql
-- ********************************************************************

def input=&1

def osm_prog="swswp.sql"
def osm_title="Session Wait Real Time w/Parameters"
start osmtitle

col sid	   format     9999  heading "Sess|ID"
col event  format     a27  heading "Wait Event" wrap
col state  format      a4  heading "Wait|State"
col siw    format    9999  heading "W'd So|Far|(secs)"
col wt     format    9999  heading "Time|W'd|(secs)"
col p1     format    99999999999  heading "P1"
col p2     format    99999999999  heading "P2"
col p3     format         9999  heading "P3"
col p1raw     format    99999999999  heading "P1Raw"
col p2raw     format    99999999999  heading "P2Raw"

select sid, event,
       decode(state,'WAITING','WG','WAITING UNKNOWN','W UN',
                    'WAITED KNOWN TIME','W KN','WAITED SHORT TIME','W SH',
                    'WAITED','WD','*') state,
       seconds_in_wait siw,
       wait_time wt,
       p1, p2, p3, p1raw, p2raw
from   v$session_wait
where  event like '&input%'
order by event,sid,p1,p2;

start osmclear

