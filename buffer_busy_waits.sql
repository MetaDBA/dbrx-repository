-------------------------------------------------------------------------------
--
-- Script:	buffer_busy_waits.sql
-- Purpose:	to report the block classes and tablespace affect by bbwaits
-- For:		8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column block_class format a30
column buffer_pool format a30

select
  w.class  block_class,
  w.count  total_waits,
  w.time  time_waited
from
  sys.v_$waitstat  w
where
  w.count > 0
order by 3 desc
/
select
  d.tablespace_name,
  sum(x.count)  total_waits,
  sum(x.time)  time_waited
from
  sys.x_$kcbfwait  x,
  sys.dba_data_files  d
where
  x.inst_id = userenv('Instance') and
  x.count > 0 and
  d.file_id = x.indx + 1
group by
  d.tablespace_name
order by 3 desc
/
select
  p.bp_name  buffer_pool,
  sum(s.bbwait)  total_waits
from
  sys.x_$kcbwds s,
  sys.x_$kcbwbpd p
where
  s.inst_id = userenv('Instance') and
  p.inst_id = userenv('Instance') and
  s.set_id >= p.bp_lo_sid and
  s.set_id <= p.bp_hi_sid and
  p.bp_size != 0
group by
  p.bp_name
having
  sum(s.bbwait) > 0
/

@restore_sqlplus_settings
