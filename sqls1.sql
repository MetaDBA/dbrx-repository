-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: sqls1.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 07-MAY-99
-- * Description	: Identify top SQL statements.
-- * Usage		: start sqls1.sql <min disk rds> <min buff rds>
-- * Thanks		  Thanks to Geert van Lierop for tip to use
-- *			  "address" instead of "hash_value".
-- ********************************************************************

def min_dr=&&1
def min_bg=&&2

def osm_prog    = 'sqls1.sql'
def osm_title   = 'Top SQL Statement Activity Summary'

col mod         heading 'Stmt Addr'            format          a16
col hv          heading 'Hash Value'            format  9999999999 print
col dr          heading 'Disk Rds'              format  999,999,999
col bg          heading 'Buff Gets'             format  9,999,999,999
col sr          heading 'Sorts'                 format       99,999
col exe         heading 'Runs'                  format    999,999,999
col loads       heading 'Body Loads'            format       99,999
col load        heading 'Load Factor'           format  999,999,999

start osmtitle

select  
  a.address                       mod,
  a.hash_value			  hv,
  a.disk_reads                    dr,
  a.buffer_gets                   bg,
  a.sorts                         sr,
  a.executions                    exe,
  a.loads                         loads,
  (a.disk_reads*100+a.buffer_gets)/1000   load
from    
  v$sqlarea a
where   
  a.disk_reads   > &min_dr and
  a.buffer_gets  > &min_bg
order by 
  a.disk_reads*100+a.buffer_gets desc       
/

undef min_dr
undef min_bg

start osmclear
