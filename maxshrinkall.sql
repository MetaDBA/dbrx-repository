
column value new_val blksize
select value 
  from v$parameter 
 where name = 'db_block_size'
/

select 'alter database datafile ''' || 
 file_name || ''' resize ' ||
 ceil( (nvl(hwm,1)*&&blksize)/1024/1024 )
 || 'm;' cmd
from dba_data_files a,
     ( select file_id, 
         max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and 
 ceil(blocks*&&blksize/1024/1024)-
      ceil((nvl(hwm,1)*
      &&blksize)/1024/1024 ) > 0
/ 
