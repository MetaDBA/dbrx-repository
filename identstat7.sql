select substr(to_char(sysdate, 'MM-DD-YY HH24:MI'),1,15) "Stats as of",
	a.name "Database",
	substr(to_char(to_date(d.value,'J'), 'MM/DD/YY')||' '||
		to_char(to_date(s.value, 'SSSSS'), 'HH24:MI:SS'),1,25)
			"Instance Startup Time",
	to_char(p.value,'999999999999') "DB Block Size"
from v$database a, v$instance d, v$instance s, v$parameter p
where d.key = 'STARTUP TIME - JULIAN'
  and s.key = 'STARTUP TIME - SECONDS'
  and p.name = 'db_block_size';
