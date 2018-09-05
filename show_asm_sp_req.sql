set echo on
SELECT SUM(bytes)/(1024*1024*1024) FROM V$DATAFILE;

SELECT SUM(bytes)/(1024*1024*1024) FROM V$LOGFILE a, V$LOG b
WHERE a.group#=b.group#;

SELECT SUM(bytes)/(1024*1024*1024) FROM V$TEMPFILE
WHERE status='ONLINE';

/* 

o For disk groups using external redundancy, every 100 GB of space needs 1 MB of extra shared pool plus 2 MB.

o For disk groups using normal redundancy, every 50 GB of space needs 1 MB of extra shared pool plus 4 MB.

o For disk groups using high redundancy, every 33 GB of space needs 1 MB of extra shared pool plus 6 MB.
 
*/
