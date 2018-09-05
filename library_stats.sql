-------------------------------------------------------------------------------
--
-- Script:	library_stats.sql
-- Purpose:	to report basic library cache statistics
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select
  namespace,
  gets  locks,
  gets - gethits  loads,
  pins,
  reloads,
  invalidations
from
  sys.v_$librarycache
where
  gets > 0
order by
  2 desc
/

@restore_sqlplus_settings
