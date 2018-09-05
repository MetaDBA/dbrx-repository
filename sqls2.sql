-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: sqls2 - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 07-MAY-99
-- * Description	: Show SQL statement text for a given hash value
-- * Thanks               Thanks to Geert van Lierop for tip to use
-- *                      "address" instead of "hash_value".
-- * Usage		: start sqls2.sql <stmt ident>
-- ********************************************************************

def addr=&&1

def osm_prog    = 'sqls2.sql'
def osm_title   = 'SQL Statement Text (Address=&addr)'

col hv		noprint
col ln		noprint
--col ln		heading 'Line'                  format        9,999
col text	heading 'SQL Statement Text'    format          A65

start osmtitle

select  t.address hv,
        t.piece ln,
        t.sql_text text
from    v$sqlarea a,
        v$sqltext t
where   a.address = t.address
  and   a.address = '&addr'
order by 1,2
/

undef sqls_id
start osmclear

