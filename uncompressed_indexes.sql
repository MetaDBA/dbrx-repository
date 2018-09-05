-------------------------------------------------------------------------------
--
-- Script:	uncompressed_indexes.sql
-- Purpose:	to identify indexes that would benefit from compression
-- For:		8.1 and above
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Note:	! THIS SCRIPT IS ONLY AS GOOD AS YOUR OPTIMIZER STATISTICS !
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column index_name format a54

select
  u.name ||'.'|| o.name  index_name,
  decode(
    sign(s.full_save - s.one_save),
    -1, 1,
    decode(s.cols, 1, 1, 2)
  )  min_compress,
  decode(
    sign(s.full_save - s.one_save),
    -1, greatest(1, least(s.max_ok, s.cols - 1)),
    s.cols
  )  max_compress
from
  (
    select
      x.obj#,
      x.cols,
      x.leaf_bytes,
      x.full_save,
      x.max_ok,
      h1.avgcln * (x.rowcnt - h1.null_cnt - h1.distcnt) - 4 * h1.distcnt
        one_save
    from
      ( select
	  i.obj#,
	  i.cols,
	  i.rowcnt,
	  (sum(h.avgcln) + 10) * i.rowcnt  leaf_bytes,
	  sum(h.avgcln) * (i.rowcnt - i.distkey) - 4 * i.distkey  full_save,
          max(decode(sign(i.rowcnt - 2 * h.distcnt), -1, 0, ic.pos#)) max_ok
	from
	  sys.ind$  i,
	  sys.icol$  ic,
	  sys.hist_head$  h
	where
	  i.leafcnt > 1 and
	  i.type# in (1,4,6) and		-- exclude special types
	  bitand(i.property, 8) = 0 and		-- exclude compressed
	  ic.obj# = i.obj# and
	  h.obj# = i.bo# and
	  h.intcol# = ic.intcol#
	group by
	  i.obj#,
	  i.cols,
	  i.rowcnt,
	  i.distkey
      )  x,
      sys.icol$  c1,
      sys.hist_head$  h1
    where
      c1.obj# = x.obj# and
      c1.pos# = 1 and
      h1.obj# = c1.bo# and
      h1.intcol# = c1.intcol#
  )  s,
  sys.obj$  o,
  sys.user$  u
where
  greatest(s.full_save, s.one_save)  > 0.05 * s.leaf_bytes and
  o.obj# = s.obj# and
  o.owner# != 0 and
  u.user# = o.owner#
order by
  greatest(s.full_save, s.one_save) desc
/

@restore_sqlplus_settings
