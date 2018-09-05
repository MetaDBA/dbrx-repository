select 'restore archivelog from logseq '|| 
        min(sequence#) ||
       ' until logseq ' ||
       max(sequence#) ||
       ' thread ' ||
       thread#  || ';'
from gv$archived_log
where completion_time between
 to_date('&start_date','DD-MON-YY HH24:MI:SS') AND
 to_date('&end_date','DD-MON-YY HH24:MI:SS') 
group by thread#;


