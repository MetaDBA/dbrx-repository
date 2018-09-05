-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: sesssat.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 12-OCT-98
-- * Last Update	: 12-OCT-98
-- * Description	: Show v$sessstat details.
-- * Usage		: start sesstat.sql <sid> <name>
-- ********************************************************************

def sid=&1
def name=&2

col sid    format    9999  heading "SID"
col name   format     a50  heading "Name" trunc
col value  format   999,999,990  heading "Value"

def osm_prog="sesstat.sql"
def osm_title="V$SESSTAT Details For SID=&sid"

start osmtitle

select b.name,
       value
from   v$sesstat a,
       v$statname b
where  a.statistic# = b.statistic#
  and  a.sid = &sid
  and  b.name like '&name%'
/

start osmclear

