-------------------------------------------------------------------------------
--
-- Script:	sparse_tables.sql
-- Purpose:	to report sparse table that should be rebuilt
-- For:		8.0 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Note:	! THIS SCRIPT IS ONLY AS GOOD AS YOUR OPTIMIZER STATISTICS !
--
-- Description:	This reports the data density as a percentage of the number
--		of rows that could fit below the high-water mark.
--		
--		A new PCTFREE of 1 is recommended, on the assumption that
--		there is no risk of row migration.
--
--		The new PCTUSED allows for a little more than one row between
--		PCTFREE and PCTUSED - this may not be enough for tables with
--		very high insert and delete activity.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column table_name format a40
column degree heading " DEGREE"
column density heading "   DATA|DENSITY"
column new_free format 99 heading "SUGGEST|PCTFREE"
column new_used format 99 heading "SUGGEST|PCTUSED"
column reads_wasted format 999999 heading "MBREADS|TO SAVE"

select /*+ ordered */
  u.name ||'.'|| o.name  table_name,
  lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree, 1)), 7)  degree,
  substr(
    to_char(
      100 * t.rowcnt / (
        floor((p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11))
        * t.blkcnt
      ),
      '999.00'
    ),
    2
  ) ||
  '%'  density,
  1  new_free,
  99 - ceil(
    ( 100 * ( p.value - 66 - t.initrans * 24 -
          greatest(
            floor(
              (p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11)
            ) - 1,
            1
          ) * greatest(t.avgrln + 2, 11)
      )
      /
      (p.value - 66 - t.initrans * 24)
    )
  )  new_used,
  ceil(
    ( t.blkcnt - t.rowcnt /
      floor((p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11))
    ) / m.value
  )  reads_wasted
from
  sys.tab$  t,
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'db_file_multiblock_read_count'
  )  m,
  sys.obj$  o,
  sys.user$  u,
  (select value from sys.v_$parameter where name = 'db_block_size')  p
where
  t.tab# is null and
  t.blkcnt > m.value and
  t.chncnt = 0 and
  t.avgspc > t.avgrln and
  ceil(
    ( t.blkcnt - t.rowcnt /
      floor((p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11))
    ) / m.value
  ) > 0 and
  o.obj# = t.obj# and
  o.owner# != 0 and
  u.user# = o.owner#
order by
  5 desc, 2
/

@restore_sqlplus_settings
