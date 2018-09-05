SELECT	EVENT,
	time_waited_micro/total_waits Avg_Wait
FROM	V$SYSTEM_EVENT
WHERE	EVENT LIKE 'db file s% read';
