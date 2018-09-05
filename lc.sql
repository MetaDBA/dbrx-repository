-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: lc - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 24-AUG-98
-- * Description	: Show library cache information.
-- * Usage		: start lc.sql
-- ********************************************************************

def osm_prog	= 'lc.sql'
def osm_title	= 'Shared Pool Library Cache Information'

set echo off feedback off heading off termout off

col a           format                  a70 fold_after 1
col sp_size	format		999,999,999 justify right fold_after 1
col x_sp_used	format		999,999,999 justify right fold_after 1
col sp_used_shr	format		999,999,999 justify right fold_after 1
col sp_used	format		999,999,999 justify right fold_after 1
col sp_used_per	format		999,999,999 justify right fold_after 1
col sp_used_run	format		999,999,999 justify right fold_after 1
col sp_avail	format		999,999,999 justify right fold_after 1
col sp_sz_pins 	format		999,999,999 justify right fold_after 1
col sp_no_pins 	format		    999,999 justify right fold_after 1
col sp_no_obj 	format		    999,999 justify right fold_after 1
col sp_no_stmts format		    999,999 justify right fold_after 1
col sp_sz_kept_chks format      999,999,999 justify right fold_after 1
col sp_no_kept_chks format          999,999 justify right fold_after 1

col val2 new_val x_sp_size noprint
select value val2
from   v$parameter
where  name='shared_pool_size'
/
col val2 new_val x_sp_used noprint
select sum(sharable_mem+persistent_mem+runtime_mem) val2
from   v$sqlarea
/
col val2 new_val x_sp_used_shr noprint
col val3 new_val x_sp_used_per noprint
col val4 new_val x_sp_used_run noprint
col val5 new_val x_sp_no_stmts noprint
select sum(sharable_mem) val2,
       sum(persistent_mem) val3,
       sum(runtime_mem) val4,
       count(*) val5
from   v$sqlarea
/
col val2 new_val x_sp_no_obj noprint
select count(*) val2
from v$db_object_cache 
/
col val2 new_val x_sp_avail noprint
select &x_sp_size-&x_sp_used val2
from   dual
/
col val2 new_val x_sp_no_kept_chks noprint
col val3 new_val x_sp_sz_kept_chks noprint
select decode(count(*),'',0,count(*)) val2,
       decode(sum(sharable_mem),'',0,sum(sharable_mem)) val3
from   v$db_object_cache
where  kept='YES'
/
col val2 new_val x_sp_no_pins noprint
select count(*) val2
from v$session a, v$sqltext b
where a.sql_address||a.sql_hash_value = b.address||b.hash_value
/
col val2 new_val x_sp_sz_pins noprint
select sum(sharable_mem+persistent_mem+runtime_mem) val2
from   v$session a,
       v$sqltext b,
       v$sqlarea c
where  a.sql_address||a.sql_hash_value = b.address||b.hash_value and
       b.address||b.hash_value = c.address||c.hash_value
/

set termout on
start osmtitle
set heading off feedback off echo off

select  'Library Cache Memory Contents Summary' a,
        'Size (bytes)                          : '
		||&x_sp_size sp_size,
        'Available (bytes)                     : '
		||&x_sp_avail sp_avail,
        'Used (total in bytes)                 : '
		||&x_sp_used sp_used,
        '     sharable                         : '
		||&x_sp_used_shr sp_used_shr,
        '     persistent                       : '
		||&x_sp_used_per sp_used_per,
        '     runtime                          : '
		||&x_sp_used_run sp_used_run ,
        'Number of SQL statements              : '
		||&x_sp_no_stmts sp_no_stmts ,
        'Number of programatic constructs      : '
		||&x_sp_no_obj sp_no_obj ,
        'Kept programatic construct chunks     : '
		||&x_sp_no_kept_chks sp_no_kept_chks ,
        'Kept programatic construct chunks size: '
		||&x_sp_sz_kept_chks sp_sz_kept_chks ,
        'Pinned statements                     : '
		||&x_sp_no_pins sp_no_pins ,
        'Pinned statements size                : '
		||&x_sp_sz_pins sp_sz_pins 
from	dual
/

start osmclear

