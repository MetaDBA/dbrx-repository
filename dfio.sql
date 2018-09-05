-- ********************************************************************
-- * Copyright Notice   : (c)1998,2000 OraPub, Inc.
-- * Filename		: dfio.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 10-jul-00
-- * Description	: Database file i/o basic data.
-- *			  Used to help spot heavy hit db files.
-- * Usage		: start dflio.sql
-- ********************************************************************

def osm_prog	= 'dfio.sql'
def osm_title	= 'Database File I/O Information'

col dbf	    heading 'Data File'	 	format  A28 justify c trunc
col writes  heading 'Write|Req(k)'	format  9,999,999
col reads   heading 'Read|Req(k)'     	format  99,999,999
col bwrites heading 'Blk|Writes(k)'	format  9,999,999
col breads  heading 'Blk|Reads(k)'     	format  99,999,999
col pctfts  heading 'FTS%'       	format        90.0

set termout off
col val1 new_val mbrc noprint
select value val1
from v$parameter
where name = 'db_file_multiblock_read_count'
/

start osmtitle

select
	name		            dbf,
	phywrts/1000	            writes,
        phyblkwrt                   bwrites,
	phyrds/1000                 reads,
        phyblkrd/1000               breads,
	100*(phyblkrd/(phyrds+0.01))/&mbrc  pctfts
from	v$datafile a,
	v$filestat b
where   a.file# = b.file#
order by 2 desc,
         1 desc
/

start osmclear
