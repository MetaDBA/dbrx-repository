-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: ds7.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 24-AUG-98
-- * Description	: Data row and data block selectivity (Oracle 6/7)
-- * Usage		: start ds.sql <tbl owner> <tbl name> <col nm>
-- ********************************************************************

def ownr        = &&1
def tnam        = &&2
def cnam        = &&3

def osm_prog    = 'ds7.sql'
def osm_title   = 'Row and Data Block Selectivity (&ownr..&tnam..&cnam)'

col colname justify c format a35   heading '&cnam|Column|Value'
col da_blks justify c format 0.999 heading 'Data Block|Selectivity'
col da_rows justify c format 0.999 heading 'Row|Selectivity'

set termout off echo off feedback off

col val1 new_val nrows noprint
select count(*) val1 from &ownr..&tnam
/
col val2 new_val nblks noprint
select count(distinct(substr(rowid,15,4)||substr(rowid,1,8))) val2
from &ownr..&tnam
/

start osmtitle

select
  &cnam                                                          colname,
  count(distinct(substr(rowid,15,4)||substr(rowid,1,8)))/&nblks  da_blks,
  count(*)/&nrows                                                da_rows
from
  &ownr..&tnam
group by
  &cnam
order by
  2 desc,
  1 asc
/

undef ownr
undef tnam
undef cnam
start osmclear

