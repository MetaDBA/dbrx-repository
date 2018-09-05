
select SID, SERIAL, FILENAME, EFFECTIVE_BYTES_PER_SECOND/1024/1024 as EBS_MB,
OPEN_TIME, CLOSE_TIME, ELAPSED_TIME, TOTAL_BYTES/1024/1024 as TOTAL_MB,
STATUS, MAXOPENFILES, buffer_size, buffer_count
from v$backup_sync_io
where close_time >= sysdate-20;

