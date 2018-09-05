select substr(segment_name,1,30) "segment", substr(owner, 1, 12),
 substr(tablespace_name,1,15) "tablespace",
 to_char(sum(bytes),'999,999,999,999')
    from dba_segments
    group by segment_name, owner, substr(tablespace_name,1,15)
        having  substr(tablespace_name,1,15) = 'DELTA_TABLES'
  order by to_char(sum(bytes),'999,999,999,999');
