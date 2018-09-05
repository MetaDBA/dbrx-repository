-- col_stats
-- Martin Widlake mdw 21/03/2003
-- MDW 11/12/09 enhanced to include more translations of low_value/high_value
-- pilfered from Gary Myers blog
-- MDW 20/02/10 added in the handling of timestamps.
col owner        form a6 word wrap
col table_name   form a15 word wrap
col column_name  form a22 word wrap
col data_type    form a12
col M            form a1
col num_vals     form 99999,999
col dnsty        form 0.9999
col num_nulls    form 99999,999
col low_v        form a30
col low_v2       form a18
col hi_v         form a30
col data_type    form a10
col low_value    form a25
col high_value   form a25
set lines 110
break on owner nodup on table_name nodup
spool col_stats.lst
select --owner
--      ,table_name
      column_name
      ,data_type
      ,decode (nullable,'N','Y','N')  M
      ,num_distinct num_vals
      ,num_nulls
      ,density dnsty
,decode(substr(data_type,1,9) -- as there are several timestamp types
  ,'NUMBER'       ,to_char(utl_raw.cast_to_number(low_value))
  ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(low_value))
  ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(low_value))
  ,'BINARY_DO',to_char(utl_raw.cast_to_binary_double(low_value))
  ,'BINARY_FL' ,to_char(utl_raw.cast_to_binary_float(low_value))
  ,'DATE',rtrim(
               to_char(100*(to_number(substr(low_value,1,2),'XX')-100)
                      + (to_number(substr(low_value,3,2),'XX')-100),'fm0000')||'-'||
               to_char(to_number(substr(low_value,5,2),'XX'),'fm00')||'-'||
               to_char(to_number(substr(low_value,7,2),'XX'),'fm00')||' '||
               to_char(to_number(substr(low_value,9,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(low_value,11,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(low_value,13,2),'XX')-1,'fm00'))
  ,'TIMESTAMP',rtrim(
               to_char(100*(to_number(substr(low_value,1,2),'XX')-100)
                      + (to_number(substr(low_value,3,2),'XX')-100),'fm0000')||'-'||
               to_char(to_number(substr(low_value,5,2),'XX'),'fm00')||'-'||
               to_char(to_number(substr(low_value,7,2),'XX'),'fm00')||' '||
               to_char(to_number(substr(low_value,9,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(low_value,11,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(low_value,13,2),'XX')-1,'fm00')
              ||'.'||to_number(substr(low_value,15,8),'XXXXXXXX')  )
       ) low_v
,decode(substr(data_type,1,9) -- as there are several timestamp types
  ,'NUMBER'       ,to_char(utl_raw.cast_to_number(high_value))
  ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(high_value))
  ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(high_value))
  ,'BINARY_DO',to_char(utl_raw.cast_to_binary_double(high_value))
  ,'BINARY_FL' ,to_char(utl_raw.cast_to_binary_float(high_value))
  ,'DATE',rtrim(
               to_char(100*(to_number(substr(high_value,1,2),'XX')-100)
                      + (to_number(substr(high_value,3,2),'XX')-100),'fm0000')||'-'||
               to_char(to_number(substr(high_value,5,2),'XX'),'fm00')||'-'||
               to_char(to_number(substr(high_value,7,2),'XX'),'fm00')||' '||
               to_char(to_number(substr(high_value,9,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(high_value,11,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(high_value,13,2),'XX')-1,'fm00'))
  ,'TIMESTAMP',rtrim(
               to_char(100*(to_number(substr(high_value,1,2),'XX')-100)
                      + (to_number(substr(high_value,3,2),'XX')-100),'fm0000')||'-'||
               to_char(to_number(substr(high_value,5,2),'XX'),'fm00')||'-'||
               to_char(to_number(substr(high_value,7,2),'XX'),'fm00')||' '||
               to_char(to_number(substr(high_value,9,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(high_value,11,2),'XX')-1,'fm00')||':'||
               to_char(to_number(substr(high_value,13,2),'XX')-1,'fm00')
              ||'.'||to_char(to_number(substr(low_value,15,8),'XXXXXXXX')))
  ,  high_value
       ) hi_v
,low_value,high_value
from dba_tab_columns
where owner      like upper('&tab_own')
and   table_name like upper(nvl('&tab_name','WHOOPS')||'%')
ORDER BY owner,table_name,COLUMN_ID
/
clear colu
spool off
clear breaks

