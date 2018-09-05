set echo off  
spool pool_est  
/*  
*********************************************************  
*                                                       *  
* TITLE        : Shared Pool Estimation                 *  
* CATEGORY     : Information, Utility                   *  
* SUBJECT AREA : Shared Pool                            *  
* DESCRIPTION  : Estimates shared pool utilization      *  
*  based on current database usage. This should be      *  
*  run during peak operation, after all stored          *  
*  objects i.e. packages, views have been loaded.       *  
*                                                       *  
*                                                       *  
********************************************************/  
Rem If running MTS uncomment the mts calculation and output  
Rem commands.    
set serveroutput on;    
declare
          object_mem number;
          shared_sql number;
          cursor_mem number;
          mts_mem number;
          used_pool_size number;
          free_mem number;
          pool_size varchar2(512); -- same as V$PARAMETER.VALUE  
begin    

-- Stored objects (packages, views)  
select sum(sharable_mem) into object_mem from v$db_object_cache;    

-- Shared SQL -- need to have additional memory if dynamic SQL used  
select sum(sharable_mem) into shared_sql from v$sqlarea;    

-- User Cursor Usage -- run this during peak usage.  
--  assumes 250 bytes per open cursor, for each concurrent user.  
select sum(250*users_opening) into cursor_mem from v$sqlarea;    

-- For a test system 
-- get usage for one user, multiply by # users  
-- select (250 * value) bytes_per_user  
-- from v$sesstat s, v$statname n  
-- where s.statistic# = n.statistic#  
-- and n.name = 'opened cursors current'  
-- and s.sid = 25;  
-- where 25 is the sid of the process    

-- MTS memory needed to hold session information for shared server users  
-- This query computes a total for all currently logged on users (run  
--  during peak period). Alternatively calculate for a single user and  
--  multiply by # users.  
select sum(value) into mts_mem from v$sesstat s, v$statname n  
       where s.statistic#=n.statistic#    
       and n.name='session uga memory max';    

-- Free (unused) memory in the SGA: gives an indication of how much memory  
-- is being wasted out of the total allocated.  
select bytes into free_mem from v$sgastat   
       where name = 'free memory'
        and pool = 'shared pool';    -- necessary for 8i+ because of java pool


-- For non-MTS add up object, shared sql, cursors and 20% overhead.  
used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem));    

-- For MTS mts contribution needs to be included (comment out previous line)  
-- used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem+mts_mem));    

select value into pool_size from v$parameter where name='shared_pool_size';    
-- Display results  
dbms_output.put_line ('Obj mem:  '||to_char (object_mem) || ' bytes');  
dbms_output.put_line ('Shared sql:  '||to_char (shared_sql) || ' bytes');  
dbms_output.put_line ('Cursors:  '||to_char (cursor_mem) || ' bytes');  
-- dbms_output.put_line ('MTS session: '||to_char (mts_mem) || ' bytes');  
dbms_output.put_line ('Free memory: '||to_char (free_mem) || ' bytes ' || '('  ||
 to_char(round(free_mem/1024/1024,2)) || 'MB)');  
dbms_output.put_line ('Shared pool utilization (total):  '||
  to_char(used_pool_size) || ' bytes ' || '(' ||
  to_char(round(used_pool_size/1024/1024,2)) || 'MB)');  
dbms_output.put_line ('Shared pool allocation (actual):  '||
  pool_size ||'  bytes ' || '(' || to_char(round(pool_size/1024/1024,2)) || 'MB)');
dbms_output.put_line ('Percentage Utilized:  '|| 
  to_char  (round(used_pool_size/pool_size*100)) || '%');  
end;  
/    
spool off 
