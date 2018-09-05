select 'ALTER TABLE "' || a.owner || '"."' || a.table_name ||
       '" MODIFY LOB ("' || a.column_name ||
       '") (STORAGE (PCTINCREASE 0));'
from   dba_lobs a, dba_segments b
where  b.pct_increase > 0
and    b.tablespace_name != 'SYSTEM'
and    b.owner NOT IN ('SYS', 'SYSTEM')
and    a.owner = b.owner
and    a.segment_name = b.segment_name
/

