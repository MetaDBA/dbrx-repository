select sql_text from  V$SQLTEXT WHERE
address=(select PREV_SQL_ADDR  from v$session
   where sid = &1)
order by piece;
