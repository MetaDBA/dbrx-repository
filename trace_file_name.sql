-- Script:	trace_file_name.sql
-- Purpose:	to get the name of the current trace file
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Synopsis:	@trace_file_name
--
--		  OR
--
--		set termout off
--		@trace_file_name
--		set termout on
--		... &Trace_Name ...
--
-- Description:	This script gets the name of the trace file for the current
--		session.  It can be used interactively, or from other scripts.
--		The name is saved in the SQL*Plus define &Trace_Name.
--
--		There are three versions of the query below, because the trace
--		files are named differently depending on the platform. The
--		two incorrect versions should be commented out or deleted.
--
-------------------------------------------------------------------------------

column trace_file_name new_value Trace_Name
column trace_file_zipped new_value Trace_Zipped noprint

/* select
  d.value || '/ora_' || p.spid || '.trc' trace_file_name,
  d.value || '/ora_' || p.spid || '.trc.gz' trace_file_zipped
from
  ( select
      p.spid
    from
      sys.v_$mystat m,
      sys.v_$session s,
      sys.v_$process p
    where
      m.statistic# = 1 and
      s.sid = m.sid and
      p.addr = s.paddr
  ) p,
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'user_dump_dest'
  ) d
/
*/

select
  d.value||'/'||lower(rtrim(i.instance, chr(0)))||'_ora_'||p.spid||'.trc' trace_file_name,
  d.value||'/'||lower(rtrim(i.instance, chr(0)))||'_ora_'||p.spid||'.trc.gz' trace_file_zipped
from
  ( select
      p.spid
    from
      sys.v_$mystat m,
      sys.v_$session s,
      sys.v_$process p
    where
      m.statistic# = 1 and
      s.sid = m.sid and
      p.addr = s.paddr
  ) p,
  ( select
      t.instance
    from
      sys.v_$thread  t,
      sys.v_$parameter  v
    where
      v.name = 'thread' and
      (
        v.value = 0 or
        t.thread# = to_number(v.value)
      )
  ) i,
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'user_dump_dest'
  ) d
/

/* select
  d.value || '\ora' || lpad(p.spid, 5, '0') || '.trc' trace_file_name,
  d.value || '\ora' || lpad(p.spid, 5, '0') || '_trc.gz' trace_file_zipped
from
  ( select
      p.spid
    from
      sys.v_$mystat m,
      sys.v_$session s,
      sys.v_$process p
    where
      m.statistic# = 1 and
      s.sid = m.sid and
      p.addr = s.paddr
  ) p,
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'user_dump_dest'
  ) d
/
*/

clear columns
