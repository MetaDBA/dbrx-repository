-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: sqls3 
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 12-SEP-03 by Terry Sutton
-- * Description	: Show SQL statement text for a given hash value
-- * Usage		: start sqls3.sql <hash value>
-- ********************************************************************

def sqlid=&&1

def osm_prog    = 'sqls3s.sql'
def osm_title   = 'SQL Statement Text (sql_id=&sqlid)'

col hv		noprint
col ln		noprint
--col ln		heading 'Line'                  format        9,999
col text	heading 'SQL Statement Text'    format          A65

start osmtitle

select  t.sql_id     hv,
        t.piece ln,
        t.sql_text text
from    v$sqlarea a,
        v$sqltext t
where   a.sql_id = t.sql_id
  and   a.sql_id = '&sqlid'
order by 1,2
/

undef sqlid
start osmclear

