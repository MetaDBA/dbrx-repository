col shared_pool_size_for_estimate      form 999,999 heading "Est SP Size (MB)"
col estd_lc_time_saved                 form 999,999,999,999 heading "Est LC Time Saved"
col instance_number        form 9999            heading "Inst"

break on instance_number skip 1
ttitle center "Shared Pool Sizing Advice                           "  skip 2

select instance_number, shared_pool_size_for_estimate, round(shared_pool_size_factor,1) size_factor,
 estd_lc_size "Est LC Size (MB)",
 estd_lc_time_saved, round(estd_lc_time_saved_factor,2) estd_lc_time_saved_factor
from dba_hist_shared_pool_advice
 where snap_id =  (select max(snap_id) from dba_hist_shared_pool_advice)
order by instance_number, shared_pool_size_factor
/

