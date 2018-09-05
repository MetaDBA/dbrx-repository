select 
   segment_name           table_name,	   
   sum(bytes)/(1024*1024) table_size_meg 
from   dba_extents 
where  segment_type='TABLE' 
and  segment_name =upper('&&table')
and owner =upper('&&owner')
group by segment_name;
