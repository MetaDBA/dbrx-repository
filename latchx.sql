-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: latch.sql 
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 20-OCT-00
-- * Description	: Latch contention information for tuning.
-- * Usage		: start latch.sql
-- ********************************************************************

def osm_prog	= 'latchx.sql'
def osm_title	= 'Latch Contention Report for interval'


set echo off feedback off verify off
col val1 new_val new_impact
select sum((b.sleeps - a.sleeps)*((b.sleeps - a.sleeps)/decode((b.gets - a.gets),0,1,(b.gets - a.gets)))) val1
from   v$latch b, latch_snap a
where b.name = a.name
/

start osmtitle

col lname 	heading "Latch Name"	form A24 trunc
col pct_impact	heading "%Impt"	form       90.0
col impact	heading "Impact"	form    9990.00
col gts 	heading "Gets(k)"	form     999990
col mss 	heading "Misses"	form     999990
col hit_ratio	heading "Hit Ratio"	form      0.000
col slps 	heading "Sleeps"	form     9990
col mss 	heading "Misses"	form     999990
col slpsgets 	heading "Sleeps/|Gets"  form     90.000

select	b.name lname,
	(((b.sleeps - a.sleeps)*((b.sleeps - a.sleeps)/decode((b.gets - a.gets),0,1,(b.gets - a.gets))))/(&new_impact))*100 pct_impact,
	(b.sleeps - a.sleeps)*((b.sleeps - a.sleeps)/decode((b.gets - a.gets),0,1,(b.gets - a.gets))) impact,
	(b.gets - a.gets)/1000 gts,
	(b.misses - a.misses) mss,
	round(((b.gets - a.gets)-(b.misses - a.misses))/decode((b.gets - a.gets),0,1,(b.gets - a.gets)),3) hit_ratio,
	(b.sleeps - a.sleeps) slps,
	round((b.sleeps - a.sleeps)/decode((b.gets - a.gets),0,1,(b.gets - a.gets)),3) slpsgets
from	v$latch b, latch_snap a
where   (b.sleeps - a.sleeps)*((b.sleeps - a.sleeps)/decode((b.gets - a.gets),0,1,(b.gets - a.gets))) > 0.0
and      b.name = a.name
order by impact desc, hit_ratio, gts desc, mss desc
/

drop table latch_snap purge;
create table latch_snap as select * from v$latch;

start osmclear
