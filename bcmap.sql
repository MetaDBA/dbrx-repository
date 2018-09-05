-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename		: bcmap.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 04-MAY-99
-- * Last Update	: 04-MAY-99
-- * Description	: Buffer cache block mapping summary
-- * Usage		: start bcmap.sql <class> <pool>
-- ********************************************************************

def inclass	= &&1
def inpool	= &&2

def osm_prog	= 'bcmap.sql'
def osm_title	= 'Buffer Cache Block Map (class:&inclass%, pool:&inpool%)'

start osmtitle

col pl		format        a8 heading 'Pool'
col bfid	format      9990 heading 'Buf #'
col fid    	format       990 heading 'File'
col bid   	format 9,999,990 heading 'Block Id'
col bclass	format       a16 heading 'Blk|Class' trunc
col bstatus	format       a22 heading 'Blk Status' trunc
col bdirty	format        a4 heading 'Blk|Drty'
col iot		format        a4 heading 'IO|Type'

break on pl skip 1

select	pool		pl,
	file_no		fid,
	block_no	bid,
	blk_class_text	bclass,
	blk_status_text	bstatus,
	blk_dirty	bdirty,
	io_type		iot,
	buf_no		bfid
from	o$buffer_cache bc,
	o$buffer_pool  bp
where   bp.pool like upper('&inpool%')
  and	bc.blk_class like upper('&inclass%')
  and   bp.buf_addr = bc.buf_addr
  and	bc.file_no > 0
order by 1,2,3
/

undef inpool
undef inclass
start osmclear

