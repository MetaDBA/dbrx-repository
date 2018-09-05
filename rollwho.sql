select r.name "RB Name ", p.pid "Oracle PID", p.spid "System PID ",
 nvl (p.username, 'No Transaction'), p.terminal
 from v$lock l, v$process p, v$rollname r
 where l.sid = p.pid(+)
   and trunc (l.id1(+)/65536) = r.usn
   and l.type(+) = 'TX'
   and l.lmode(+) = 6
 order by r.name;
