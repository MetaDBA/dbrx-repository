set linesize 140
col checkpoint_change# format 99999999999999999999999
col chkptchangeTime format a32 trunc
col currtime for a20 trunc
select checkpoint_change#, 
       scn_to_timestamp(checkpoint_change#) chkptchangeTime,
       to_char(sysdate,'DD-MON-YY HH:MI AM') currtime 
  from v$database;
