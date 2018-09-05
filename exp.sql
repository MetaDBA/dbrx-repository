REM
REM explain.sql
REM ===========
REM
REM This script displays the execution plan for a specified statement_id
REM in a visual format that makes the tree structure of execution plans
REM evident.
REM
REM Modification history:
REM   06/10/94  RJS  Created.
REM

SET VERIFY OFF

REM ACCEPT stmt_id CHAR PROMPT "Enter statement_id: "

COL id          FORMAT 999
COL parent_id   FORMAT 999 HEADING "PARENT"
COL operation   FORMAT a35 TRUNCATE
COL object_name FORMAT a30

SELECT     id, parent_id, LPAD (' ', LEVEL - 1) || operation || ' ' ||
           options operation, object_name, cost
FROM       plan_table
WHERE      statement_id = 'tsdb'
START WITH id = 0
AND        statement_id = 'tsdb'
CONNECT BY PRIOR
           id = parent_id
AND        statement_id = 'tsdb';


REM statement_id lines were statement_id = '&stmt_id' instead of 'tsdb'
