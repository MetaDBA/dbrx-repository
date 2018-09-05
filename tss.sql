-- ********************************************************************
-- * Copyright Notice   : (c)1998,9 OraPub, Inc.
-- * Filename		: tss.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 01-APR-99
-- * Description	: Report Oracle tablespace free information
-- * Usage		: start tss.sql
-- ********************************************************************

def osm_prog	= 'tss.sql'
def osm_title	= 'Oracle Database Tablespace Space Summary'

start osmtitle

break on report
compute sum of totspace fspace uspace uextents ffrags on report

col tsname   format         a20 justify c heading 'Tablespace|Name' trunc
col totspace format       9,990 justify c heading 'Total|Space|(MB)'
col fspace   format       9,990 justify c heading 'Free|Space|(MB)'
col uspace   format       9,990 justify c heading 'Used|Space|(MB)'
col pctusd   format         990 justify c heading 'Pct|Used'
col umaxext  format       9,990 justify c heading 'Biggest|Data|Ext|(MB)'
col uextents format     999,990 justify c heading 'Num of|Data|Exts'
col fmaxfrag format       9,990 justify c heading 'Biggest|Free|Ext|(MB)'
col ffrags   format       9,990 justify c heading 'Num Free|Exts'

select
  f.ts_name		tsname,
  (f.free_space+nvl(u.used_space,0))/1048576 totspace,
  nvl(f.free_space/1048576,0)	fspace,
  nvl(u.used_space/1048576,0)	uspace,
  nvl(100*nvl(u.used_space,0)/(f.free_space+u.used_space),0) pctusd,
  nvl(u.max_ext_size/1048576,0)	umaxext,
  nvl(u.num_exts,0)		uextents,
  f.max_frag_size/1048576	fmaxfrag,
  f.num_frags		ffrags
from
  sys.ts_free f,
  sys.ts_used u
where
  f.ts_name = u.ts_name(+)
order by
  f.ts_name
/

start osmclear

