set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col PhysRead format 99,999,999,999 heading Physical|Reads
col PhysPer  format 99,999,999,999 heading Reads|/Sec

select b.snap_id || '-' || e.snap_id snap_ids,
	  to_char(s.snap_time, 'MM-dd hh24:mi') || '-' ||
	  to_char(f.snap_time, 'hh24:mi') times,
           (sum(e.phyrds) - nvl(sum(b.phyrds),0))
                               PhysRead,
                  ((sum(e.phyrds) - nvl(sum(b.phyrds),0)) /
                                      (f.snap_time - s.snap_time)/86400)
                               PhysPer
       from stats$filestatxs  e
          , stats$filestatxs  b
	  , stats$snapshot s
	  , stats$snapshot f
      where b.dbid            = e.dbid
        and b.instance_number = e.instance_number
        and e.snap_id            = b.snap_id + 1
	and s.snap_id = b.snap_id
	and f.snap_id = e.snap_id
	and f.dbid = s.dbid
	and f.dbid = b.dbid
	and f.instance_number = s.instance_number
	and f.instance_number = b.instance_number
	and b.snap_id between &beg_snap and &end_snap
group by b.snap_id, e.snap_id, s.snap_time, f.snap_time
order by b.snap_id
      ;


