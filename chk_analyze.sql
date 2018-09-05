select 'table', decode( num_rows, null, 'NO', 'YES' ) from 
    dba_tables where table_name = 'WORKFLOW_T'
      union all
    select 'index', decode( num_rows, null, 'NO', 'YES' ) from dba_indexes 
    where table_name = 'WORKFLOW_T'
      union all
    select 'histograms', decode( count(*), 0, 'NO', 'YES' ) from 
    dba_tab_histograms where table_name = 'WORKFLOW_T' and rownum = 1
;


