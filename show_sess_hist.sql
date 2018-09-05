
set feedback off
set markup html on
spool ash_sqlstats.html
select sql_id, plan_hash_value, disk_reads,direct_writes, buffer_gets, executions, loads, cpu_time, elapsed_time, avg_hard_parse_time, user_io_wait_time,phys
ical_read_requests phys_reads, physical_write_requests phys_writes from V$SQLSTATS where sql_id in(
select sql_id from (
select sql_id, max(timewait) from (SELECT  sql_id, event,
        count(*),
        sum(TIME_WAITED) timewait
--from    v$ACTIVE_SESSION_HISTORY A
from DBA_HIST_ACTIVE_SESS_HISTORY A
GROUP BY sql_id,event
having sum(time_waited) > 0
and count(*) > 100) T1
group by sql_id) T2);


