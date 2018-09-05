select sql_id  from v$sql where hash_value = '&1'
and rownum = 1;

