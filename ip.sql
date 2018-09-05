-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: ip - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 24-AUG-98
-- * Description	: Instance parameter report
-- * Usage		: start ip.sql
-- ********************************************************************

def p_name=&1

def osm_prog	= 'ip.sql'
def osm_title	= 'Instance Parameters'
start osmtitle

col name  format a40 heading 'Instance Parameter' justify l wrap
col value format a36 heading 'Value'              justify l trunc

select
  name,
  value
from
  v$parameter
where name like '&p_name%'
order by
  name,
  value
/

start osmclear

