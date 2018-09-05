-------------------------------------------------------------------------------
--
-- Script:	latch_spins.sql
-- Purpose:	shows latch spin statistics
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column name        format a39 heading "LATCH TYPE"
column spin_gets              heading "SPIN GETS"
column sleep_gets             heading "SLEEP GETS"
column hit_rate    format a13 heading "SPIN HIT RATE"

select
  l.name,
  l.spin_gets,
  l.misses - l.spin_gets  sleep_gets,
  to_char(100 * l.spin_gets / l.misses, '99999990.00') || '%'  hit_rate
from
  sys.v_$latch  l
where
  l.misses > 0
order by
  l.misses - l.spin_gets desc
/

set heading off

select
  'ALL LATCHES'  name,
  sum(l.spin_gets)  spin_gets,
  sum(l.misses - l.spin_gets)  sleep_gets,
  to_char(100 * sum(l.spin_gets) / sum(l.misses), '99999990.00') || '%'  hit_rate
from
  sys.v_$latch  l
where
  l.misses > 0
/

@restore_sqlplus_settings
