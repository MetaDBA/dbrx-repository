-- ******************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : ogbigld.sql
-- * Author             : Craig A. Shallahamer
-- * Original           : 21-may-99
-- * Last Modified      : 21-may-99
-- * Description        : Object Growth : Load objects into OG tables
-- * Usage              : start ogbigld.sql 
-- * 			  Will prompt for details
-- ******************************************************

set echo off verify off

accept owner prompt 'Please enter partial object owner (e.g., or%ty) : '
accept obj   prompt 'Please enter partial object name  (e.g., gl%ba) : '

col own   format a20  heading "Owner"
col name  format a30  heading "Name"
col otype format a10  heading "Type"

prompt
prompt These objects currently reside in the database (dba_objects) and
prompt NOT in the Object Gatherer tables (o$dba_objects)
prompt

select owner       own,
       object_name name,
       object_type otype
from   dba_objects
where  owner       like upper('&owner%')
  and  object_name like upper('&obj%')
minus
select owner       own,
       object_name name,
       type        otype
from   o$dba_objects
where  owner       like upper('&owner%')
  and  object_name like upper('&obj%')
/

prompt
accept yn prompt 'If you would like these objects loaded, press RETURN.'

insert into o$obj_to_analyze
(
  owner,
  obj_name,
  obj_type,
  doit,
  compute,
  est_pct
)
select owner       own,
       object_name name,
       object_type otype,
       'N',
       'Y',
       100
from   dba_objects
where  owner       like upper('&owner%')
  and  object_name like upper('&obj%')
minus
select owner       own,
       object_name name,
       type        otype,
       'N',
       'Y',
       100
from   o$dba_objects
where  owner       like upper('&owner%')
  and  object_name like upper('&obj%')
/

prompt
prompt The objects have been loaded.
prompt You must run ogobjset to enable the actual stats gathering.
prompt









