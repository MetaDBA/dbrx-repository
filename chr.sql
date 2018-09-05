-- ******************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: chr.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Modified	: 17-AUG-98
-- * Description	: Key SGA cache hit ratios
-- * Usage		: start chr.sql
-- ******************************************************

def osm_prog	= 'chr.sql'
def osm_title	= 'Key SGA Cache Hit Ratios'

set heading off
set termout off
set echo off

col lib_hit			format 999.999 justify right fold_after
col dict_hit		format 999.999 justify right fold_after
col db_hit			format 999.999 justify right fold_after
col ss_avg_users_cursor format 999.99  justify right fold_after
col ss_avg_stmt_exe     format 999.99  justify right fold_after
col a                   format a50     fold_after

set heading off termout off veryify off echo off feedback off

col val2 new_val lib noprint
select 1-(sum(reloads)/sum(pins)) val2
from   v$librarycache
/
col val2 new_val dict noprint
select 1-(sum(getmisses)/sum(gets)) val2
from   v$rowcache
/
col val2 new_val phys_reads noprint
select value val2
from   v$sysstat
where  name = 'physical reads'
/
col val2 new_val log1_reads noprint
select value val2
from   v$sysstat
where  name = 'db block gets'
/
col val2 new_val log2_reads noprint
select value val2
from   v$sysstat
where  name = 'consistent gets'
/
col val2 new_val chr noprint
select 1-(&phys_reads / (&log1_reads + &log2_reads)) val2
from   dual
/

col val2 new_val avg_users_cursor noprint
col val3 new_val avg_stmts_exe    noprint
select sum(users_opening)/count(*) val2,
       sum(executions)/count(*)    val3
from   v$sqlarea
/

set termout on
start osmtitle
set heading off
set feedback off
set verify off

select  'Data Block Buffer Hit Ratio : '||&chr db_hit,
        'Shared SQL Pool' a,
        '  Dictionary Hit Ratio      : '||&dict dict_hit,
        '  Shared SQL Buffers (Library Cache)' a,
        '    Cache Hit Ratio         : '||&lib lib_hit,
 	  '    Avg. Users/Stmt         : '||&avg_users_cursor ss_avg_users_cursor,
	  '    Avg. Executes/Stmt      : '||&avg_stmts_exe ss_avg_stmts_exe
from	dual
/

set heading on

start osmclear

