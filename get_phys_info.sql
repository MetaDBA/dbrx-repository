set lines 90

select b.snap_id || '-' || e.snap_id || ' ' ||
	  to_char(s.snap_time, 'MM-dd hh24:mi') || '-' ||
	  to_char(f.snap_time, 'hh24:mi') || 
           lpad(to_char((e.disk_reads - nvl(b.disk_reads,0))
                               ,'99,999,999,999'),15) ||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999'),14) || 
                  lpad(to_char(decode(e.executions - nvl(b.executions,0)
                                     ,0, to_number(null)
                                     ,(e.disk_reads - nvl(b.disk_reads,0)) /
                                      (e.executions - nvl(b.executions,0)))
                               ,'999,999,999'), 15) || '  ' ||
                  e.hash_value "PhysReadExecRead/ExecHashValue"
       from stats$sql_summary e
          , stats$sql_summary b
	  , stats$snapshot s
	  , stats$snapshot f
      where b.dbid            = e.dbid
        and b.instance_number = e.instance_number
        and b.hash_value      = e.hash_value
        and e.snap_id            = b.snap_id + 1
	and e.hash_value = '&hash_value'
        and e.executions         > nvl(b.executions,0)
	and s.snap_id = b.snap_id
	and f.snap_id = e.snap_id
	and b.snap_id between &beg_snap and &end_snap
order by b.snap_id
      ;


