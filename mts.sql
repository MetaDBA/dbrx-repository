-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: mts.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 24-SEP-98
-- * Last Update	: 24-SEP-98
-- * Description	: Show MTS information
-- * Usage		: start mts.sql
-- ********************************************************************

def osm_prog	= 'mts.sql'
def osm_title	= 'Oracle Multi-Threaded Server Statistics'

-- start osmtitle

ttitle off

col prot	heading 'Protocol'  format   A50 justify c
col busy_rt	heading 'Busy Rate %' format   990.000 justify right

set feedback off heading on

select	network prot,
	sum(busy) / (sum(busy) + sum(idle)) busy_rt
from	v$dispatcher
group by network
/

ttitle off
set heading off

select	'Request time in request Q (avg wait time): '||
        to_char(decode(totalq,0,'No Requests',wait/totalq),990.000) || 
	' hundredths of seconds'
from	v$queue
where	type = 'COMMON'
/
select 'Dispatchers ' ||status, count(STATUS) 
	from v$dispatcher group by status
/
select server||' server connections:     ',count(server) Processes 
	from v$session group by server
/
select 'Shared Server Processes Running:           '||count(*)
from   v$shared_server
where  status != 'QUIT'
/
select 'Shared servers:'||status,count(status) 
	from v$shared_server group by status
/
start osmclear
