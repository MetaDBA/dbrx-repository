select 'alter index ' || index_owner || '.' || index_name || ' rebuild partition ' ||
partition_name || ';'
   from dba_ind_partitions where status = 'UNUSABLE';

