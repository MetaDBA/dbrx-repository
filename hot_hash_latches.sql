-------------------------------------------------------------------------------
--
-- Script:	hot_cache_hash_latches.sql
-- Purpose:	to find the hot cache hash latches
-- For:		8.0 and 8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select
  l.child#,
  l.sleeps,
  sum(decode(x.state, 1, 1, 0))  cur_buffers,
  sum(decode(x.state, 3, 1, 0))  cr_buffers
from
  sys.v_$latch_children  l,
  ( select
      avg(sleeps)  sleeps
    from
      sys.v_$latch_children
    where
      name = 'cache buffers chains'
  )  a,
  sys.x_$bh  x
where
  l.name = 'cache buffers chains' and
  l.sleeps > 2 * a.sleeps and
  x.hladdr = l.addr and
  x.inst_id = userenv('Instance')
group by
  l.child#,
  l.sleeps
order by
  2 desc
/

@restore_sqlplus_settings
