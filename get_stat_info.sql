set lines 90
col stats format a90 heading "Snaps        Date/Time       Stat                          Value"

select b.snap_id || '-' || e.snap_id || ' ' ||
	  to_char(s.snap_time, 'MM-dd hh24:mi') || '-' ||
	  to_char(f.snap_time, 'hh24:mi') ||  '  ' ||
	   rpad(e.name,25) ||
           lpad(to_char(((e.value - nvl(b.value,0)))
                               ,'999,999,999,999'),16)  stats
       from stats$sysstat e
          , stats$sysstat b
	  , stats$snapshot s
	  , stats$snapshot f
      where b.dbid            = e.dbid
        and b.instance_number = e.instance_number
        and b.name            = e.name      
        and e.snap_id            = b.snap_id + 1
	and e.name       = '&stat_name'
	and s.snap_id = b.snap_id
	and f.snap_id = e.snap_id
	and b.snap_id between &beg_snap and &end_snap
order by b.snap_id
      ;


