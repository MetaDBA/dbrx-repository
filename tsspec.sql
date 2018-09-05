-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: tsmap.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 24-SEP-98
-- * Description	: Tablespace block mapping summary
-- * Usage		: start tsmap.sql <tablespace name>
-- ********************************************************************

rem def ts		= &&1

def osm_prog	= 'tsmap.sql &ts'
def osm_title	= 'Tablespace Block Map'

start osmtitle

col tablespace format       a15 justify c trunc heading 'Tablespace'
col file_id    format       990 justify c       heading 'File'
col block_id   format 9,999,990 justify c       heading 'Block Id'
col blocks     format   999,990 justify c       heading 'Size'
col segment    format       a38 justify c trunc heading 'Segment'

break on tablespace skip page

select
  tablespace_name	       tablespace,
  file_id,
  block_id,
  blocks,
  owner||'.'||segment_name     segment
from
  dba_extents 
where
  tablespace_name = upper('INDEX_40M') 
   and file_id in (23,26,28)
   and block_id > 200000
 union
select
  tablespace_name	       tablespace,
  file_id,
  block_id,
  blocks,
  '<free>'
from
  dba_free_space
where
  tablespace_name = upper('INDEX_40M')
   and file_id in (23,26,28)
   and block_id > 200000
order by
  1,2,3
/

undef ts
start osmclear

