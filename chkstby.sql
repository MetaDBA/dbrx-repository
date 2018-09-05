select round((sysdate - completion_time)*24,1) hours_behind
from v$archived_log
where sequence# = (select min(STANDBY_LAST_LOG_NUMBER)
        from dbrx.dbrx_metric_1_data);
