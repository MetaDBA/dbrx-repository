select to_char(job,'999') "Job",
 substr(log_user,1,8) "Log_User",
 to_char(last_date,'DD-MON HH24:MI') "Last Date",
 to_char(this_date,'DD-MON HH24:MI') "This Date",
 to_char(next_date,'DD-MON-YY HH24:MI') "Next Date",
 substr(interval,1,60) "Interval",
 substr(what,1,60) "What",
 to_char(failures,'99') "  F",
 substr(broken,1,1) "B"
from user_jobs
order by job;
