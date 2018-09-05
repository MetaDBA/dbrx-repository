-------------------------------------------------------------------------------
--
-- Script:	latch_sleeps.sql
-- Purpose:	shows latch sleep statistics
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column name        format a37 heading "LATCH TYPE" trunc
column impact      format 9999999999 heading "IMPACT"
column sleep_rate  format a10 heading "SLEEP RATE"
column holding     format 99999999999 heading "WAITS HOLDING"
column level#      format 9999 heading "LEVEL"

select
  l.name,
  l.sleeps * l.sleeps / (l.misses - l.spin_gets)  impact,
  to_char(100 * l.sleeps / l.gets, '99990.00') || '%'  sleep_rate,
  l.waits_holding_latch  holding,
  l.level#
from
  sys.v_$latch  l
where
  l.sleeps > 0
order by
  2 desc
/

@restore_sqlplus_settings
