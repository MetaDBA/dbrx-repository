SELECT to_char(100 * (1 - p.hard_parses/e.executions), '999999999.99')  "Noparse Ratio"
  FROM
 (select value hard_parses
     from v$sysstat 
      where name = 'parse count (hard)' ) p, 
 (select value executions
     from v$sysstat 
      where name = 'execute count' ) e;
