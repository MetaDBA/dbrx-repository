def schema=&1

select 'create synonym ' || table_name || ' for &schema..' || table_name || ';'
from dba_tables where owner = upper('&schema');

undef schema
