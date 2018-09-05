-- ********************************************************************
-- * Copyright Notice   : (c)1999,2000,2001 OraPub, Inc.
-- * Filename		: fgidx.sql 
-- * Author		: Craig A. Shallahamer
-- * Original		: 15-nov-99
-- * Last Update	: 13-may-01
-- * Description	: Get INDEX fragmentation details for a given object.
-- * Usage		: start fgidx.sql <owner> <index name>
-- ********************************************************************

def owner=&&1
def inm=&&2

prompt The &owner..&inm index will be analyzed validate structure.
prompt Press ENTER to begin analyze and then produce report.
accept x

set echo on verify on heading on

set termout on
analyze index &owner..&inm validate structure;

set termout off
set echo on verify on heading on

col val0A new_val block_size
select value val0A
from   v$parameter
where  name = 'db_block_size';

col val1A new_val tnm
select table_name val1A
from   dba_ind_columns
where  index_owner = upper('&owner')
  and  index_name  = upper('&inm');

col val1AA new_val pct_free
select pct_free val1AA
from   dba_indexes
where  table_owner = upper('&owner')
  and  index_name  = upper('&inm');

col valAB new_val sf
select  count(*) valAB
from    dba_extents
where   segment_name= upper('&inm')
  and   owner       = upper('&owner');

set termout off
set verify on feedback on echo on

col val4A	new_val br_blks noprint
col val4B	new_val lf_blks noprint
col val4C	new_val used_blocks noprint
col val4D	new_val empty_blocks noprint
col val4E	new_val alloc_blocks noprint
col val4F	new_val alloc_bytes noprint
col val4G	new_val used_bytes noprint
col val4H	new_val br_blks_rows noprint
col val4I	new_val lf_blks_rows noprint
col val4J	new_val br_entry_size noprint
col val4K	new_val lf_entry_size noprint
col val4L	new_val no_rows noprint

select  br_blks				val4A,
	lf_blks				val4B,
	1+br_blks+lf_blks 		val4C,
	blocks-1-br_blks-lf_blks	val4D,
	blocks				val4E,
	blocks*&block_size		val4F,
	1+br_blks+lf_blks*&block_size 	val4G,
	(lf_rows-del_lf_rows)/br_blks	val4H,
	(lf_rows-del_lf_rows)/lf_blks	val4I,
	(&block_size*br_blks)/(lf_rows-del_lf_rows)	val4J,
	(&block_size*lf_blks)/(lf_rows-del_lf_rows)	val4K,
	lf_rows-del_lf_rows		val4L
from    index_stats;

col val5A new_value no_used_bytes
col val5B new_value pct_blocks_used 
select &alloc_bytes-&used_bytes		val5A,
       &used_blocks/&alloc_blocks	val5B
from   dual;

set echo off feedback off verify off
set termout on
set heading off

col c format a30			fold_after justify right
col x format 999,999,999,999		fold_after justify right

prompt
prompt INDEX Fragmentation Report
prompt

select 'Owner		   : '||'&owner' c,
       'Table name	   : '||'&tnm' c,
       'Index name	   : '||'&inm' c,
       'Block size         : '||&block_size x,
       'pct_free	   : '||&pct_free x,
       'Rows  	           : '||&no_rows x,
       'Number of extents  : '||&sf x,
       '-- Space Allocated  -------' c,
       'Blocks alloc	   : '||&alloc_blocks x,
       'Bytes alloc	   : '||&alloc_bytes x,
       '-- All Alloc Blocks -------' c,
       'Blocks alloc	   : '||&alloc_blocks x,
       'Blocks w/data	   : '||&used_blocks x,
       'Blocks wo/data	   : '||&empty_blocks x,
       'Percent used       : '||&pct_blocks_used x,
       'Bytes alloc	   : '||&alloc_bytes x,
       'Bytes used	   : '||&used_bytes x,
       'Bytes not used     : '||&no_used_bytes x,
       '-- All Used Blocks -------' c,
       'Used blocks	   : '||&used_blocks x,
       'Used bytes         : '||&used_bytes x,
       'Root blocks	   : 1' x,
       'Branch blocks 	   : '||&br_blks x,
       '  rows per bb      : '||&br_blks_rows x,
       '  entry size(bytes): '||&br_entry_size x,
       'Leaf blocks        : '||&lf_blks x,
       '  rows per lb      : '||&lf_blks_rows x,
       '  entry size(bytes): '||&lf_entry_size x
from   dual;

set feedback on


