-------------------------------------------------------------------------------
--
-- Script:	session_cursor_cache.sql
-- Purpose:	to check if the session cursor cache is constrained 
-- For:		8.0 and higher
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Description:	If 'session cursor cache count' = session_cached_cursors, then
--		session_cached_cursors should be increased.
--		If 'opened cursors current' + 'session cursor cache count' =
--		open_cursors, then open_cursors should be increased.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column parameter format a29
column value     format a5
column usage     format a5

select
  'session_cached_cursors'  parameter,
  lpad(value, 5)  value,
  decode(value, 0, '  n/a', to_char(100 * used / value, '990') || '%')  usage
from
  ( select
      max(s.value)  used
    from
      sys.v_$statname  n,
      sys.v_$sesstat  s
    where
      n.name = 'session cursor cache count' and
      s.statistic# = n.statistic#
  ),
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'session_cached_cursors'
  )
union all
select
  'open_cursors',
  lpad(value, 5),
  to_char(100 * used / value,  '990') || '%'
from
  ( select
      max(sum(s.value))  used
    from
      sys.v_$statname  n,
      sys.v_$sesstat  s
    where
      n.name in ('opened cursors current', 'session cursor cache count') and
      s.statistic# = n.statistic#
    group by
      s.sid
  ),
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'open_cursors'
  )
/

column cursor_cache_hits format a17
column soft_parses format a11
column hard_parses format a11

select
  to_char(100 * sess / calls, '999999999990.00') || '%'  cursor_cache_hits,
  to_char(100 * (calls - sess - hard) / calls, '999990.00') || '%'  soft_parses,
  to_char(100 * hard / calls, '999990.00') || '%'  hard_parses
from
  ( select value calls from sys.v_$sysstat where name = 'parse count (total)' ),
  ( select value hard from sys.v_$sysstat where name = 'parse count (hard)' ),
  ( select value sess from sys.v_$sysstat where name = 'session cursor cache hits' )
/

column max_cacheable_cursors format 99999999999999999999

select
  max(count(*))  max_cacheable_cursors
from
  ( select
      p.kglobt18  schema#		-- parsing schema number
    from
      sys.x$kglcursor  p
    where
      p.kglobt12 > 2			-- enough parse_calls
    union all
    select
      s.kglntsnm  schema#		-- authorized schema number
    from
      sys.x$kglcursor  c,
      sys.x$kglsn  s
    where
      c.kglobt12 > 2 and
      s.kglhdadr = c.kglhdadr
  )
group by
  schema#
/

@restore_sqlplus_settings
