  SELECT substr(sql_text,1,40) "SQL", 
  	 count(*) ,
       to_char(sum(sharable_mem),'999,999,999') "Sum Mem Used", 
	 sum(executions) "TotExecs"
    FROM v$sqlarea
   WHERE executions < 5
   GROUP BY substr(sql_text,1,40)
  HAVING count(*) > 30
   ORDER BY 2
  ;

