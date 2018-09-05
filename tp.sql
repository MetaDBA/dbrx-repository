-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: tp.sql
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-NOV-00
-- * Last Update	: 09-dec-00
-- * Description	: Top Oracle Processes
-- * Usage		: start tp.sql
-- ********************************************************************

set feedback off head on echo off

accept zsid	prompt "Enter a   session ID                    (sid) :"
accept zcpu	prompt "Enter the minimum session cpu time      (sec) :"
accept zpio	prompt "Enter the minimum session physical I/O  (gets):"
accept zlio	prompt "Enter the minimum session logical I/O   (gets):"
accept qpio	prompt "Enter the minimum SQL stmt physical I/O (gets):"
accept qlio	prompt "Enter the minimum SQL stmt logical I/O  (gets):"

def osm_prog	= 'tp.sql'
def osm_title	= 'Top Oracle Processes (by QPIO*10+QLIO desc)'
start osmtitle

set verify off feedback off head on echo off

col sidx	format       9999	heading 'SID'
col uname	format         a8	heading 'Oracle|User Name' trunc
col scpu	format       9990	heading 'SCPU|(sec)'
col pio		format       9999	heading 'SPIO|(k)'
col lio		format       9999	heading 'SLIO|(m)'
col rs		format       999999999	heading 'SRedo|(KB)'
col sa		format        a17	heading 'QSQL Address'
col dr		format       9999	heading 'QPIO|(k)'
col bg		format       9999 	heading 'QLIO|(m)'
col rowx	format       9999	heading 'QRows|(k)'
col load	noprint

select
  s.sid			sidx,
  s.username		uname,
  t2.value/100		scpu,
  sio.physical_reads/1000 			pio,
  (sio.block_gets+sio.consistent_gets)/1000/1000 	lio,
  t1.value/1024		rs,
  s.sql_address		sa,
  q.disk_reads/1000	dr,
  q.buffer_gets/1000/1000	bg,
  q.rows_processed/1000	rowx,
  q.disk_reads*10+q.buffer_gets load
from
  v$session s,
  v$sqlarea q,
  v$sesstat t1,
  v$sesstat t2,
  v$sess_io sio
where
  s.sql_address = q.address and
  s.sid         = t1.sid and
  s.sid         = t2.sid and
  t1.statistic# = 99 and  -- redo written by this session
  t2.statistic# = 12 and  -- CPU used by this session
  s.sid         = sio.sid and
  s.sid 	                        like '&zsid%' and
  t2.value                              >= nvl('&zcpu',0) and
  sio.physical_reads                    >= nvl('&zpio',0) and
  (sio.block_gets+sio.consistent_gets)  >= nvl('&zlio',0) and
  q.disk_reads                          >= nvl('&qpio',0) and
  q.buffer_gets                         >= nvl('&qlio',0)
order by
  load desc
/

start osmclear

