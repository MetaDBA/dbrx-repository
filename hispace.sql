set echo off

select * from dbname;

select 
substr(table_name,1,22) "Table_name",
 substr(tablespace_name,1,15) "Tablespace",
 lpad(substr(pct_free || ' / ' || pct_used,1,9),9) "PctFr/Usd",
 num_rows "  Num_Rows",
 blocks "    Blocks",
 empty_blocks " EmptyBlks",
 lpad(substr(avg_row_len,1,5),5) "AvRow",
 lpad(substr(avg_space,1,5),7) "AvSpace"
 from dba_tables
  where avg_space > 3000
and owner not in ('SYS', 'SYSTEM')
and blocks > 8
and num_rows > 0
order by avg_space;