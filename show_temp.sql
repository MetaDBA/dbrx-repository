
set linesize 100 pagesize 100
col username for a10 trunc
col tablespace for a10 trunc
col file_name for a40 trunc
break on report on inst_id skip 1
compute sum of extents on report
compute sum of blocks on report
compute sum of mb on report
col mb for 9,999,999
SELECT s.inst_id,s.username, s.sid,  u.TABLESPACE, u.CONTENTS, u.extents, u.blocks,(u.blocks * 8192)/1024/1024 mb
  FROM gv$session s, gv$sort_usage u
WHERE s.saddr = u.session_addr and u.inst_id = s.inst_id
      order by s.inst_id;

SELECT   a.inst_id,A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     gv$sort_segment A,
         (
         SELECT   b.inst_id,B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     gv$tablespace B, gv$tempfile C
         WHERE    B.ts#= C.ts# and b.inst_id = c.inst_id
         GROUP BY b.inst_id,B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name and a.inst_id = d.inst_id
GROUP by a.inst_id,A.tablespace_name, D.mb_total;

select tablespace_name,file_name,status,  bytes/1048576 mb from dba_temp_files order by 1,2;
