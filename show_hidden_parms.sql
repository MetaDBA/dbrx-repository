set linesize 120
col description for a40
col value for a10
col name for a40
SELECT
  x.ksppinm name,
  y.ksppstvl VALUE,
  ksppdesc description
FROM x$ksppi x,
  x$ksppcv y
WHERE x.inst_id = userenv('Instance')
 AND y.inst_id = userenv('Instance')
 AND x.indx = y.indx 
ORDER BY 1
/

