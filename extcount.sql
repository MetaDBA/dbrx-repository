select substr(extents,1,7) "Extents",
	substr(tablespace_name,1,10) "Tablespace",
	substr(segment_name,1,30) "Segment",
	substr(segment_type,1,5) "Type",
	initial_extent "Init_Extnt",
	next_extent "Next_Extnt",
	substr(owner,1,10) "Owner"
from dba_segments
where extents > 100
and owner <> 'SYS' and owner <> 'SYSTEM'
order by extents desc;
