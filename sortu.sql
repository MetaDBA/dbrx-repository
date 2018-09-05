col username format a15
col sid format 9999
col tablespace format a12

SELECT s.username, s.sid, s.sql_hash_value, u.tablespace, u.contents, u.extents,
 u.blocks, u.blocks * (select value from v$parameter where name = 'db_block_size')/1048576 MB
FROM v$session s, v$sort_usage u
WHERE s.saddr=u.session_addr;  
