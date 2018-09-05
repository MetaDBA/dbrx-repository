-------------------------------------------------------------------------------
--
-- Script:	child_sleeps.sql
-- Purpose:	to examine the distribution of sleeps over child latches
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

@accept LatchType "Latch type" "cache buffers %"

column name format a48
column sleeps format a20
break on name

select
  name,
  to_char(min(sleeps)) ||
  decode(
    max(sleeps) - min(sleeps),
    0, null,
    ' to ' || to_char(max(sleeps))
  )  sleeps,
  count(*)  latches
from
  sys.v_$latch_children
where
  name like '&LatchType'
group by
  name,
  trunc(round(log(2, sleeps+1), 37))
/

undefine LatchType

@restore_sqlplus_settings
