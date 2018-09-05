-- ********************************************************************
-- * Copyright Notice   : (c)2000,2001 OraPub, Inc.
-- * Filename		: rbs
-- * Author		: Craig A. Shallahamer
-- * Original		: 24-SEP-98
-- * Last Update	: 01-mar-01
-- * Description	: Rollback segment statistics
-- * Usage		: start rbs
-- * Note: The percent extention (% Extn) is the percentage of an additional
-- * extent being allocated WHEN A TRX NEEDS TO MOVE INTO THE NEXT rbs extent.
-- * It is not related to EACH time a transaction writes, only when moving into
-- * the next extent.
-- ********************************************************************

def osm_prog	= 'rbs.sql'
def osm_title	= 'Rollback Segment Statistics'
start osmtitle

col segment    format           a12 heading 'Segment Name'  justify c trunc
col status     format           a8  heading 'Status'        justify c
col tablespace format           a18 heading 'Tablespace'    justify c trunc
col extents    format         9,990 heading 'Extents'       justify c
col bytes      format     9,999,990 heading 'Size|(KB)' justify c
col extn       format         990.0 heading '% Extn'
col wgratio    format         0.000 heading 'Wait/Get|Ratio'
col optsize    format       999,999 heading 'Optimal|(KB)'

select
  r.segment_name         segment,
  r.status               status,
  r.tablespace_name      tablespace,
  n.extents              extents,
  n.bytes/1024                bytes,
  100*(v.shrinks/(v.wraps+0.0001)) extn,
  waits/gets 		wgratio,
  optsize/1024          optsize
from
  dba_rollback_segs  r,
  dba_segments       n,
  v$rollname	     rn,
  v$rollstat         v
where
    r.segment_name = n.segment_name
and r.segment_name = rn.name
and rn.usn         = v.usn
order by 2,1,3
/

start osmclear

