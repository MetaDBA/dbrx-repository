-------------------------------------------------------------------------------
--
-- Script:	hot_blocks.sql
-- Purpose:	to show the distribution of hot blocks to hash latches
-- For:		8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column child# format 99999
column segment_name format a40
break on child#

select /*+ ordered */
  l.child#,
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch  touches
from
  ( select
      avg(tch)  tch
    from
      sys.x_$bh
    where
      inst_id = userenv('Instance')
  )  a,
  sys.x_$bh  x,
  sys.v_$latch_children  l,
  sys.apt_extents  e
where
  x.inst_id = userenv('Instance') and
  x.tch > a.tch * a.tch and
  l.addr = x.hladdr  and
  e.file_id = x.file# and
  x.dbablk between e.block_id and e.block_id + e.blocks - 1 
order by
  1,
  5 desc
/

@restore_sqlplus_settings
