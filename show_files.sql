set linesize 100 pagesize 1000 
col name for a70


select name from v$controlfile
union
select name from v$datafile
union
select name from v$tempfile
union
select member name from v$logfile
union
select filename name from v$block_change_tracking;

