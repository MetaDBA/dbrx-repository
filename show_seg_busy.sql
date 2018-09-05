set linesize 140
select * from (
select owner,object_name,subobject_name,object_type,tablespace_name,value
from v$segment_statistics
where statistic_name ='buffer busy waits'
order by value DESC)
where rownum <= 10;
