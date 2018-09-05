select 'alter index ' || owner || '.' || index_name || ' rebuild ;'
   from dba_indexes where status = 'UNUSABLE';
