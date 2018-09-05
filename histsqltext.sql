def sqlid=&1

col hv		heading "sql_id"
col text        heading 'SQL Statement Text'    format          A65

select  a.sql_id     hv,
        a.sql_text text
from    dba_hist_sqltext a
where   a.sql_id = '&sqlid'
and rownum = 1
/

undef sqlid

