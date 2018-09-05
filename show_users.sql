set pagesize 100 linesize 300
col machine for a30 trunc
col username for a15 trunc
col ct for 9,999 
compute sum of ct on report
compute sum of ct on inst_id
break on inst_id skip 1 on report
select inst_id,machine,username,count(1) ct
from gv$session
where username is not null
group by inst_id,machine,username
order by 1,2,3
/
