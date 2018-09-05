select a.name, to_char(a.value * (select b.value
        from v$parameter b
         where name = 'db_block_size'),'999,999,999') "Pool Size"
from v$parameter a
 where a.name like 'buffer_pool%';

select substr(owner,1,10) "OWNER", rpad(segment_type || '  ' || segment_name, 40, ' ')  "Object Name",
 buffer_pool "Pool",
 to_char(s.bytes,'999,999,999,999') "Size"
 from dba_segments s
where buffer_pool <> 'DEFAULT'
;

