-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: sga - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 17-AUG-98
-- * Description	: Show very basic SGA information
-- * Usage		: start sga.sql
-- ********************************************************************

def osm_prog	= 'sga.sql'
def osm_title	= 'System Global Area Summary'
start osmtitle

comp sum of value on report 
break on report 

col name  format            a20 heading 'Component' justify c trunc
col value format 99,999,999,990 heading 'Size'      justify c trunc

select
  name,
  value
from
  v$sga
order by
  name,
  value
/

start osmclear

