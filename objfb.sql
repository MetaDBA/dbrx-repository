-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: objfb.sql- Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 09-oct-98
-- * Last Update	: 04-may-99
-- * Description	: Show object for a given file and block number.
-- * Usage		: start objfb.sql <file #> <blk#>
-- ********************************************************************

def file_id=&1
def block_id=&2

col a format a77 fold_after
def osm_prog	= 'objfb.sql'
def osm_title	= 'Object Details For A Given File #(&file_id) and block #(&block_id)'

start osmtitle

set heading off

select 'File number    :'||&file_id a,
       'Block number   :'||&block_id a,
       'Owner          :'||owner a,
       'Segment name   :'||segment_name a,
       'Segment type   :'||segment_type a,
       'Tablespace     :'||e.tablespace_name a,
       'File name      :'||file_name a
from   dba_extents e,
       dba_data_files f
where  e.file_id = f.file_id
  and  e.file_id = &file_id
  and  e.block_id <= &block_id
  and  e.block_id + e.blocks > &block_id
/

start osmclear
set heading on
