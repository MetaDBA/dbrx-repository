select ((a.count / (b.value + c.value)) * 100) Pct
from v$waitstat a, v$sysstat b, v$sysstat c
where a.class = 'free list'
and b.statistic# = (select statistic#
			from v$statname
			where name = 'db block gets')
and c.statistic# = (select statistic#
			from v$statname
			where name = 'consistent gets');

select total_waits, b.value DB_get, c.value con_get,
	((a.total_waits / (b.value + c.value)) * 100) Busy
from v$system_event a, v$sysstat b, v$sysstat c
where a.event = 'buffer busy waits'
and b.statistic# = (select statistic#
			from v$statname
			where name = 'db block gets')
and c.statistic# = (select statistic#
			from v$statname
			where name = 'consistent gets');
