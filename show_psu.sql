set linesize 140
col action_time for a30 trunc
col action for a10 trunc
col bundle_series for a7 trunc
col version for a12 trunc
col id for 999
col comments for a22 trunc
select action_time,action,version,bundle_series,id,comments from sys.registry$history;

