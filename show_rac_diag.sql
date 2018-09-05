-- Eric Keen, Database Specialists, Inc  11/14/2011
set linesize 140 numwidth 20 echo on pagesize 999 
col comp_name for a40 trunc
col schema for a10 trunc
col status for a5 trunc
col version for a12 trunc
col name format a30
col value format a50
col name format a20 trunc
col kind format a10 trunc
spool diag_collect.log
select instance_name,sessions_current,sessions_highwater,cpu_count_current,cpu_core_count_current,cpu_socket_count_current
  from gv$license l , gv$instance i 
where l.inst_id=i.inst_id;
select * from v$version;
select comp_name,schema,version,status from dba_registry;
select 	inst_id,
        name,
        value
from	gv$parameter
where	isdefault = 'FALSE'
and	value is not null
order	by inst_id,name;
select inst_id, resource_name, current_utilization, max_utilization,
initial_allocation
from gv$resource_limit
where max_utilization > 0
order by inst_id, resource_name;
column "AVG CR BLK REC TIME (ms)" format 9999999.9
select b1.inst_id, b2.value "GCS CR BLOCKS RECEIVED", 
b1.value "GCS CR BLOCK RECEIVE TIME",
((b1.value / b2.value) * 10) "AVG CR BLK REC TIME (ms)"
from gv$sysstat b1, gv$sysstat b2
where b1.name = 'global cache cr block receive time' and
b2.name = 'global cache cr blocks received' and b1.inst_id = b2.inst_id 
or b1.name = 'gc cr block receive time' and
b2.name = 'gc cr blocks received' and b1.inst_id = b2.inst_id ;
select inst_id, name, kind, file#, status, BLOCKS, 
read_pings, write_pings
from (select p.inst_id, p.name, p.kind, p.file#, p.status, 
count(p.block#) BLOCKS, sum(p.forced_reads) READ_PINGS, 
sum(p.forced_writes) WRITE_PINGS
from gv$ping p, gv$datafile df
where p.file# = df.file# (+)
group by p.inst_id, p.name, p.kind, p.file#, p.status
order by sum(p.forced_writes) desc)
where rownum < 10
order by write_pings desc;
select inst_id, name, kind, file#, status, blocks, 
read_pings, write_pings
from (select p.inst_id, p.name, p.kind, p.file#, p.status, 
count(p.block#) BLOCKS, sum(p.forced_reads) read_pings, 
sum(p.forced_writes) write_pings
from gv$ping p, gv$datafile df
where p.file# = df.file# (+)
group by p.inst_id, p.name, p.kind, p.file#, p.status
order by sum(p.forced_reads) desc)
where rownum < 10
order by read_pings desc;
set numwidth 10
column event format a25 tru
select inst_id, event, time_waited, total_waits, total_timeouts
from (select inst_id, event, time_waited, total_waits, total_timeouts
from gv$system_event where event not in ('rdbms ipc message','smon timer',
'pmon timer', 'SQL*Net message from client','lock manager wait for remote message',
'ges remote message', 'gcs remote message', 'gcs for action', 'client message', 
'pipe get', 'null event', 'PX Idle Wait', 'single-task message', 
'PX Deq: Execution Msg', 'KXFQ: kxfqdeq - normal deqeue', 
'listen endpoint status','slave wait','wakeup time manager')
order by time_waited desc)
where rownum < 10
order by time_waited desc;
select inst_id,name || '(' || kind || ')' object, sum (xnc) conversions
from gv$cache_transfer
group by inst_id,name,kind;
set linesize 140 pagesize 30
select
inst_id,     
instance,   
class,
cr_block, 
cr_busy, 
cr_congested,            
current_block,          
current_busy,          
current_congested     
from
gv$instance_cache_transfer 
where cr_busy > 0
order by cr_busy;
