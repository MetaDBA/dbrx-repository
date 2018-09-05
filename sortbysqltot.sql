col username form a12
col sid_serial form a12
col tablespace form a6
set long 100000
break on sql_id skip 1
compute sum label totalspace of mb_used on sql_id

SELECT   S.sid || ',' || S.serial# sid_serial, S.username,
         T.blocks * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
         S.sql_id sql_id, Q.hash_value, substr(Q.sql_fulltext, 1, 100) sqltext
FROM     v$sort_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
WHERE    T.session_addr = S.saddr
AND      S.sql_id  = Q.sql_id  (+)
AND      T.tablespace = TBS.tablespace_name
ORDER BY S.sid;

