REM /*Check Dictionary Cache*/

select 
  sum(gets) "Gets", sum(getmisses) "Misses",
  100 * (1-(sum(getmisses)/sum(gets)))
  "Dictionary Cache Hit Ratio"
from v$rowcache;

