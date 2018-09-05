set pagesize 200 linesize 140
col input_bytes_display heading "Input|Bytes|Disp" for a10 justify right
col output_bytes_display heading "Output|Bytes|Disp"for a10 justify right
col output_bytes_per_sec_display  heading "Output|Bytes|PerSec" for a10 justify right
col time_taken_display heading "Time|Taken|Disp" for a10  justify left
col status for a9 trunc
col command_id for a20 trunc
col output_device_type heading "Dev|Type" for a8 trunc

SELECT
  b.command_id, 
  b.status, 
  b.start_time, 
  b.end_time, 
  b.time_taken_display, 
  b.input_type, 
  b.output_device_type, 
  b.input_bytes_display, 
  b.output_bytes_display, 
  b.output_bytes_per_sec_display 
FROM V$RMAN_BACKUP_JOB_DETAILS b 
WHERE ( b.start_time > (SYSDATE - &lastNumDays) ) order by b.start_time;
