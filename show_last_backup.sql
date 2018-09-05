alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS';
set linesize 140 pagesize 40
col handle format a30
col media format a20
select distinct media,handle,tag,start_time,completion_time,BACKUP_TYPE
from rc_backup_piece
   where  start_time > (sysdate -5) and backup_type in ('D','L')
order by completion_time;

