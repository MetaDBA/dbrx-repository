REM
REM alert_severity.sql
REM ==================
REM
REM This script will display all alert log lines for a specified sample,
REM the severity that the loader assigned to each, and whether or not each
REM line has been excluded at the instance level. Use this script to figure
REM out what specific line in an alert log excerpt caused the alert to get
REM a certain severity assignment.
REM
REM

SET VERIFY OFF

ACCEPT cust CHAR PROMPT "Enter customer short name: "
ACCEPT date CHAR PROMPT "Enter sample date as MM-DD-YYYY HH24:MI: "

COL sample_id NEW_VALUE sample_id

SELECT   A.customer_short_name customer, B.current_instance_name instance,
         C.sample_id, C.sample_type, 
         TO_CHAR (C.sample_date_db_local_time,
                  'mm-dd-yyyy hh24:mi:ss') sample_date
FROM     dbrx_owner.customers A, dbrx_owner.customer_instances B, 
         dbrx_owner.samples C
WHERE    A.customer_short_name = '&cust'
AND      B.customer_id = A.customer_id
AND      C.instance_id = B.instance_id
AND      C.sample_type IN ('full_stat', 'ping')
AND      C.sample_date_db_local_time BETWEEN
           TO_DATE (RTRIM ('&date') || ':00', 'mm-dd-yyyy hh24:mi:ss') AND
           TO_DATE (RTRIM ('&date') || ':59', 'mm-dd-yyyy hh24:mi:ss')
ORDER BY C.sample_id;

SET PAGESIZE 99

COL severity_id           FORMAT 90      HEADING SEV
COL excl                  FORMAT a4
COL alert_log_line_number FORMAT 9999990 HEADING LINE_NUM
COL alert_log_text        FORMAT a62

SELECT   A.severity_id, 
         DECODE (dbrx_owner.analyzer.check_omit_list 
                   (39, 'alert log strings to ignore', A.alert_log_text,
                    B.instance_id),
                   1, ' ', 'X') excl,
         A.alert_log_line_number, A.alert_log_text
FROM     dbrx_owner.sample_alert_log_lines A, dbrx_owner.samples B
WHERE    B.sample_id = &sample_id
AND      A.sample_id = B.sample_id
ORDER BY A.alert_log_line_number;

