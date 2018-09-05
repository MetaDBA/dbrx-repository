-------------------------------------------------------------------------------
--
-- Script:	blocks_on_hot_latches.sql
-- Purpose:	to find potentially hot blocks in cache
-- For:		8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column segment_name format a40

select /*+ ordered */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch  touches,
  decode(x.lru_flag,
    0, 'MID',
    2, 'LRU',
    4, 'AUX',
    8, 'HOT',
    '???'
  )  lru
from
  sys.v_$latch_children  l,
  ( select
      avg(sleeps)  sleeps
    from
      sys.v_$latch_children
    where
      name = 'cache buffers chains'
  )  a,
  sys.x_$bh  x,
  sys.apt_extents  e
where
  l.name = 'cache buffers chains' and
  l.sleeps > 2 * a.sleeps and
  x.hladdr = l.addr and
  x.inst_id = userenv('Instance') and
  e.file_id = x.file# and
  x.dbablk between e.block_id and e.block_id + e.blocks - 1
/

@restore_sqlplus_settings
