-------------------------------------------------------------------------------
--
-- Script:	drop_xviews.sql
-- Purpose:	to drop the views on the x$ tables (for StatsPack install)
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

spool drop_xviews.tmp
prompt set echo on
select 
  'drop view X_$' || substr(name, 3) || ';'
from
  sys.v_$fixed_table
where
  name like 'X$%'
/
spool off

@restore_sqlplus_settings
@drop_xviews.tmp

set termout off
host rm -f drop_xviews.tmp	-- for Unix
host del drop_xviews.tmp	-- for others

@restore_sqlplus_settings
