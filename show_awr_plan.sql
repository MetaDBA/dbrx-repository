set pagesize 300 linesize 200 trimspool on
select * from table(dbms_xplan.display_awr('&SQL_ID',NULL,NULL,'advanced'));
