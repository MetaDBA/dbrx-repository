select s.sid, s.username, r.name "ROLLBACK SEG"
   from v$session s, v$transaction t, v$rollname r
  where s.taddr=t.addr
   and  t.xidusn = r.usn; 
