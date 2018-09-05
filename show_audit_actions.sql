select username,action_name,count(1) from dba_audit_trail group by username,action_name order by 1; 

