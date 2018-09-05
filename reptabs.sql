col segment format a30 heading "Segment"
col bytes format 9,999,999,999 heading "        Bytes"
col tablespace format a20 heading "Tablespace"

select segment_name segment,
	to_char(bytes,'9,999,999,999') bytes,
	tablespace_name tablespace
 from dba_segments
 where (segment_type = 'TABLE' and segment_name between 'DEF$_AQCALL' and 'DEF$_AQERROR')
 or (segment_type = 'LOBSEGMENT' and segment_name in 
	(select segment_name from dba_lobs
	 where table_name between 'DEF$_AQCALL' and 'DEF$_AQERROR'));




