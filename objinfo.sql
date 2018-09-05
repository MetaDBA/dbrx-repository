def object_name=&&1

col owner form a15
col object_name form a30
col object_type form a20

select owner, object_name, object_type, object_id, created,
last_ddl_time  
from dba_objects
where object_name = upper('&object_name');
