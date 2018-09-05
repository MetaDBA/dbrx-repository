-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename		: objloc.sql
-- * Author		: Craig A. Shallahamer
-- * Original		: 08-JUL-99
-- * Last Update	: 08-JUL-99
-- * Description	: Object location listing
-- * Usage		: start objloc  <owner> <partial object name>
-- * Example            : start objloc  gl  gl_bal
-- ********************************************************************

def own=&&1
def objname=&&2

def osm_prog	= 'objloc.sql'
def osm_title	= 'Object Location List (&own..&objname)'
start osmtitle

col own			format a10 heading 'Owner'
col segnam		format a23 heading 'Segment Name'
col fn			format a45 heading 'File Name'

break on own
break on segnam

select	owner		own,
	segment_name	segnam,
	file_name	fn
from	dba_extents	ext,
	dba_data_files	fil
where	ext.file_id	= fil.file_id
  and   owner 		like upper('&own%')
  and   segment_name	like upper('&objname%')
order by 1,2,3
/

start osmclear

