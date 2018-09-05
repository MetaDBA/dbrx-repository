-------------------------------------------------------------------------------
--
-- Script:	multiblock_read_test.sql
-- Purpose:	find largest actual multiblock read size
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Description:	This script prompts the user to enter the name of a table to
--		scan, and then does so with a large multiblock read count, and
--		with event 10046 enabled at level 8.
--		The trace file is then examined to find the largest multiblock
--		read actually performed.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

alter session set db_file_multiblock_read_count = 32768;
/
column value heading "Maximum possible multiblock read count"
select
  value
from
  sys.v_$parameter
where
  name = 'db_file_multiblock_read_count'
/


prompt
@accept Table "Table to scan" SYS.SOURCE$
prompt Scanning ...
set termout off
alter session set events '10046 trace name context forever, level 8'
/
select /*+ full(t) noparallel(t) nocache(t) */ count(*) from &Table t
/
alter session set events '10046 trace name context off'
/

set termout on


@trace_file_name


prompt
prompt Maximum effective multiblock read count
prompt ----------------------------------------

host sed -n '/scattered/s/.*p3=//p' &Trace_Name | sort -n | tail -1

@restore_sqlplus_settings
