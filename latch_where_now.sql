-------------------------------------------------------------------------------
--
-- Script:	latch_where_now.sql
-- Purpose:	shows a snapshot of latch sleeps by code locations
-- For:		8.0 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set recsep off
column name format a30 heading "LATCH TYPE"
column location format a40 heading "CODE LOCATION and [LABEL]"
column sleeps format 999999 heading "SLEEPS"

select /*+ ordered use_merge(b) */
  b.name,
  b.location,
  b.sleeps - a.sleeps  sleeps
from
  (
    select /*+ no_merge */
      wsc.ksllasnam  name,
      rpad(lw.ksllwnam, 40) ||
      decode(lw.ksllwlbl, null, null, '[' || lw.ksllwlbl || ']')  location,
      wsc.kslsleep  sleeps
    from
      sys.x_$kslwsc wsc,
      sys.x_$ksllw lw
    where
      wsc.inst_id = userenv('Instance') and
      lw.inst_id = userenv('Instance') and
      lw.indx = wsc.indx
  )  a,
  (
    select /*+ no_merge */
      wsc.ksllasnam  name,
      rpad(lw.ksllwnam, 40) ||
      decode(lw.ksllwlbl, null, null, '[' || lw.ksllwlbl || ']')  location,
      wsc.kslsleep  sleeps
    from
      ( select min(indx) zero from sys.x_$ksmmem where rownum < 1000000 ) delay,
      sys.x_$kslwsc wsc,
      sys.x_$ksllw lw
    where
      wsc.inst_id = userenv('Instance') and
      lw.inst_id = userenv('Instance') and
      wsc.kslsleep > delay.zero and
      lw.indx = wsc.indx
  )  b
where
  b.name = a.name and
  b.location = a.location and
  b.sleeps > a.sleeps
order by
  3 desc
/

@restore_sqlplus_settings
