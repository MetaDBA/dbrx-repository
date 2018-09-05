select 'alter index ' || owner || '.' || index_name || ' rebuild nologging compute statistics;'
   from dba_indexes where table_name = upper('&1'); 
