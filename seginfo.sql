set heading on
def segment_name=&&1

col owner               format a15
col segment_name        format a30
col MB			format 999,999,999.9
col segment_type 	format a15
col blocks              format 999999999 heading "Blocks"

select owner, segment_name, blocks,
round(bytes)/1048576 MB,
tablespace_name, segment_type
from dba_segments
where segment_name = upper('&segment_name');
