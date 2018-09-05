REM /* Check Library Cache */

select sum(pins) "Requests",
sum(reloads) "Reloads",
100 * (1-(sum(reloads)/sum(pins))) "Library Cache Hit Ratio"
from v$librarycache;

select sum(gets) "Gets",
sum(gethits) "Gethits",
sum(gethits)*100/sum(gets) "Library Cache GetHit Ratio"
from v$librarycache;
