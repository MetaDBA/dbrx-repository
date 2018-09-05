-- ********************************************************************
-- * Copyright Notice   : (c)1999,2000,2001 OraPub, Inc.
-- * Filename		: fgtbl.sql 
-- * Author		: Craig A. Shallahamer
-- * Original		: 10-nov-99
-- * Last Update	: 21-mar-01
-- * Description	: Get TABLE fragmentation details for a given object.
-- * Usage		: start fgtbl.sql <owner> <table name>
-- ********************************************************************

def owner=&&1
def tnm=&&2

set echo off verify off heading off
set termout off

col val4 new_val hwm_blocks noprint
col val5 new_val above_hwm noprint
col val6 new_val row_chains noprint
col val7 new_val row_size noprint
col val7a new_val pct_used noprint
col val7b new_val pct_free noprint
col val8 new_val num_rows noprint
col val9 new_val row_chains_pct noprint

select  num_rows 	val8,
        blocks		val4,
	empty_blocks	val5,
	chain_cnt	val6,
	avg_row_len	val7,
	pct_used	val7a,
	pct_free	val7b,
        100*chain_cnt/num_rows val9
from    dba_tables
where   table_name = upper('&tnm')
  and   owner      = upper('&owner');

col val9 new_val block_size noprint
select value val9
from   v$parameter
where  name = 'db_block_size';

col val10a new_val blocks_alloc noprint
col val10b new_val bytes_alloc noprint
col val10e new_val hwm_bytes noprint
col val10f new_val bytes_used noprint
select &hwm_blocks+&above_hwm val10a,
       (&hwm_blocks+&above_hwm)*&block_size/1024/1024 val10b,
       (&hwm_blocks*&block_size)/1024/1024 val10e,
       (&num_rows*&row_size)/1024/1024 val10f
from   dual;

col val11a new_val blocks_pct_used noprint
col val11b new_val bytes_pct_used noprint
select 100*&hwm_blocks/&blocks_alloc val11a,
       100*&num_rows*&row_size/&hwm_bytes/1024/1024 val11b
from   dual;

col val12 new_val sf noprint
select  count(*) val12
from    dba_extents
where   segment_name= upper('&tnm')
  and   owner       = upper('&owner');

set termout on
set echo off feedback off verify off

col bogus 	  format 999,999,999         fold_after

select 'Owner		   : '||'&owner' bogus,
       'Table name	   : '||'&tnm' bogus,
       'pct_free	   : '||&pct_free bogus,
       'pct_used	   : '||&pct_used bogus,
       'Number of extents  : '||&sf||' <-- Segment Fragmentation' bogus,
       'Rows		   : '||&num_rows bogus,
       'Row size           : '||&row_size bogus,
       'Rows frag:migration: '||&row_chains bogus,
       'Row % frag:migr.   : '||&row_chains_pct||'% <-- Row Fragmentation' bogus,
       'DB block size      : '||&block_size bogus,
       'Blocks alloc	   : '||&blocks_alloc bogus,
       'Block HWM          : '||&hwm_blocks bogus,
       '% alloc used by HWM: '||&blocks_pct_used||'%' bogus,
       'MB alloc           : '||&bytes_alloc||'MB' bogus,
       'MB HWM             : '||&hwm_bytes||'MB' bogus,
       'MB used	           : '||&bytes_used||'MB' bogus,
       '% HWM bytes used   : '||&bytes_pct_used||'% <-- Block Fragmentation' bogus
from   dual;

prompt *** The table &owner..&tnm must have been recently analyzed for accuracy
prompt *** You may need to ANALYZE TABLE &owner..&tnm DELETE STATISTICS

set feedback on


