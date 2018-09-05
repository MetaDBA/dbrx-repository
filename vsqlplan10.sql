def sqlid=&&1

col object_name format a30
col operation format a40
col optimizer format a10
col id format 999
break on child_number skip 1

select ID, parent_id, lpad(' ', LEVEL-1)|| OPERATION || ' ' ||
 OPTIONS operation, OBJECT_NAME, OPTIMIZER, COST, child_number
 from v$sql_plan where sql_id='&&sqlid'
start with id = 0
        and sql_id='&&sqlid'
connect by (prior id = parent_id
        and prior sql_id = sql_id 
        and prior child_number = child_number)

/
