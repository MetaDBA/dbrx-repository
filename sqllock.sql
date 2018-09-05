-- Gets current and last query for all sessions holding blocking locks
select s.sid, sql_hash_value, prev_hash_value
from v$session s
where s.sid in (
select l.sid from v$lock l
where block = 1);



