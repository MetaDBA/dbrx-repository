set linesize 132

select substr(fulldate(began),1,20) "Began",
 substr(fulldate(ended),1,20) "Ended",
substr(sqltext,1,60) "Sqltext",
substr(error_text,1,10) "Error Text"
from background_jobs_run;
