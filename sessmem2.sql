
select s1.sid, to_char(s1.value,'999,999,999,999') sess_uga_mem,
                 to_char(s2.value,'999,999,999,999') sess_pga_mem,
                substr(to_char(s.logon_time,'    MM-DD HH24:MI'),1,16) "    Logon_time",
		substr(nvl(decode(type,'BACKGROUND','SYS ('||b.name||')',
	        	s.username),substr(p.program,instr(p.program,'('))),1,15) oracle_user,
                substr(s.osuser,1,8) osuser_
    from v$sesstat s1, v$sesstat s2, v$statname n1,
         v$statname n2, v$session s, v$bgprocess b, v$process p
   where s1.statistic# = n1.statistic#
    and  s2.statistic# = n2.statistic#
    and  n1.name = 'session uga memory'
    and  n2.name = 'session pga memory'
    and  s2.sid = s1.sid
    and  s2.sid = s.sid
    and  s.paddr = p.addr
    and  s.paddr = b.paddr (+)
        order by s.sid;

