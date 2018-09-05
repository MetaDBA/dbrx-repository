col a  form a100 fold_after 1
col b  form a80
col c  form a20		

set heading off
set lines 132

select 
'Owner.Job Name, Job Type     : ' || owner || '.' || job_name b, '    ' || job_type C,
'State, Enabled, Failure Count: ' || state || '  ' || enabled || '  ' || failure_count a,
'Last Start, Next Run         : ' || substr(trunc(last_start_date,'MI'),1,15) || '          ' || substr(trunc(next_run_date,'MI'),1,15) a,
'Repeat Interval              : ' || repeat_interval a,
'Job Action                   : ' || case when length(job_action) < 300 or job_action is null then job_action else '*** Too long to display here ***' end a
from dba_scheduler_jobs
order by job_name;

set heading on
