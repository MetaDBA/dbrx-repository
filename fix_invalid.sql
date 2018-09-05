set heading off
set feedback off
spool /tmp/fixinv.run

select
 'alter ' || substr(object_type,1,20) || ' ' || owner || '.' || substr(object_name,1,30) || ' compile;'
from sys.dba_objects
where object_type = 'VIEW'
and status = 'INVALID'
order by owner, object_type;

select 'alter package ' || owner|| '.' || substr(object_name,1,30) || ' compile body;'
from sys.dba_objects
where status = 'INVALID'
and object_type = 'PACKAGE BODY'
order by owner, object_type;

select 'alter procedure ' || owner|| '.' || substr(object_name,1,30) || ' compile;'
from sys.dba_objects
where status = 'INVALID'
and object_type = 'PROCEDURE'
order by owner, object_type;

select
 'select count(*) from ' || substr(object_name,1,30) || ' where rownum = 1;'
from sys.dba_objects
where object_type = 'SYNONYM' and owner = 'PUBLIC'
and status = 'INVALID'
order by owner, object_type;

select
 'select count(*) from ' ||owner|| '.' || substr(object_name,1,30) ||' where rownum = 1;'
from sys.dba_objects
where object_type = 'SYNONYM' and owner <> 'PUBLIC'
and status = 'INVALID'
order by owner, object_type;


spool off

set heading on;
set feedback on;

@/tmp/fixinv.run

