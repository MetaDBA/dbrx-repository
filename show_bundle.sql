set linesize 140 pagesize 100
col comp_id for a15 trunc
col status for a5 trunc
col version for a10 trunc
col comp_name for a30 trunc
col action_time for a30 trunc
col id for a10 trunc
col action for a10 trunc
col bundle for a6 trunc
col comments for a30 trunc
col namespace for a20 trunc

SELECT SUBSTR(comp_id,1,15) comp_id, 
       status, 
       SUBSTR(version,1,10) version, 
       SUBSTR(comp_name,1,30) comp_name 
FROM dba_registry;
select substr(action_time,1,30) action_time,
       substr(id,1,10) id,
       substr(action,1,10) action,
       substr(version,1,8) version,
       substr(BUNDLE_SERIES,1,6) bundle,
       substr(comments,1,30) comments 
from sys.registry$history; 
select * from sys.registry$history; 

