set linesize 140
set pagesize 140
col inst_id for 99
col sid for 999
col qcinst_id for 99
col qc_sid for A5 trunc
col actual_dop for 999
col req_dop for 999
col wait_class for a5 trunc
col wait_event for a10 trunc
col osuser for a5 trunc
col terminal for a5 trunc
col username for a10 trunc
col secWait for 999,999
SELECT
  DECODE(px.qcinst_id,NULL,username,
  ' - '||LOWER(SUBSTR(pp.SERVER_NAME,
  LENGTH(pp.SERVER_NAME)-4,4) ) )"USERNAME",
  s.terminal,
  s.osuser,
  s.inst_id,
  s.sql_id,
  DECODE(px.qcinst_id,NULL, 'QC', '(Slave)') "QC_SLAVE" ,
  s.SID,
  DECODE(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) AS STATE,
  CASE  sw.state WHEN 'WAITING' THEN SUBSTR(sw.event,1,30) ELSE NULL END AS wait_event ,
  CASE  sw.state WHEN 'WAITING' THEN s.wait_class ELSE NULL END AS wait_class ,
  s.wait_time,
  s.seconds_in_wait secWait,
  DECODE(px.qcinst_id, NULL ,TO_CHAR(s.SID) ,px.qcsid) "QC_SID",
  px.qcinst_id,
  px.req_degree Req_DOP,
  px.DEGREE Actual_DOP
FROM gv$px_session px,
     gv$session s ,
     gv$px_process pp,
     gv$session_wait sw
WHERE px.SID=s.SID (+)
AND px.serial#=s.serial#(+)
AND px.inst_id = s.inst_id(+)
AND px.SID = pp.SID (+)
AND px.serial#=pp.serial#(+)
AND sw.SID = s.SID
AND sw.inst_id = s.inst_id
AND type = 'USER'
AND (px.qcinst_id IS NULL OR s.wait_class <> 'Idle')
-- Set the following filters based on initial query results or desired filters
-- AND username = '<USERNAME>'
-- AND terminal = '<TERMINAL>'
-- AND osuser = '<OSUSER>'
ORDER BY
  DECODE(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  DECODE(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
  px.SERVER_SET,
  px.INST_ID
/
