col mbytes_processed          form 999,999,999         heading "MB    |Processed"
col estd_extra_bytes_rw       form 999,999,999,999,999
col estd_pga_cache_hit_percentage form 999 heading "Estd PGA cache|hit percentage"
col pga_target_factor         form 9.9             heading "PGA Tgt|Factor"
col pga_target_for_estimate   form 999,999,999,999
col instance_number        form 9999            heading "Inst"

break on instance_number skip 1

ttitle center "PGA Target Advice                 "  skip 2

select instance_number, pga_target_for_estimate, round(pga_target_factor,1) pga_target_factor,
 round(bytes_processed/1048576) mbytes_processed, estd_extra_bytes_rw, estd_pga_cache_hit_percentage, estd_overalloc_count
from dba_hist_pga_target_advice
 where snap_id =  (select max(snap_id) from dba_hist_pga_target_advice)
order by instance_number, pga_target_factor
/

