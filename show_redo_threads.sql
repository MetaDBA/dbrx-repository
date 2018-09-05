select thread#,group#,count(1) from gv$log group by thread#,group# order by 1,2;

select thread#,status,enabled,sequence#,checkpoint_time
from gv$thread order by thread#; 
