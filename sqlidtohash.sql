select  hash_value from v$sql where sql_id = '&1'
and rownum = 1;

