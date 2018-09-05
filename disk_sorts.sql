-------------------------------------------------------------------------------
--
-- Script:	disk_sorts.sql
-- Purpose:	for sort_area_size tuning
-- For:		8.1 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column average_size format a12

select /*+ ordered */
  s.disk_sorts,
  decode(s.disk_sorts, 0, 'n/a',
    lpad(
      ceil((nvl(w1.kwrites, 0) + nvl(w2.kwrites, 0)) / s.disk_sorts) || 'K',
      12
    )
  )  average_size,
  least(s.disk_sorts, p.peak)  peak_concurrent
from
  (
    select
      value  disk_sorts
    from
      sys.v_$sysstat
    where
      name = 'sorts (disk)'
  )  s,
  (
    select /*+ ordered */
      sum(i.kcfiopbw * e.febsz) / 1024  kwrites
    from
      (
	select distinct
	  tempts#
	from
	  sys.user$
	where
	  type# = 1
      )  u,
      sys.file$  f,
      sys.x_$kcfio  i,
      sys.x_$kccfe  e
    where
      i.inst_id = userenv('Instance') and
      e.inst_id = userenv('Instance') and
      f.ts# = u.tempts# and
      i.kcfiofno = f.file# and
      e.fenum = i.kcfiofno
  )  w1,
  (
    select /*+ ordered use_nl(h) */
      sum(i.kcftiopbw * e.tfbsz) / 1024  kwrites
    from
      (
	select distinct
	  tempts#
	from
	  sys.user$
	where
	  type# = 1
      )  u,
      sys.x_$ktfthc  h,
      sys.x_$kcftio  i,
      sys.x_$kcctf  e
    where
      h.inst_id = userenv('Instance') and
      i.inst_id = userenv('Instance') and
      e.inst_id = userenv('Instance') and
      h.ktfthctsn = u.tempts# and
      i.kcftiofno = h.ktfthctfno and
      e.tfnum = i.kcftiofno
  )  w2,
  (
    select /*+ ordered */
      sum(l.max_utilization)  peak
    from
      (
	select /*+ ordered */ distinct
	  t.contents$
	from
	  (
	    select distinct
	      tempts#
	    from
	      sys.user$
	    where
	      type# = 1
	  )  u,
	  sys.ts$  t
	where
	  t.ts# = u.tempts#
      )  y,
      sys.v_$resource_limit  l
    where
      (y.contents$ = 0 and l.resource_name = 'temporary_table_locks') or
      (y.contents$ = 1 and l.resource_name = 'sort_segment_locks')
  )  p
/

@restore_sqlplus_settings
