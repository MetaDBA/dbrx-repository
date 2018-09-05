-------------------------------------------------------------------------------
--
-- Script:	create_xviews.sql
-- Purpose:	to create views on the x$ tables
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Comment:	Must be executed as SYS via SQL*Plus.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set pagesize 0
set termout off
set echo off

spool create_xviews.tmp
prompt set echo on
select 
  'create or replace view X_$' || substr(name, 3) ||
  ' as select * from ' || name || ';'
from
  sys.v_$fixed_table
where
  name like 'X$%'
/
spool off

@restore_sqlplus_settings
@create_xviews.tmp

set termout off
host rm -f create_xviews.tmp	-- for Unix
host del create_xviews.tmp	-- for others

@restore_sqlplus_settings
