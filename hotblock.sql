select /*+ ordered */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch,
  l.child#
from
  sys.v$latch_children  l,
  sys.x$bh  x,
  sys.dba_extents  e
where
  l.name    = 'cache buffers chains' and
  l.sleeps  > &sleep_count and
  x.hladdr  = l.addr and
  e.file_id = x.file# and
  x.dbablk between e.block_id and e.block_id + e.blocks - 1;


