col logical form 999,999,999,999,999
col physical form 999,999,999,999,999
col segment_name form a30
col owner form a12

SELECT t.buffer_pool, t.owner, t.segment_name, lr.value logical, pr.value physical,
 1 - (pr.value / (lr.value+pr.value+0.00001)) hit_ratio
FROM (SELECT owner,object_name,value FROM v$segment_statistics
WHERE statistic_name='logical reads') lr,
(SELECT owner,object_name,value FROM v$segment_statistics
WHERE statistic_name='physical reads') pr,
dba_segments t
WHERE lr.owner=pr.owner AND lr.object_name=pr.object_name
  AND lr.owner=t.owner AND lr.object_name=t.segment_name
  and t.buffer_pool <> 'DEFAULT'
ORDER BY t.buffer_pool, t.owner, t.segment_name
/
