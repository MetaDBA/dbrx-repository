-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: sqls3 
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 12-SEP-03 by Terry Sutton
-- * Description	: Show SQL statement text for a given hash value
-- * Usage		: start sqls3.sql <hash value>
-- ********************************************************************

def hash=&&1

def osm_prog    = 'sqls3.sql'
def osm_title   = 'SQL Statement Text (Hash=&hash)'

col hv		noprint
col ln		noprint
col text	heading 'SQL Statement Text'    format          A64
col execs	heading 'Execs'		 	format       999,999,999
col bufgets	heading 'Bufgts(K)'		format	     999,999,999
col physreads	heading 'DskRds(K)'		format        9,999
col loads	heading 'Loads'			format	      99,999
col elapsed	heading 'Elapsed|Secs'		format	    999,999,999,999

start osmtitle

select  t.hash_value hv,
        t.piece ln,
        t.sql_text text,
	a.executions execs,
	a.buffer_gets/1000 bufgets,
	a.disk_reads/1000 physreads,
	a.loads loads,
	round(a.elapsed_time/1000000) elapsed
from    v$sqlarea a,
        v$sqltext t
where   a.hash_value = t.hash_value
  and   a.hash_value = '&hash'
order by 1,2
/

undef sqls_id
start osmclear

