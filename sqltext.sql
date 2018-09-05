select sql_text from  V$SQLTEXT WHERE
address=(select sql_address from v$session
   where sid = &1)
order by piece;
