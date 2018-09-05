-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: sysstat - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 17-AUG-98
-- * Description	: Instance Statistics
-- * Usage		: start sysstat.sql <partial param or % for all>
-- ********************************************************************

def pname=&&1

set verify off feedback off echo off

def osm_prog	= 'sysstat.sql'
def osm_title	= 'Instance Statistics Summary (%&pname%)'
start osmtitle

col statistic  format             a60 justify c heading 'Statistic'
col statvalue  format 999,999,999,990 justify c heading 'Value'

select
  n.name	statistic,
  v.value	statvalue
from
  v$statname	n,
  v$sysstat		v
where
  n.statistic# = v.statistic# and
  n.name like '%&pname%'
order by
  1 asc
/

undef pname
start osmclear

