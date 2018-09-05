-------------------------------------------------------------------------------
--
-- Script:	ideal_cache_size.sql
-- Purpose:	to suggest an ideal number of buffers for each buffer pool
-- For:		8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Description:	This script assumes that the ideal number of buffers in each
--		pool is the current number, plus the number of buffers due to
--		be heated, less free buffers and hot buffers due to be cooled.
--
--		Of course, the ideal will fluctuate from moment to moment.
--		So the script should be run several times under distinct
--		workload peaks before drawing any firm conclusions.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select /*+ ordered use_hash(b) */
  n.bp_name  buffer_pool,
  count(*)  current_buffers,
  count(*) +
  count(decode(lru_flag, 0, decode(tch, 0, null, 1, null, 1))) -
  count(decode(state, 0, 1, decode(lru_flag, 8, decode(tch, 0, 1, 1, 1))))
    ideal_buffers
from
  (
    select /*+ ordered */
      p.bp_name,
      s.addr
    from
      sys.x_$kcbwbpd  p,
      sys.x_$kcbwds  s
    where
      s.inst_id = userenv('Instance') and
      p.inst_id = userenv('Instance') and
      s.set_id >= p.bp_lo_sid and
      s.set_id <= p.bp_hi_sid and
      p.bp_size != 0
  )  n,
  sys.x_$bh b
where
  b.inst_id = userenv('Instance') and
  b.set_ds = n.addr
group by
  n.bp_name
/

@restore_sqlplus_settings
-------------------------------------------------------------------------------
--
-- To do:	If KEEP or RECYCLE have no hot region, suggest that instead.
--
-------------------------------------------------------------------------------
