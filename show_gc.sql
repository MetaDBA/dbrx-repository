-- GLOBAL CACHE CR PERFORMANCE
-- This shows the average latency of a consistent block request.  
-- AVG CR BLOCK RECEIVE TIME should typically be about 15 milliseconds depending 
-- on your system configuration and volume, is the average latency of a 
-- consistent-read request round-trip from the requesting instance to the holding 
-- instance and back to the requesting instance. If your CPU has limited idle time 
-- and your system typically processes long-running queries, then the latency may 
-- be higher. However, it is possible to have an average latency of less than one 
-- millisecond with User-mode IPC. Latency can be influenced by a high value for 
-- the DB_MULTI_BLOCK_READ_COUNT parameter. This is because a requesting process 
-- can issue more than one request for a block depending on the setting of this 
-- parameter. Correspondingly, the requesting process may wait longer.  Also check
-- interconnect badwidth, OS tcp settings, and OS udp settings if 
-- AVG CR BLOCK RECEIVE TIME is high.
--
set numwidth 20 linesize 140
column "AVG CR BLOCK RECEIVE TIME (ms)" format 9999999.9
select b1.inst_id, b2.value "GCS CR BLOCKS RECEIVED", 
b1.value "GCS CR BLOCK RECEIVE TIME",
((b1.value / b2.value) * 10) "AVG CR BLOCK RECEIVE TIME (ms)"
from gv$sysstat b1, gv$sysstat b2
where b1.name = 'global cache cr block receive time' and
b2.name = 'global cache cr blocks received' and b1.inst_id = b2.inst_id 
or b1.name = 'gc cr block receive time' and
b2.name = 'gc cr blocks received' and b1.inst_id = b2.inst_id 
order by 1;
