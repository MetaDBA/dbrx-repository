-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename		: latch.sql 
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 20-OCT-00
-- * Description	: Latch contention information for tuning.
-- * Usage		: start latch.sql
-- ********************************************************************

def osm_prog	= 'latch.sql'
def osm_title	= 'Latch Contention Report'


set echo off feedback off verify off
col val1 new_val new_impact
select sum(sleeps*(sleeps/decode(gets,0,1,gets))) val1
from   v$latch
/

start osmtitle

col lname 	heading "Latch Name"	form A24 trunc
col pct_impact	heading "%Impt"	form       90.0
col impact	heading "Impact"	form    9990.00
col gts 	heading "Gets(k)"	form     999990
col mss 	heading "Misses"	form     99999990
col hit_ratio	heading "Hit Ratio"	form      0.000
col slps 	heading "Sleeps"	form     999990
col mss 	heading "Misses"	form     999990
col slpsgets 	heading "Sleeps/|Gets"  form     90.000

select	name lname,
	((sleeps*(sleeps/decode(gets,0,1,gets)))/(&new_impact))*100 pct_impact,
	sleeps*(sleeps/decode(gets,0,1,gets)) impact,
	gets/1000 gts,
	misses mss,
	round((gets-misses)/decode(gets,0,1,gets),3) hit_ratio,
	sleeps slps,
	round(sleeps/decode(gets,0,1,gets),3) slpsgets
from	v$latch
where   sleeps*(sleeps/decode(gets,0,1,gets)) > 0.0
order by impact desc, hit_ratio, gets desc, misses desc, name
/

start osmclear
