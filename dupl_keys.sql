def table_name=&&1
def column_name=&&2

select * 
from &table_name 
where &column_name in (select &column_name from &table_name group by &column_name having count(*) > 1);


REM To actually delete the duplicate rows:
REM delete from table_name
REM where rowid not in (select min(rowid) from table_name group by column_name)
REM and column_name in (select column_name from table_name group by column_name having count(*) > 1);

/* Another option:
select * from table_name where rowid in
(select rowid from table_name
minus 
select min(rowid) from table_name
group by column_name);

delete from table_name where rowid in
(select rowid from table_name
minus 
select min(rowid) from table_name
group by column_name);
*/
