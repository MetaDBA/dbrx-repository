select count(*)    "cCHILD"
,      sum(GETS)   "sGETS"
,      sum(MISSES) "sMISSES"
,      sum(SLEEPS) "sSLEEPS" 
from v$latch_children 
where name = 'cache buffers chains'
order by 4, 1, 2, 3;
