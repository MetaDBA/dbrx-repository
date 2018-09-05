set linesize 100 pagesize 300 echo on
select * from gv$gcspfmaster_info where remaster_cnt > 1 order by remaster_cnt desc;

-- select *  from  gv$policy_history;  
