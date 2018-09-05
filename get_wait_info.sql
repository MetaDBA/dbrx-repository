set lines 90
col stats format a90 heading "Snaps        Date/Time       Event                         Seconds Waited"

select b.snap_id || '-' || e.snap_id || ' ' ||
	  to_char(s.snap_time, 'MM-dd hh24:mi') || '-' ||
	  to_char(f.snap_time, 'hh24:mi') ||  '  ' ||
	   rpad(e.event,25) ||
           lpad(to_char(((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000)
                               ,'999,999'),8)  stats
       from stats$system_event e
          , stats$system_event b
	  , stats$snapshot s
	  , stats$snapshot f
      where b.dbid            = e.dbid
        and b.instance_number = e.instance_number
        and b.event           = e.event     
        and e.snap_id            = b.snap_id + 1
	and e.event      = '&event_name'
	and s.snap_id = b.snap_id
	and f.snap_id = e.snap_id
	and b.snap_id between &beg_snap and &end_snap
order by b.snap_id
      ;


