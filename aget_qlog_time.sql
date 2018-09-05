set lines 132
col snap_ids format a15            heading "Snap IDs"
col times    format a20            heading "Date/Time"
col LogRead  format 99,999,999,999 heading Logical|Reads
col Execs    format 999,999,999    heading Executions
col Reads_Per format 999,999,999   heading Reads|/Exec
col Hash format 999999999999       heading SQL_ID

needs work
select snap_ids, times, LogRead, Execs, Reads_Per, Hash from
(select lag(s.snap_id,1,0) over (order by s.snap_id) || '-' || s.snap_id snap_ids, 
          to_char(lag(s.snap_time,1) over (order by s.snap_id), 'MM-dd hh24:mi') || '-' ||
          to_char(s.snap_time, 'hh24:mi') times,
           (e.buffer_gets - nvl((lag(e.buffer_gets,1,0) over (order by e.snap_id)),0))
                               LogRead,
                  (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0))
				Execs,
                  decode(e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)
                                     ,0, to_number(null)
                                     ,(e.buffer_gets - nvl((lag(e.buffer_gets,1,0) over (order by e.snap_id)),0)) /
                                      (e.executions - nvl((lag(e.executions,1,0) over (order by e.snap_id)),0)))
				Reads_Per,
                  e.sql_id Hash
       from wrh$_sqlstat e
	  , wrm$_snapshot s
	where e.sql_id = '&sql_id'
	and s.snap_id = e.snap_id
	and s.BEGIN_INTERVAL_TIME between &beg_time and &end_time) ss
where substr(ss.snap_ids,1,2) <> '0-'
order by ss.snap_ids
      ;

select s.snap_id, executions_delta, buffer_gets_delta, round(buffer_gets_delta/executions_delta) buff_per_exec,
	 disk_reads_delta, round(disk_reads_delta/executions_delta) phys_per_exec
from sys.wrh$_sqlstat e
	  , sys.wrm$_snapshot s
	where e.sql_id = '&sql_id'
	and s.snap_id = e.snap_id
	and s.BEGIN_INTERVAL_TIME between &beg_time and &end_time
order by s.snap_id;

select snap_id, executions_delta, buffer_gets_delta, disk_reads_delta
from sys.wrh$_sqlstat e
	where e.sql_id = '04qg4p77v9cad'
	and e.snap_id = 7578




7578 18 Oct 2007 17:00      1
7579 18 Oct 2007 18:00      1


              Snap Id      Snap Time      Sessions Curs/Sess
            --------- ------------------- -------- ---------
Begin Snap:      7578 18-Oct-07 17:00:55       107       7.1
  End Snap:      7579 18-Oct-07 18:00:07       110       7.0
   Elapsed:               59.20 (mins)

  Elapsed      CPU                  Elap per  % Total
  Time (s)   Time (s)  Executions   Exec (s)  DB Time    SQL Id
---------- ---------- ------------ ---------- ------- -------------
        36         36           15        2.4     1.7 04qg4p77v9cad
SELECT o.id, NVL(o.pid,:"SYS_B_00") pid, nvl(spo.name, nvl(m.main_name, o.name))
 name, o.type_id, o.status, site.sort_number, DECODE(m.object_id, null, :"SYS_B
_01", DECODE(site.object_id, null, :"SYS_B_02", status)) vstatus, NVL(spo.descr
iption, NVL(m.main_descr, o.descr)) descr FROM wam_object o, wam_site_profile_
