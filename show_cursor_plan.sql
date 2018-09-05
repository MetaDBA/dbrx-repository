set echo on pagesize 1000 linesize 140
select * from table(dbms_xplan.display_cursor('&sql_id',null,'iostats'));
select * from table(dbms_xplan.display_cursor('&sql_id',0));
/
