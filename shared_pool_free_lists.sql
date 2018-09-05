-------------------------------------------------------------------------------
--
-- Script:	shared_pool_free_lists.sql
-- Purpose:	to check the length of the shared pool free lists
-- For:		8.1.6 to 8.1.7
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select
  decode(
    sign(ksmchsiz - 812),
    -1, (ksmchsiz - 16) / 4,
    decode(
      sign(ksmchsiz - 4012),
      -1, trunc((ksmchsiz + 11924) / 64),
      decode(
        sign(ksmchsiz - 65548),
        -1, trunc(1/log(ksmchsiz - 11, 2)) + 238,
        254
      )
    )
  )  bucket,
  sum(ksmchsiz)  free_space,
  count(*)  free_chunks,
  trunc(avg(ksmchsiz))  average_size,
  max(ksmchsiz)  biggest
from
  sys.x_$ksmsp
where
  inst_id = userenv('Instance') and
  ksmchcls = 'free'
group by
  decode(
    sign(ksmchsiz - 812),
    -1, (ksmchsiz - 16) / 4,
    decode(
      sign(ksmchsiz - 4012),
      -1, trunc((ksmchsiz + 11924) / 64),
      decode(
        sign(ksmchsiz - 65548),
        -1, trunc(1/log(ksmchsiz - 11, 2)) + 238,
        254
      )
    )
  )
/

@restore_sqlplus_settings

