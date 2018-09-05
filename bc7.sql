-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename		: bc7.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 04-MAY-99
-- * Last Update	: 04-MAY-99
-- * Description	: DB Block Buffer Cache Stats for O7.
-- *			  Note that if you immediately run the report
-- *			  it may look very different...
-- * Usage		: start bc7.sql
-- ********************************************************************

def osm_prog	= 'bc7.sql'
def osm_title	= 'Data Block Buffer Cache Stats For Oracle7'

start osmtitle

set echo off feedback off verify off

col total_db_buffers new_val blocks
select count(*) total_db_buffers
from   o$buffer_cache
/

ttitle off

prompt
prompt This report shows the number of objects in
prompt the block buffer cache grouped by object type.
prompt

col type	format a10	heading "Object|Type"
col cnt 	format 99,990	heading "# of|Objects"
col pct 	format 0.000	heading "PCT of|Objects"

break on report
compute sum of cnt on report
compute sum of pct on report

select	object_type type,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache bc,
	dba_objects obj
where   bc.obj_no = obj.object_id
group by object_type
order by object_type
/

prompt
prompt This report shows the distribution of buffered
prompt blocks by their class.
prompt

col cls		format    a30	heading "Block|Class"
col cnt 	format 99,990	heading "# of|Blocks"

select	blk_class_text cls,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache
group by blk_class
order by 2 desc
/


prompt 
prompt This report shows the distribution of buffered
prompt blocks by their state.
prompt 

col status	format a40	heading "Block|State"

select	blk_status_text status,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache
group by blk_status_text
order by 2 desc
/

prompt 
prompt This report shows the distribution of dirty
prompt blocks in the block buffer.
prompt 

col status	format a8	heading "Blocks|Dirty?"

select	blk_dirty status,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache
group by blk_dirty
order by 2 desc
/

start osmclear

