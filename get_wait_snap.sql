set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col event format a30 		   heading Wait|Event
col Seconds_Waited format 999,999 heading Seconds|Waited

select snap_ids, times, Event, Seconds_Waited from
(select lag(s.snap_id,1,0) over (order by s.snap_id) || '-' || s.snap_id snap_ids, 
	  to_char(lag(s.snap_time,1) over (order by s.snap_id), 'MM-dd hh24:mi') || '-' ||
	  to_char(s.snap_time, 'hh24:mi') times,
	   e.event  Event,
           lpad(to_char(((e.time_waited_micro - nvl((lag(e.time_waited_micro,1,0) over (order by e.snap_id)),0))/1000000)
                               ,'999,999'),8) Seconds_Waited 
       from stats$system_event e
	  , stats$snapshot s
      where e.event      = '&event_name'
	and s.snap_id = e.snap_id
	and s.snap_id between &beg_snap and &end_snap) ss
where substr(ss.snap_ids,1,2) <> '0-'
order by ss.snap_ids
      ;


