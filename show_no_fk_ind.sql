
SELECT * FROM (
SELECT c.table_name, cc.column_name, cc.position column_position
FROM   dba_constraints c, dba_cons_columns cc
WHERE  c.constraint_name = cc.constraint_name
AND    c.constraint_type = 'R' and c.owner = upper('&owner')
MINUS
SELECT i.table_name, ic.column_name, ic.column_position
FROM   dba_indexes i, dba_ind_columns ic
WHERE  i.index_name = ic.index_name and i.table_owner = upper('&&owner')
)
ORDER BY table_name, column_position;
