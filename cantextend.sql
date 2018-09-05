REM 'Segments with insufficient room for Next Extent'

select substr(a.tablespace_name,1,10) "Tablespace",
 substr(owner,1,10) "Owner",
 substr(segment_name,1,30) "Segment which cannot extend",
 substr(segment_type,1,12) "Segment Type",
 to_char((next_extent / 1024), '9,999,999') || 'K' "Next Extent",
 to_char((max_free_bytes / 1024), '9,999,999') || 'K' "  Max Free"
from sys.dba_segments a,  
  (select tablespace_name,max(bytes) max_free_bytes
                from sys.dba_free_space
               group by tablespace_name) f
 where not exists
 (select 'x' from sys.dba_free_space b
 where a.tablespace_name = b.tablespace_name
 and b.bytes >= a.next_extent)
 and f.tablespace_name = a.tablespace_name
 and a.tablespace_name not in
(select d.tablespace_name from dba_data_files d
 where autoextensible = 'YES')
 union
select substr(a.tablespace_name,1,10) "Tablespace",
 ' ' "Owner",
 'No Free Space in Tablespace' "Segment which cannot extend",
 ' ',
 ' ',
 '       0'
 from dba_tablespaces a
where a.tablespace_name not in
(select b.tablespace_name from dba_free_space b)
and contents <> 'TEMPORARY'
and a.tablespace_name not in
(select d.tablespace_name from dba_data_files d
 where autoextensible = 'YES')
 order by "Tablespace", "Segment which cannot extend";
