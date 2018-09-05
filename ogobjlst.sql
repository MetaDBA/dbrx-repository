-- ******************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : ogobjlst.sql
-- * Author             : Craig A. Shallahamer
-- * Original           : 20-may-99
-- * Last Modified      : 20-may-99
-- * Description        : Object Growth : Which object are scheduled
-- *			  to be loaded.
-- * Usage              : start smobjlst.sql 
-- * 			  Will prompt for details
-- ******************************************************

set echo off verify off

accept owner prompt 'Please enter partial object owner (e.g., or%ty) : '
accept obj   prompt 'Please enter partial object name  (e.g., gl%ba) : '

def osm_prog	= 'ogobjlst.sql'
def osm_title	= 'Object Growth - List Objects Scheduled For Possible Load'

start osmtitle

col owner   format a20  heading "Owner"
col name    format a30  heading "Name"
col do      format  a1  heading "Load?"
col cmpt    format  a1  heading "Compute|Stats?"
col pct     format  99  heading "Estimate|Percent"

select owner own,
       obj_name name,
       obj_type type,
       doit	do,
       compute  cmpt,
       est_pct  pct
from   o$obj_to_analyze
where  owner    like upper('&owner%')
  and  obj_name like upper('&obj%')
/

start osmclear


