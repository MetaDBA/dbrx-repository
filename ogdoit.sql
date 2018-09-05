-- ******************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : ogdoit.sql
-- * Author             : Craig A. Shallahamer
-- * Original           : 21-may-99
-- * Last Modified      : 21-may-99
-- * Description        : Object Growth : Create "analyze" command file 
-- * 			  and run it (after asking for confirmation).
-- * Usage              : start ogdoit.sql 
-- * 			  Will prompt for details
-- ******************************************************

set echo off verify off

prompt The analyze command file is about to be created.
prompt You will have the opportunity to review it before it is run.
accept yn prompt 'Press RETURN when ready.'

set heading off feedback off

spool azme.txt

select 'analyze '||obj_type||' '||owner||'.'||obj_name||' compute statistics;'
from   o$obj_to_analyze
where  doit = 'Y'
/
spool off

prompt
prompt The actual SQL file is named azme.txt.  You can view it now,
prompt but it should look just like what is above...
prompt 
prompt If the above looks good, just press RETURN for the actual
prompt analyze to take place.  This may take some time!!!
prompt
accept yn 

set echo on feedback on

start azme.txt

set echo off
prompt The analyze has complted...loading data into OG tables...


col xx new_val new_key
select max(the_key)+1 xx
from   o$dba_tables
/


insert into o$dba_tables
(the_key,
 the_date,
 owner,
 table_name,
 tablespace_name,
 pct_free,
 pct_used,
 ini_trans,
 max_trans,
 initial_extent,
 next_extent,
 pct_increase,
 num_rows,
 blocks,
 empty_blocks,
 avg_space,
 chain_cnt,
 avg_row_len
)
select &new_key,
       sysdate,
       dba.owner,
       dba.table_name,
       dba.tablespace_name,
       dba.pct_free,
       dba.pct_used,
       dba.ini_trans,
       dba.max_trans,
       dba.initial_extent,
       dba.next_extent,
       dba.pct_increase,
       dba.num_rows,
       dba.blocks,
       dba.empty_blocks,
       dba.avg_space,
       dba.chain_cnt,
       dba.avg_row_len
from   dba_tables dba,
       o$obj_to_analyze anal
where  dba.owner      = anal.owner
  and  dba.table_name = anal.obj_name
  and  anal.obj_type  = 'TABLE'
/




