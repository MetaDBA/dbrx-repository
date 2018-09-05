select a.sequence#, (a.completion_time - h.first_time)*1440 "min to arch", a.completion_time
 from v$archived_log a, v$loghist h
where a.completion_time > sysdate - 2
and a.sequence#  = h.sequence#;

