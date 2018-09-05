def sql_id=&&1

SELECT * FROM table (
DBMS_XPLAN.DISPLAY_CURSOR('&&sql_id',null,'IOSTATS'));

undef sql_id 
