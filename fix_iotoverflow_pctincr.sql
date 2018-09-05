select 'alter table ' || owner || '.' || table_name || ' storage(pctincrease 0);'
from dba_tables t
where exists
(select 'x' from  dba_indexes i
where i.table_name = t.table_name
and i.owner = t.owner
and i.pct_increase <> 0
and owner <> 'SYS');

