select to_char(a.bytes,'999,999,999') current_free
 from large_pool_free a
where a.sample_date = (select max(b.sample_date)
from large_pool_free b);

select to_char(min(bytes),'9,999,999,999') least_free,
to_char(avg(pool_size.value) - min(bytes),'9,999,999,999') most_used
 from large_pool_free, (select value from v$parameter
where name = 'large_pool_size') pool_size;