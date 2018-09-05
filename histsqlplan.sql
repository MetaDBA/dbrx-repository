set lines 140

select * from table(dbms_xplan.display_awr('&&sql_id'));

set lines 132

