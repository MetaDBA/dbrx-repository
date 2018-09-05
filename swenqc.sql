-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: swenqc.sql - SW Enqueue COUNT report
-- * Author		: Craig A. Shallahamer
-- * Original		: 09-oct-98
-- * Last Update	: 10-jul-00
-- * Description	: Show SW enqueue details by COUNT.
-- * Usage		: start swenqc.sql
-- ********************************************************************

def osm_prog	= 'swenqc.sql'
def osm_title	= 'Session Wait Enqueue Details by COUNT'

start osmtitle

col sid   format    9999 heading "Sid"
col enq   format      a4 heading "Enq."
col edes  format     a30 heading "Enqueue Name"
col md    format     a10 heading "Lock Mode" trunc
col p2    format 9999999 heading "ID 1"
col p3    format 9999999 heading "ID 2"
col cnt   format    9990 heading "Count"

select 
       chr(bitand(p1,-16777216)/16777215)||
       chr(bitand(p1, 16711680)/65535) enq,
       decode(
         chr(bitand(p1,-16777216)/16777215)||chr(bitand(p1, 16711680)/65535),
                'TX','Transaction (RBS)',
                'TM','DML Transaction',
                'TS','Tablespace and Temp Seg',
                'TT','Temporary Table',
                'ST','Space Mgt (e.g., uet$, fet$)',
                'UL','User Defined',
         chr(bitand(p1,-16777216)/16777215)||chr(bitand(p1, 16711680)/65535))
         edes,
       decode(bitand(p1,65535),1,'Null',2,'Sub-Share',3,'Sub-Exclusive',
         4,'Share',5,'Share/Sub-Exclusive',6,'Exclusive','Other') md,
       p2,
       p3,
       count(*) cnt
from   v$session_wait
where  event = 'enqueue'
group by p1, p2, p3
/

start osmclear

