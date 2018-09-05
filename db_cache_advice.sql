col size_for_estimate      form 999,999 heading "Est Size (MB)"
col base_physical_reads    form 999,999,999,999 heading "Base Phys Reads"
col actual_physical_reads  form 999,999,999,999 heading "Actual Phys Reads"
col physical_reads         form 999,999,999,999 heading "Projected Phys Reads"
col instance_number        form 9999            heading "Inst"

break on instance_number skip 1

ttitle center "DB Cache Sizing Advice                                 "   skip 2

select instance_number, size_for_estimate, round(size_factor,1) size_factor, physical_reads,
 base_physical_reads, actual_physical_reads
from dba_hist_db_cache_advice
 where snap_id =  (select max(snap_id) from dba_hist_db_cache_advice)
order by instance_number, size_factor
/

