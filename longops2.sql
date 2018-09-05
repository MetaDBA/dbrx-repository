select username, elapsed_seconds, time_remaining, sql_text
   from v$session_longops, v$sqlarea
   where sql_address = address
   and sofar < totalwork;

