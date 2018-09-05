select file_id, segment_name, max(block_id) from dba_extents 
where tablespace_name = 'SYSTEM' 
and owner <> 'SYS'
group by file_id, segment_name
order by file_id, max(block_id)
/


