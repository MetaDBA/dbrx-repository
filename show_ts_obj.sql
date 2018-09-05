set linesize 140 pagesize 300
col tablespace_name for a30 trunc
col owner for a10 trunc
col object_name for a30 trunc
col object_type for a20 trunc
select distinct s.tablespace_name,
       o.owner,
       o.object_name,
       o.object_type,
       max(o.last_ddl_Time) max_ddl,
       max(o.created) created
from  dba_objects o,
      dba_segments s
where o.owner = s.owner and
      o.object_name = s.segment_name and
      o.object_type = s.segment_type and
      s.tablespace_name = upper('&ts_name')
group by s.tablespace_name,
       o.owner,
       o.object_name,
       o.object_type,
order by last_ddl_time;

