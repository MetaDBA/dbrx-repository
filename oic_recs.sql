col name format a25 heading "Instance Parameter"
col value format a13 heading "Current Value"

select name, value 
from v$system_parameter 
where name like 'optimizer_index%';

select  round(a.time_waited_micro/a.total_waits) "Avg_Seq_Read",
	round(b.time_waited_micro/b.total_waits) "Avg_Scat_Read",
	round(100*(a.time_waited_micro/a.total_waits)/(b.time_waited_micro/b.total_waits))
		"Rec OICA Setting"
from v$system_event a, v$system_event b
where a.event = 'db file sequential read'
and   b.event = 'db file scattered read';

SELECT substr((round (1000*(a.value + b.value - c.value)/
                (a.value + b.value)))/10, 1,19) "Rec OIC Setting"
        FROM  v$sysstat a,
                v$sysstat b,
                v$sysstat c
        WHERE a.name = 'db block gets'
        AND     b.name = 'consistent gets'
        AND     c.name = 'physical reads';
