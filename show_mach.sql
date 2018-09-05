col machine for a30 trunc
col username for a10 trunc
break on inst_id
select inst_id,machine,username 
from gv$session 
where username is not null
group by inst_id,machine,username
order by 1,2,3;
