-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: stu.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 24-SEP-98
-- * Description	: Segment type per Tablespace per User
-- * Usage		: start stu.sql
-- ********************************************************************

def osm_prog	= 'stu.sql'
def osm_title	= 'Space Usage per Segment Type per Tablespace per User'
start osmtitle

col username        format            a25 justify c heading 'Username'
col tablespace_name format            a25 justify c heading 'Tablespace Name'
col segment_type    format            a17 justify c heading 'Segment Type'
col mbytes          format      99,990.99 justify c heading 'MB Used'

break on username skip 1

select
  owner                  username,
  segment_type           segment_type,
  sum(bytes)/1048576     mbytes,
  tablespace_name        tablespace_name
from
  dba_segments
group by
  owner,
  tablespace_name,
  segment_type
order by
  1,2,3
/

start osmclear

