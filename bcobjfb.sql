-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename		: bcobjfb.sql- Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 04-may-99
-- * Last Update	: 04-may-99
-- * Description	: Show object for a given file and block number.
-- *			  The block must be currently in cache. 
-- * Usage		: start bcobjfb.sql <file #> <blk#>
-- ********************************************************************

def file_id=&1
def block_id=&2

col a format a77 fold_after
def osm_prog	= 'bcobjfb.sql'
def osm_title	= 'BC Object Details For A Given File #(&file_id) and block #(&block_id)'

start osmtitle

set heading off

select 'File number    :'||&file_id a,
       'Block number   :'||&block_id a,
       'Owner          :'||owner a,
       'Segment name   :'||segment_name a,
       'Segment type   :'||segment_type a,
       'Tablespace     :'||e.tablespace_name a,
       'File name      :'||file_name a,
       'Object number  :'||bc.obj_no a,
       'Block class    :'||bc.blk_class_text a,
       'Block status   :'||bc.blk_status_text a,
       'Block dirty?   :'||bc.blk_dirty a,
       'Block I/O type :'||bc.io_type a,
       'Block temp?    :'||bc.blk_temp a,
       'Block stale?   :'||bc.blk_stale a,
       'Block direct?  :'||bc.blk_direct_addr a
from   dba_extents e,
       dba_data_files f,
       o$buffer_cache bc
where  e.file_id = f.file_id
  and  f.file_id = bc.file_no
  and  bc.file_no= &file_id
  and  bc.block_no = &block_id
  and  e.block_id <= &block_id
  and  e.block_id + e.blocks > &block_id
/

start osmclear
