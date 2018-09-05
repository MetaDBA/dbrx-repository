REM This version is just for one tablespace.

def ts          = &&1

column value new_val blksize
select value 
  from v$parameter 
 where name = 'db_block_size'
/

select 'alter database datafile ''' || 
 file_name || ''' resize ' ||
 greatest (ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ), 11)
 || 'm;' cmd
from dba_data_files a,
     ( select file_id, 
         max(block_id+blocks-1) hwm
         from dba_extents
  	where tablespace_name = upper('&&ts')
        group by file_id ) b
where a.file_id = b.file_id(+)
  and a.tablespace_name = upper('&&ts')
  and 
 ceil(blocks*&&blksize/1024/1024)-
      ceil((nvl(hwm,1)*
      &&blksize)/1024/1024 ) > 0 
/ 
