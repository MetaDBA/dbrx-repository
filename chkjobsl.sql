col Interval form a50
col What form a130
col Log_user form a8
col last_date form a15 heading "Last Date"
col this_date form a15 heading "This Date"
col next_date form a15 heading "Next Date"

select to_char(job,'9999') "Job",
 substr(log_user,1,8) "Log_User",
 to_char(last_date,'DD-MON HH24:MI') last_date,
 to_char(this_date,'DD-MON HH24:MI') this_date,
 to_char(next_date,'DD-MON-YY HH24:MI') next_date,
 to_char(failures,'99') "  F",
 substr(broken,1,1) "B",
 substr(interval,1,60) "Interval",
 Instance,
 substr(what,1,130) "What"
from dba_jobs
order by job;

