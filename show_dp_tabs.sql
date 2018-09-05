-- Drop these for odd completion errors. ORA-31626
col owner.object for a50 trunc
col object_type for a6 trunc
set linesize 100

select o.status, o.object_id, o.object_type, 
          o.owner||'.'||object_name "OWNER.OBJECT" ,
          o.created
from   dba_objects o, dba_datapump_jobs j 
  where  o.owner=j.owner_name and 
         o.object_name=j.job_name and 
         j.job_name not like 'BIN$%' 
order  by 4, 2; 

