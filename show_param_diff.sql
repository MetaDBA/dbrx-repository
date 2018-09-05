col name for a20 trunc
col value for a40 trunc
set pagesize 140
select name,value from gv$parameter where inst_id = 1 union select name,value from gv$parameter where inst_id = 2
/
