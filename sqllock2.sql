def osm_prog	= 'sqllock.sql'
def osm_title	= 'Session Wait Enqueue Details'

start osmtitle

col sid   format    9999 heading "Sid"
col enq   format      a4 heading "Enq."
col edes  format     a30 heading "Enqueue Name"
col md    format     a10 heading "Lock Mode" trunc
col p2    format 9999999 heading "ID 1"
col p3    format 9999999 heading "ID 2"

select s.sid, t.sql_text
from  V$SQLTEXT t, v$session s
WHERE
t.hash_value = s.SQL_HASH_VALUE
and s.sid in
(select w.sid
from   v$session_wait w
where  event = 'enqueue'
)
order by s.sid, t.piece;

start osmclear

