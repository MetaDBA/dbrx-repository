set linesize 140 pagesize 900
col tablespace_name for a30 trunc
col segment_name for a30 trunc
col bytes for 9,999,999,999,999
col blocks for 9,999,999,999,999

select tablespace_name,file_id,block_id,bytes,blocks,relative_fno 
      from dba_free_space
     where tablespace_name = '&T'
       and bytes <= ( select min(next_extent)
                from dba_segments
               where tablespace_name = '&T')
     order by block_id;

 
select segment_name, extent_id, bytes/1024/1024 mb from dba_extents where segment_name in
    (
    select segment_name from dba_segments where tablespace_name = '&T'
    )
   order by 1,2;
