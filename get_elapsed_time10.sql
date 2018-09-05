set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col Elapsed  format 99,999,999,999 heading Elapsed|Times
col Execs    format 999,999,999    heading Executions
col Elaps_Per format 999,999.99   heading Secs|/Exec
col Hash format 999999999999       heading OldHashValue


select snap_ids, times, Elapsed, Execs, Elaps_Per, Hash from
(select lag(s.snap_id,1,0) over (order by s.snap_id) || '-' || s.snap_id snap_ids, 
          to_char(lag(s.snap_time,1) over (order by s.snap_id), 'MM-dd hh24:mi') || '-' ||
          to_char(s.snap_time, 'hh24:mi') times,
           round(((e.elapsed_time - nvl((lag(e.elapsed_time,1,0) over (order by e.snap_id)),0))/1000000),2)
                               Elapsed,
                  (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0))
				Execs,
                  round((decode(e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)
                                     ,0, to_number(null)
                                     ,(e.elapsed_time - nvl((lag(e.elapsed_time,1,0) over (order by e.snap_id)),0)) /
                                      (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)))/1000000),2)
				Elaps_Per,
                  e.old_hash_value Hash
       from stats$sql_summary e
	  , stats$snapshot s
	where e.old_hash_value = '&old_hash_value'
	and s.snap_id = e.snap_id
        and s.instance_number in (select instance_number from v$instance)
	and s.snap_time between (sysdate - &beg_time_days_ago) and (sysdate - &end_time_days_ago)) ss
where substr(ss.snap_ids,1,2) <> '0-'
order by ss.snap_ids
      ;


