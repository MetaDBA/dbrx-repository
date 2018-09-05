-------------------------------------------------------------------------------
--
-- Script:	lgwr_stats.sql
-- Purpose:	to show if the log_buffer is well sized
-- For:		8.0 and 8.1
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Description: These statistics show whether the log_buffer is well sized.
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set termout off
column log_block_size new_value LogBlockSize
select
  max(lebsz) log_block_size
from
  sys.x_$kccle
where
  inst_id = userenv('Instance')
/
set termout on

column write_size format 99999999999999 heading "Average Log|Write Size"

select
  ceil(max(decode(name, 'redo blocks written', value))
      /max(decode(name, 'redo writes', value, 1)))
  * &LogBlockSize  write_size
from
  sys.v_$sysstat
/

column threshold  format 99999999999999 heading "Background|Write Theshold"

select
  least(ceil(value/&LogBlockSize/3) * &LogBlockSize, 1024*1024)  threshold
from
  sys.v_$parameter
where
  name = 'log_buffer'
/

column sync_cost_ratio format 990.00 heading "Sync Cost Ratio"

select
  (sum(decode(name, 'redo synch time', value)) / sum(decode(name, 'redo synch writes', value)))
  / (sum(decode(name, 'redo write time', value)) / sum(decode(name, 'redo writes', value)))
    sync_cost_ratio
from
  sys.v_$sysstat
where
  name in ('redo synch writes', 'redo synch time', 'redo writes', 'redo write time')
/

prompt
prompt If the sync cost ratio is approximately 1, then you can do nothing other
prompt than attempt to reduce your commit frequency and optimize log file writes
prompt at the operating system level. 
prompt
prompt If the ratio is higher than 1.5, then you may have an instance tuning problem worth investigating.
prompt If the log_buffer is too small, it can increase log file sync times indirectly via redo allocation
prompt latch contention. If so, in addition to the latch contention itself in V$LATCH, the above script
prompt would show that the average log write size is of the same order of magnitude as the background write
prompt threshold. If not, then increasing the log_buffer size is not likely to have a significant impact,
prompt but if anything it would in fact increase the average log file sync time rather than reduce it. 

@restore_sqlplus_settings
