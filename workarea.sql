col operation 	     form a18
col number_passes    form 9999     heading "Number|Passes"
col actual_mem_used  form 99,999.9 heading "Actual Mem|Used (M)"
col est_size         form 99,999.9 heading "Est |Size(M)"
col max_mem_used     form 99,999.9 heading "Max Mem|Used (M)"

SELECT to_number ( decode(sid, 65535 ,null,sid)) sid,
       sql_id ,
       operation_type operation , 
                 round ( expected_size/ 1024 / 1024, 1 ) est_size , 
                         round ( actual_mem_used/ 1024 / 1024 , 1) actual_mem_used ,
                         round ( max_mem_used/ 1024 / 1024, 1 ) max_mem_used , 
                         number_passes ,
                         round ( tempseg_size/ 1024 / 1024, 1 ) "TEMP SEG SIZE (M)" , 
                         round ( actual_mem_used/ 1024 / 1024 , 1) + round( tempseg_size / 1024/ 1024 , 1) "TOTAL (M)"            
FROM v$sql_workarea_active
WHERE sql_id = '8gn3q7k6h3y5n' 
ORDER BY 3 DESC;

