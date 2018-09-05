SELECT substr(name,1,26) "Other Stats", value
	FROM v$sysstat
	WHERE name IN (
		'enqueue waits',
		'dbwr free needed',
                'dbwr free low',
		'redo log space requests',
		'table scans (short tables)',
		'table scans (long tables)',
		'table fetch continued row',
		'sorts (memory)',
		'sorts (disk)');
