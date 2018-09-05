select begin_time, end_time, maxquerylen, tuned_undoretention 
from v$undostat 
order by begin_time;

