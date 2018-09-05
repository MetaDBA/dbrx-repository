REM Run as SYS

select sum(count) "Buffer Cache Hits", 
100*trunc(indx/100)+1 || ' to ' || 100*(trunc(indx/100)+1)
"Interval" 
from sys.x$kcbcbh
where indx > 0 group by trunc(indx/100);