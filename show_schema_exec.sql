set linesize 140
select substr(sql_text, 1,40), sum(sorts/executions)
from v$sqlarea where sorts>0 and executions >0 and sorts/executions>1
and parsing_schema_name= upper('&schema')
group by substr(sql_text, 1,40) order by 2 asc;

