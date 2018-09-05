col bytes form 999,999,999,999
col segment_name form a30
col owner form a15

select owner, segment_name, bytes
from dba_segments
where tablespace_name = upper('&1')
order by bytes;
