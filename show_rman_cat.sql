alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS';
set linesize 140 pagesize 40
col handle format a30
col media format a20
-- select distinct db_id from rc_backup_piece where handle like '%ODMDEV%';
select distinct media,handle,tag,start_time,completion_time,BACKUP_TYPE
from rc_backup_piece
 where db_id = 2419785199 and start_time > (sysdate -10)
order by completion_time;

