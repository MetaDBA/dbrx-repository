set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col PhysRead format 99,999,999,999 heading Physical|Reads
col Execs    format 999,999,999    heading Executions
col Reads_Per format 999,999,999   heading Reads|perExec
col Hash format 999999999999       heading HashValue


select snap_ids, times, PhysRead, Execs, Reads_Per, Hash from
(select lag(s.snap_id,1,0) over (order by s.snap_id) || '-' || s.snap_id snap_ids, 
          to_char(lag(s.snap_time,1) over (order by s.snap_id), 'MM-dd hh24:mi') || '-' ||
          to_char(s.snap_time, 'hh24:mi') times,
           (e.disk_reads - nvl((lag(e.disk_reads,1,0) over (order by e.snap_id)),0))
                               PhysRead,
                  (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0))
				Execs,
                  decode(e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)
                                     ,0, to_number(null)
                                     ,(e.disk_reads - nvl((lag(e.disk_reads,1,0) over (order by e.snap_id)),0)) /
                                      (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)))
				Reads_Per,
                  e.hash_value Hash
       from stats$sql_summary e
	  , stats$snapshot s
	where e.hash_value = '&hash_value'
	and s.snap_id = e.snap_id
        and s.instance_number in (select instance_number from v$instance)
	and s.snap_time between (sysdate - &beg_time_days_ago) and (sysdate - &end_time_days_ago)) ss
where substr(ss.snap_ids,1,2) <> '0-'
order by ss.snap_ids
      ;


