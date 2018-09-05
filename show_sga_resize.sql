-- check ASMM 
show parameter sga
show parameter pga

column component format a20
column parameter format a30  
column initial_size format 99,999,999,999
column target_size format 99,999,999,999
column final_size format 99,999,999,999
set linesize 90 pagesize 60  
select component,
        oper_type,
        oper_mode,
        parameter,
        initial_size,
        target_size,
        final_size,
        status,
        to_char(start_time,'dd-mon hh24:mi:ss') start_time,
        to_char(end_time,'dd-mon hh24:mi:ss')   end_time
from v$sga_resize_ops
order by start_time
;  
 
