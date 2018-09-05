def sql_id=&&1

SELECT * FROM table (
DBMS_XPLAN.DISPLAY_CURSOR('&&sql_id'));

undef sql_id 
