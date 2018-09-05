-------------------------------------------------------------------------------
--
-- Script:	reserved_pool_hwm.sql
-- Purpose:	to get the hwm of reserved pool usage
-- For:		8.1 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

define Stopper = 40	-- 40 for 8.1, 48 previously

select
  sum(r.ksmchsiz) - &Stopper  reserved_size,
  sum(
    r.ksmchsiz -
    decode(h.kghlunfu, 0, decode(r.indx, 1, r.ksmchsiz, 0), 0)
  ) - &Stopper  high_water_mark,
  to_char(
    100 * (sum(
	     r.ksmchsiz -
	     decode(h.kghlunfu, 0, decode(r.indx, 1, r.ksmchsiz, 0), 0)
	   ) - &Stopper
	  ) / (sum(r.ksmchsiz) - &Stopper),
    '99999999'
  ) || '%'  "PEAK USAGE"
from
  sys.x_$kghlu  h,
  sys.x_$ksmspr  r
where
  h.inst_id = userenv('Instance') and
  r.inst_id = userenv('Instance')
/

undefine Stopper
@restore_sqlplus_settings

