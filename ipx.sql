-- ********************************************************************
-- * Copyright Notice   : (c)2000 OraPub, Inc.
-- * Filename           : ipx
-- * Author             : Craig A. Shallahamer
-- * Original           : 17-jul-00
-- * Last Update        : 17-jul-00
-- * Description        : ALL Instance parameter report
-- * Usage              : Must be run as Oracle user "sys".
-- *			  start ipx.sql
-- * Notes		: Shamelessly taken from Tim Gorman's report.
-- ********************************************************************

def name=&1

def osm_prog    = 'ipx.sql'
def osm_title   = 'Display ALL Instance Parameters'
start osmtitle

col parameter 	format a50 heading "Instance Parameter and Value" word_wrapped
col description format a20 heading "Description" word_wrapped
col dflt 	format a5  heading "Dflt?" word_wrapped

select  rpad(i.ksppinm, 35) || ' = ' || v.ksppstvl parameter,
        i.ksppdesc description,
        v.ksppstdf dflt
from    x$ksppi         i,
        x$ksppcv        v
where   v.indx = i.indx
and     v.inst_id = i.inst_id
and     i.ksppinm like '&name%'
order by i.ksppinm
/

start osmclear

