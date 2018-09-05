prompt must be run by sys or user who has privs on kglob

select to_char(sysdate, 'HH:MI:SS') time, KGLNAHSH hash, sum(sleeps) sleeps,location,MUTEX_TYPE
, substr(KGLNAOBJ,1,40) object
from x$kglob , v$mutex_sleep_history
where kglnahsh=mutex_identifier
group by KGLNAOBJ,KGLNAHSH,location,MUTEX_TYPE
order by sleeps;

