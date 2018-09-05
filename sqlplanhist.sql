COL id          FORMAT 999
COL parent_id   FORMAT 999 HEADING "PARENT"
COL operation   FORMAT a35 TRUNCATE
COL object_name FORMAT a30

def sqlid       = &&1

SELECT     id, parent_id, LPAD (' ', LEVEL - 1) || operation || ' ' ||
           options operation, object_name, cost
FROM       DBA_HIST_SQL_PLAN
WHERE      sql_id = '&sqlid'
START WITH id = 0
AND        sql_id ='&sqlid'
CONNECT BY PRIOR
           id = parent_id
AND        sql_id = '&sqlid' 
/

undef sqlid
