set linesize 130 pagesize 1000

col name for a45 trunc
col ctl_change# for 9999999999999999
col df_change# for 9999999999999999

select a.file#,
       a.name,
        a.checkpoint_change# ctl_change#,
        b.checkpoint_change# df_change#,
        b.checkpoint_time,
        case
        when ((a.checkpoint_change# - b.checkpoint_change#) = 0) then 'Startp normal'
        when ((a.checkpoint_change# - b.checkpoint_change#) > 0) then 'Media recovery'
        when ((a.checkpoint_change# - b.checkpoint_change#) < 0) then 'Old controlfile'
        else 'Unknown'
        end status
from    v$datafile a,  -- controlfile
        v$datafile_header b -- datafile scn
where a.file# = b.file#;
