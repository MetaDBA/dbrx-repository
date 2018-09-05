REM
REM standby_metric.sql
REM ==================
REM
REM This script creates a table and stored procedure that customize the
REM Database Rx agent implementation. These objects, together with a script
REM that runs on the standby server, implement a customer-defined metric that
REM allows Database Rx to monitor how many logs the standby database lags
REM behind the primary database for non-DataGuard standby databases.
REM
REM The script that runs on the standby server is included at the end of this
REM script, embedded in comments. See comments for installation instructions.
REM
REM Run this script on the primary database as a privileged / DBA user. The
REM script assumes that the Database Rx agent schema is called "ops$dbrx".
REM
REM Modification history:
REM   04-02-2004  Roger Schrag  Created.
REM   12-20-2005  Roger Schrag  Generic updates. Packaged for CVS.
REM   01-15-2006  Terry Sutton  Added minutes behind to logs behind as conditions
REM                             and added variables for thresholds.
REM

CREATE TABLE ops$dbrx.dbrx_metric_1_data
(
standby_last_log_number  NUMBER,
timestamp                DATE
)
TABLESPACE users;


CREATE OR REPLACE PROCEDURE ops$dbrx.database_rx_custom_metric_1
(
p_metric_value    OUT NUMBER,
p_metric_severity OUT NUMBER
)
AS
  v_primary_current_log NUMBER;
  v_standby_last_log    NUMBER;
  v_sev2_minutes_limit  NUMBER;
  v_sev3_minutes_limit  NUMBER;
  v_sev2_logs_limit     NUMBER;
  v_sev3_logs_limit     NUMBER;
  v_time_standby_last_applied DATE;

BEGIN
  -- Set thresholds for how many logs or how many minutes the standby is behind the primary.
  v_sev2_minutes_limit  := 90;  -- Don't raise Sev2 alert unless standby also X minutes behind.
  v_sev3_minutes_limit  := 30;  -- Don't raise Sev3 alert unless standby also X minutes behind.
  v_sev2_logs_limit     := 20;  -- Threshold for logs behind to raise Sev2 alert.
  v_sev3_logs_limit     := 4;   -- Threshold for logs behind to raise Sev2 alert.
  --
  -- Get the sequence number of the current online redo log.
  --
  SELECT MAX (sequence#)
  INTO   v_primary_current_log
  FROM   v$log;
  --
  -- Get the sequence number of the last log applied to the standby database.
  --
  SELECT MAX (standby_last_log_number)
  INTO   v_standby_last_log
  FROM   dbrx_metric_1_data;
  --
  -- Get the time that the log with sequence number standby_last_log_number
  -- was applied to the primary database.
  SELECT MIN (completion_time)
  INTO   v_time_standby_last_applied
  FROM   v$archived_log
  WHERE  sequence# = v_standby_last_log;
  --
  -- Return the gap to the Database Rx agent as the metric value. If we
  -- don't know the gap, raise an unhandled exception so that the agent
  -- does not report any data for this metric.
  --
  IF v_standby_last_log IS NULL THEN
    RAISE no_data_found;
  END IF;

  p_metric_value := v_primary_current_log - v_standby_last_log;
  p_metric_severity := NULL;

  IF v_primary_current_log - v_standby_last_log > v_sev3_logs_limit
  AND (sysdate - v_time_standby_last_applied) * 1440 > v_sev3_minutes_limit
    THEN
    --
    -- Raise a severity 3 alert because the lag is greather than the Sev3 threshold.
    --
    p_metric_severity := 3;
  END IF;

  IF v_primary_current_log - v_standby_last_log > v_sev2_logs_limit
  AND (sysdate - v_time_standby_last_applied) * 1440 > v_sev2_minutes_limit
    THEN
    --
    -- Raise a severity 2 alert because the lag is greather than the Sev2 threshold.
    --
    p_metric_severity := 2;
  END IF;

END database_rx_custom_metric_1;
