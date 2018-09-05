-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: latch.sql - Version 1.1
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 02-AUG-00
-- * Description	: Latch contention information for tuning.
-- * Usage		: start latch.sql
-- ********************************************************************

def osm_prog	= 'latch.sql'
def osm_title	= 'Latch Contention Report'

col lname 	heading "Latch Name"	form A37 trunc
col gts 	heading "Gets(k)"	form     999,999,990
col mss 	heading "Misses"	form     999,999,990
col hit_ratio	heading "Hit Ratio"	form         0.000

start osmtitle

select 'NW '||name lname,
    immediate_gets/1000 gts,
    immediate_misses mss,
    round((immediate_gets/(immediate_gets+immediate_misses)), 3)
      hit_ratio
   from v$latch
    where immediate_gets + immediate_misses != 0
    order by hit_ratio desc, immediate_gets desc, 
	     immediate_misses desc, name
/

ttitle off

col lname 	heading "Latch Name"	form A30 trunc
col impact	heading "Impact"	form    9990.00
col gts 	heading "Gets(k)"	form     999990
col mss 	heading "Misses"	form     999990
col hit_ratio	heading "Hit Ratio"	form      0.000
col slps 	heading "Sleeps"	form     9990
col mss 	heading "Misses"	form     999990
col slpsgets 	heading "Sleeps/|Gets"  form     90.000

select	'WW '||name lname,
	sleeps*(sleeps/decode(gets,0,1,gets)) impact,
	gets/1000 gts,
	misses mss,
	round((gets-misses)/decode(gets,0,1,gets),3) hit_ratio,
	sleeps slps,
	round(sleeps/decode(gets,0,1,gets),3) slpsgets
from	v$latch
where 	gets != 0
order by impact desc, hit_ratio, gets desc, misses desc, name
/

start osmclear
