set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col Stat  format a25		   heading Stat
col Stat_Value format 999,999,999,999 heading Value


select snap_ids, times, Stat, Stat_Value from
(select lag(s.snap_id,1,0) over (order by s.snap_id) || '-' || s.snap_id snap_ids, 
          to_char(lag(s.snap_time,1) over (order by s.snap_id), 'MM-dd hh24:mi') || '-' ||
          to_char(s.snap_time, 'hh24:mi') times,
	   e.name Stat,
           lpad(to_char(((e.value - nvl((lag(e.value,1,0) over (order by e.snap_id)),0)))
                               ,'999,999,999,999'),16)  Stat_Value
       from stats$sysstat e
	  , stats$snapshot s
	where e.name       = '&stat_name'
	and s.snap_id = e.snap_id
        and s.instance_number in (select instance_number from v$instance) 
	and s.snap_time between (sysdate - &beg_time_days_ago) and (sysdate - &end_time_days_ago)) ss
where substr(ss.snap_ids,1,2) <> '0-'
order by ss.snap_ids
      ;


