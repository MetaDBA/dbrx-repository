-- ********************************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename		: dfl.sql
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 01-feb-01
-- * Description	: Database file listing
-- * Usage		: start dfl.sql
-- ********************************************************************

def osm_prog	= 'dfl.sql'
def osm_title	= 'Database File List'
start osmtitle

col file_type_sort  noprint
col file_type       format a7  heading 'Type'       justify c
col file_name       format a48 heading 'File'       justify c trunc
col file_id	    format a3   heading 'ID'
col file_size       format a7  heading 'Size|in Mb' justify c
col tablespace_name format a14 heading 'Tablespace' justify c trunc

break on file_type duplicates skip 1

select
  1           file_type_sort,
  'CONTROL'   file_type,
  value       file_name,
  ''          file_id,
  ''          file_size,
  ''          tablespace_name
from
  v$parameter
where
  lower(name) = 'control_files'
union
select
  2        file_type_sort,
  'REDO'   file_type,
  group#||':'||member file_name,
  ''       file_id,
  ''       file_size,
  ''       tablespace_name
from
  v$logfile
union
select
  3                                          file_type_sort,
  'DATA'                                     file_type,
  file_name                                  file_name,
  to_char(file_id)			     file_id,
  rpad(to_char(bytes/1048576,'99,990'),7)    file_size,
  tablespace_name                            tablespace_name
from
  dba_data_files
union
select
  4						file_type_sort,
  'TEMP'					file_type,
  file_name					file_name,
  to_char(file_id)			        file_id,
  rpad(to_char(bytes/1048576,'99,990'),7)	file_size,
  tablespace_name				tablespace_name
from
  dba_temp_files
order by 
  1,6,3
/

start osmclear

