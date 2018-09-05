set linesize 140 echo on
select s.sql_hash_value, sw.p1 file#, sw.p2 block#, sw.p3 reason
FROM gv$session_wait sw, gv$session s
WHERE sw.event = 'buffer busy waits'
AND sw.sid = s.sid and sw.inst_id = s.inst_id;
