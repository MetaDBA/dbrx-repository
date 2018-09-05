set long 1000000

select sql_fulltext from  V$SQL WHERE
sql_id = '&1'
;
