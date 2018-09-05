col snap_id noprint
col user_id noprint
col username form a16
col END_INTERVAL_TIME form a26
col BEGIN_INTERVAL_TIME form a26

break on BEGIN_INTERVAL_TIME skip 1 on END_INTERVAL_TIME

select s.snap_id, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME, h.user_id , username, count(*)
from DBA_HIST_SNAPSHOT s, DBA_HIST_ACTIVE_SESS_HISTORY h, dba_users u
where s.snap_id = h.snap_id
and u.user_id = h.user_id
group by  s.snap_id, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME, h.user_id , username
order by  s.snap_id, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME, h.user_id , username
/
