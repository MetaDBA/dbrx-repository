-------------------------------------------------------------------------------
--
-- Script:	latch_levels.sql
-- Purpose:	shows the latch types by level (with child counts)
-- For:		8.0 and 8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column latch_level format 99 heading "LATCH|LEVEL"
column type_name format a45 heading "TYPE|NAME"
column parent format 9 heading "PARENT|LATCH"
column children format 999999 heading "CHILD|LATCHES"
break on latch_level

select
  d.kslldlvl  latch_level,
  d.kslldnam  type_name,
  sum(decode(l.kslltcnm, 0, 1, null))  parent,
  sum(decode(l.kslltcnm, 0, null, 1))  children
from
  sys.x_$kslld  d,
  sys.x_$ksllt  l
where
  d.inst_id = userenv('Instance') and
  l.inst_id = userenv('Instance') and
  l.kslltnum = d.indx
group by
  d.kslldlvl,
  d.kslldnam
order by
  d.kslldlvl,
  d.kslldnam
/

@restore_sqlplus_settings
