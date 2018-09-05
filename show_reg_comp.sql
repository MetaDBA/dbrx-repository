set linesize 100 pagesize 100
col comp_name format a35 heading 'Component'
col version format a12 heading 'Version'
col status format a10 heading 'Status'
col modified heading 'Modified'

select comp_name
, version
, status
, modified 
from dba_registry 
order by 1;
