-------------------------------------------------------------------------------
--
-- Script:	latch_gets.sql
-- Purpose:	shows latch get statistics
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column name        format a30 heading "LATCH TYPE"  trunc
column simple_gets format a18 heading "SIMPLE GETS" justify right
column spin_gets   format a14 heading "SPIN GETS"   justify right
column sleep_gets  format a14 heading "SLEEP GETS"  justify right

select
  l.name,
  substr(
    to_char(
      l.gets - l.misses,
      '9999999990'
    ),
    2
  ) ||
  ' ' ||
  substr(
    to_char(
      100 * (l.gets - l.misses) / l.gets,
      '999.00'
    ),
    2
  ) ||
  '%'  simple_gets,
  substr(
    to_char(
      l.spin_gets,
      '9999990'
    ),
    2
  ) ||
  ' ' ||
  substr(
    to_char(
      100 * l.spin_gets / l.gets,
      '90.00'
    ),
    2
  ) ||
  '%'  spin_gets,
  substr(
    to_char(
      l.misses - l.spin_gets,
      '9999990'
    ),
    2
  ) ||
  ' ' ||
  substr(
    to_char(
      100 * (l.misses - l.spin_gets) / l.gets,
      '90.00'
    ),
    2
  ) ||
  '%'  sleep_gets
from
  sys.v_$latch  l
where
  l.gets > 0
order by
  l.name
/

@restore_sqlplus_settings
