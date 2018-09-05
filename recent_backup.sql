select file#, max(completion_time)
from v$backup_datafile
group by file#
having max(completion_time) < sysdate -5
order by  max(completion_time)
/
