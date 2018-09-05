set linesize 120 pagesize 130
col owner for a10 trunc
col segment_type for a10 trunc
col segment_name for a35 trunc
col partition_name for a20 trunc

SELECT e.owner, e.segment_type, e.segment_name, e.partition_name
  FROM dba_extents e, v$database_block_corruption c
 WHERE e.file_id = c.FILE#
   AND e.block_id <= c.BLOCK# + c.blocks - 1
   AND e.block_id + e.blocks - 1 >= c.BLOCK#
UNION
SELECT s.owner, s.segment_type, s.segment_name, s.partition_name
  FROM dba_segments s, v$database_block_corruption c
 WHERE s.header_file = c.FILE#
   AND s.header_block BETWEEN c.BLOCK# AND c.BLOCK# + c.blocks - 1
ORDER BY SEGMENT_TYPE,  OWNER, SEGMENT_NAME;
