-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : bc.sql - Version 1.0
-- * Author             : Craig A. Shallahamer
-- * Original           : 04-MAY-99
-- * Last Update        : 04-MAY-99
-- * Description        : DB Block Buffer Cache Stats for O8+
-- *                      Note that if you immediately run the report
-- *                      it may look very different...
-- *			  There is a bc7 for Oracle7.
-- * Usage              : start bc.sql
-- ********************************************************************

def osm_prog    = 'bc.sql'
def osm_title   = 'Data Block Buffer Cache Stats'

start osmtitle

set echo off feedback off verify off

col total_db_buffers new_val blocks
select count(*) total_db_buffers
from   o$buffer_cache
/

ttitle off

prompt
prompt Grouped by db block buffer pool type,
prompt this report shows the number of objects in
prompt the block buffer cache grouped by object type.
prompt

clear break
clear col
break on pol skip 1
compute sum of cnt on pol 
compute sum of pct on pol

col pol		format a10	heading "Buffer|Pool"
col type	format a10	heading "Object|Type"
col cnt 	format 99,990	heading "# of|Objects"
col pct 	format 0.000	heading "PCT of|Objects"

select	pool pol,
	segment_type type,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache bc,
	dba_extents obj,
	o$buffer_pool p
where  	bc.buf_addr = p.buf_addr
  and   bc.file_no  = obj.file_id
  and   bc.block_no = obj.block_id
group by pool, segment_type
order by pool, segment_type
/

prompt
prompt Grouped by db block buffer pool type,
prompt this report shows the distribution of buffered
prompt blocks by their class.
prompt

col cnt 	format 99,990	heading "# of|Blocks"
col cls		format a20	heading "Block|Class"

select	pool pol,
	blk_class_text cls,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache,
	o$buffer_pool p
where   o$buffer_cache.buf_addr = p.buf_addr
group by pool, blk_class_text
order by 1,2 desc
/


prompt
prompt Grouped by db block buffer pool type,
prompt this report shows the distribution of buffered
prompt blocks by their state.
prompt

col status	format a40	heading "Block|State"

select	pool pol,
	blk_status_text status,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache,
	o$buffer_pool p
where   o$buffer_cache.buf_addr = p.buf_addr
group by pool, blk_status_text
order by 1,2 desc
/


prompt 
prompt Grouped by db block buffer pool type,
prompt this report shows the distribution of dirty
prompt blocks in the block buffer.
prompt 

col status	format a8	heading "Blocks|Dirty?"

break on pol skip 1

select	pool pol,
	blk_dirty status,
	count(*) cnt,
	count(*)/&blocks pct
from 	o$buffer_cache,
	o$buffer_pool p
where   o$buffer_cache.buf_addr = p.buf_addr
group by pool, blk_dirty
order by 1,2 desc
/

start osmclear


