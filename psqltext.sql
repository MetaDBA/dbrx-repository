select sql_text from  V$SQLTEXT WHERE
hash_value=(select prev_hash_value from v$session
   where sid = &1)
order by piece;
