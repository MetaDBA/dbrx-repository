SELECT segment_name, segment_type, owner, tablespace_name, block_id, blocks
FROM sys.dba_extents
WHERE file_id = 2108
AND 117129  BETWEEN block_id and block_id + blocks -1;

