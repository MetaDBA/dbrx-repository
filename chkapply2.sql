col orderer form 9 noprint
col titler form a28 heading " "
col completion_time form a25  heading "Time Archived on Primary"
col sequence form 999999999 heading "Sequence#"

select 1 orderer, 'Last Primary Archivelog' titler, max(sequence#) sequence, max(completion_time) completion_time
from v$archived_log 
where archived='YES' 
and creator = 'ARCH'
union
select 2 orderer, 'Last Log Applied on Standby' titler, sequence#, completion_time 
from v$archived_log l, dbrx.DBRX_METRIC_1_DATA d
where l.sequence# = d.STANDBY_LAST_LOG_NUMBER  
and creator = 'ARCH'
order by orderer
;

