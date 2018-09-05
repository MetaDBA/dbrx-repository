select 'alter index ' || owner || '.' || index_name || ' rebuild nologging 
 tablespace ' || owner || ';'
   from dba_indexes where status = 'UNUSABLE';
