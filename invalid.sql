col owner form a15
col obj_name form a30 heading "Object Name"
col object_type form a15

select owner, substr(object_name,1,30) obj_name,
object_type
from dba_objects
where status = 'INVALID';

