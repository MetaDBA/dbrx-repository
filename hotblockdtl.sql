column segment_name format a35
     select /*+ RULE */
       e.owner ||'.'|| e.segment_name  segment_name,
       e.file_id file#,
       e.block_id df_block#,
       e.extent_id  extent#,
       x.dbablk - e.block_id + 1  block#,
       x.tch,
       l.child#
     from
       sys.v$latch_children  l,
       sys.x$bh  x,
       sys.dba_extents  e
     where
       x.hladdr  = '&ADDR' and
       e.file_id = x.file# and
       x.hladdr = l.addr and
       x.dbablk between e.block_id and e.block_id + e.blocks -1
     order by x.tch desc ;

