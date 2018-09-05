set linesize 140 pagesize 100
select resource_name,current_utilization,max_utilization, limit_value from gv$resource_limit order by 1
/
