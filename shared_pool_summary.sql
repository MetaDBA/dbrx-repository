-------------------------------------------------------------------------------
--
-- Script:	shared_pool_summary.sql
-- Purpose:	to get an overview of chunks in the shared pool
-- For:		8.0 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Warning:	This script queries x$ksmsp which causes it to take the
--		shared pool latch for a fairly long time.
--		Think twice before running this script on a large system
--		with potential shared pool problems -- you may make it worse.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select
  ksmchcom  contents,
  count(*)  chunks,
  sum(decode(ksmchcls, 'recr', ksmchsiz))  recreatable,
  sum(decode(ksmchcls, 'freeabl', ksmchsiz))  freeable,
  sum(ksmchsiz)  total
from
  sys.x_$ksmsp
where
  inst_id = userenv('Instance') and
  ksmchcls not like 'R%'
group by
  ksmchcom
/

@restore_sqlplus_settings

