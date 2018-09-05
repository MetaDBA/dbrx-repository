set linesize 130 pagesize 500
break on inst_id dup skip 3 on report skip 5  dup
compute sum of mb_used on inst_id report 
compute sum of mb_used on report
col username for a5 trunc
col sid_serial for a10 trunc
col sql_text for a80 wrap
col inst_id for 999
col mb_used for 999,999.999
spool temp
SELECT   t.inst_id,S.sid || ',' || S.serial# sid_serial, S.username,
         T.blocks * TBS.block_size / 1024 / 1024 mb_used, 
         Q.hash_value, 
          Q.sql_text
-- FROM     v$sort_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
FROM     gv$tempseg_usage T, gv$session S, gv$sqlarea Q, dba_tablespaces TBS
WHERE    T.session_addr = S.saddr
         and t.inst_id = s.inst_id
         and q.inst_id = s.inst_id
         and (T.blocks * TBS.block_size / 1024 / 1024) > .01
AND      T.sqladdr = Q.address (+)
AND      T.tablespace = TBS.tablespace_name
ORDER BY inst_id,4;

