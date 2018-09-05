-------------------------------------------------------------------------------
--
-- Script:	buffer_busy_sample.sql
-- Purpose:	to sample to the buffer busy wait parameters and sql text
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column wait format a15
column address noprint
column piece noprint
break on wait

select /*+ ordered */ distinct
  w.wait,
  t.address,
  t.piece,
  translate(t.sql_text, chr(13), ' ') sql_text
from
  ( select sid,
           p3||' on '||p1||'.'||p2  wait
    from   sys.v_$session_wait
    where  event = 'buffer busy waits'
    union
    select sid,
           p3||' on '||p1||'.'||p2  wait
    from   sys.v_$session_wait
    where  event = 'buffer busy waits'
    union
    select sid,
           p3||' on '||p1||'.'||p2  wait
    from   sys.v_$session_wait
    where  event = 'buffer busy waits'
    union
    select sid,
           p3||' on '||p1||'.'||p2  wait
    from   sys.v_$session_wait
    where  event = 'buffer busy waits'
    union
    select sid,
           p3||' on '||p1||'.'||p2  wait
    from   sys.v_$session_wait
    where  event = 'buffer busy waits'
  )  w,
  sys.v_$session  s,
  sys.v_$sqltext  t
where
  s.sid = w.sid and
  t.address = s.sql_address
order by
  w.wait,
  t.address,
  t.piece
/

@restore_sqlplus_settings
