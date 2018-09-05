-- ******************************************************
-- * Copyright Notice   : (c)19989 OraPub, Inc.
-- * Filename           : ogobjset.sql
-- * Author             : Craig A. Shallahamer
-- * Original           : 21-may-99
-- * Last Modified      : 21-may-99
-- * Description        : Object Growth : Set object details
-- * Usage              : start ogobjset.sql 
-- * 			  Will prompt for details
-- ******************************************************

set echo off verify off

prompt
accept flag  prompt 'Will you want to stats gathered for these objects? (Y/N) :'
prompt
prompt Enter enough information to ID just the object(s) you want to update.
prompt
accept owner prompt 'Please enter partial object owner (e.g., or%ty)      : '
accept obj   prompt 'Please enter partial object name  (e.g., gl%ba)      : '
accept type  prompt 'Please enter partial object type  (e.g., tab)        : '
prompt
prompt The following objects will be updated.

col own   format a20  heading "Owner"
col name  format a30  heading "Name"
col otype format a10  heading "Type"
col do    format a10  heading "Gather?|(Y/N)"

select owner		own,
       obj_name		name,
       obj_type		otype,
       doit		do
from   o$obj_to_analyze
where  owner    like upper('&owner%')
  and  obj_name like upper('&obj%')
  and  obj_type like upper('&type%')
/

prompt
accept yn prompt 'If this is OK, then press RETURN, otherwise break out now.'
prompt

update o$obj_to_analyze
set    doit = upper('&flag')
where  owner    like upper('&owner%')
  and  obj_name like upper('&obj%')
  and  obj_type like upper('&type%')
/


prompt
prompt The following objects have been updated as shown below.

select owner		own,
       obj_name		name,
       obj_type		otype,
       doit		do
from   o$obj_to_analyze
where  owner    like upper('&owner%')
  and  obj_name like upper('&obj%')
  and  obj_type like upper('&type%')
/

start osmclear


