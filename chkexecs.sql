select hash_value, executions, round(elapsed_time/1000000) elapsed, sql_fulltext 
from v$sqlarea 
where upper(sql_fulltext) like upper('%&1%');

