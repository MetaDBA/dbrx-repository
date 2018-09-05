set pagesize 1000
col mb for 9,999,999,999
select to_char(h.completion_time,'YYYY-MM-DD HH24') day_hour,
       sum(h.blocks*h.block_size)/1024/1024 MB
from gv$archived_log h
where dest_id = 1
group by  to_char(h.completion_time,'YYYY-MM-DD HH24')
 order by 1;
