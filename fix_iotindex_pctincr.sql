select 'alter table ' || owner || '.' || table_name || ' overflow storage(pctincrease 0);'
from dba_tables t
where exists
(select 'x' from  dba_tables iot
where iot.iot_name = t.table_name
and iot.owner = t.owner
and iot.pct_increase <> 0
and owner <> 'SYS');
