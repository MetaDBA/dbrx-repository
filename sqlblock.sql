select s.sid, sql_text
from V$sqltext t, v$session s
where t.address = s.prev_sql_addr
and s.sid in (
SELECT /*+ CHOOSE */
	bs.sid 
FROM 
   v$lock hk,  v$session bs, 
			v$lock wk,  v$session ws 
WHERE 
     hk.block   = 1 
AND  hk.lmode  != 0 
AND  hk.lmode  != 1 
AND  wk.request  != 0 
AND  wk.TYPE (+) = hk.TYPE 
AND  wk.id1  (+) = hk.id1 
AND  wk.id2  (+) = hk.id2 
AND  hk.sid    = bs.sid(+) 
AND  wk.sid    = ws.sid(+)
and (bs.username is not null) and (bs.username<>'SYSTEM')  and (bs.username<>'SYS') 
)
ORDER BY s.sid, t.piece;


