set linesize 140 pagesize 40
col min_time for a15 trunc
col max_time for a15 trunc
col time_diff for a15 trunc
SELECT INSTANCE_NUMBER,
    SESSION_ID,
   SESSION_SERIAL#,
   SQL_PLAN_HASH_VALUE,
   MIN(SAMPLE_TIME) min_time,
   MAX(SAMPLE_TIME) max_time,
 MAX(SAMPLE_TIME) - MIN(SAMPLE_TIME)   time_diff
FROM DBA_HIST_ACTIVE_SESS_HISTORY
  WHERE SQL_ID = '&sql_id'
   GROUP BY INSTANCE_NUMBER,
             SESSION_ID,
             SESSION_SERIAL#,
            SQL_PLAN_HASH_VALUE
  ORDER BY 5;

