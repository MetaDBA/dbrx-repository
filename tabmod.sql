def owner=&&1
col table_owner form a15
col table_name form a30
col pctchg form 999999
col last_analyzed form a18

select m.table_name, t.num_rows,
        round(100*(m.inserts + m.updates + m.deletes)/(t.num_rows+.01)) pctchg,
        m.inserts, m.updates, m.deletes, m.truncated, m.timestamp, t.last_analyzed
from sys.dba_tab_modifications m, dba_tables t
where m.table_owner = t.owner
and m.table_name = t.table_name
and m.table_owner like upper('&owner%')
order by m.table_owner, m.table_name;
