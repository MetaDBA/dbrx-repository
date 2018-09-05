def hashvalue=&&1

col object_name format a30
col operation format a40
col optimizer format a10
col id format 999
break on child_number skip 1

select ID, parent_id, lpad(' ', LEVEL-1)|| OPERATION || ' ' ||
 OPTIONS operation, substr(object_owner,1,3) || '.' || OBJECT_NAME object_name, OPTIMIZER, COST, child_number
 from v$sql_plan where hash_value='&&hashvalue'
start with id = 0
        and hash_value='&&hashvalue'
connect by (prior id = parent_id
        and prior hash_value = hash_value
        and prior child_number = child_number)
;

undef hashvalue
