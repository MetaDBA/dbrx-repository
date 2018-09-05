REM /* Database buffer cache hit ratio */
col hitratio form 99.99 heading "Buffer Cache|Hit Ratio "

SELECT to_char(a.value + b.value, '999,999,999,999') "Logical Reads",
	to_char(c.value, '9,999,999,999') "Physical Reads",
	(round (1000*(a.value + b.value - c.value)/
		(a.value + b.value)))/10  hitratio
	FROM  v$sysstat a,
		v$sysstat b,
		v$sysstat c
	WHERE a.name = 'db block gets'
	AND	b.name = 'consistent gets'
	AND	c.name = 'physical reads';
