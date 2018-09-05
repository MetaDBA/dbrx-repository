select sql_id, count(*), 
count(*)*100/sum(count(*)) over() pctload
from v$active_session_history
where sample_time > sysdate - 1/24
group by sql_id
order by count(*) desc;
