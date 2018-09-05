set linesize 100
col comp_name for a40 trunc
col schema for a10 trunc
col status for a5 trunc
col version for a12 trunc
select comp_name,schema,version,status from dba_registry;
