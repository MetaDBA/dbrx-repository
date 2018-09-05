select to_char(first_time, 'MM-DD  HH24') "Hour",
 count(*) "Switches"
from v$loghist
where first_time > sysdate - 2
group by to_char(first_time, 'MM-DD  HH24');

select to_char(count(*),'999,999,999,999,999') "LogSwitchesLast2Days",
 to_char((count(*) * avg(logsize.mbytes)), '9,999,999') "Megs Used"
 from v$loghist, (select bytes/1048576 mbytes
		  from v$log
		  group by bytes) logsize
where first_time > sysdate - 2;

