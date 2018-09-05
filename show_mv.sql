col object_name for a40
col username for a10
set echo on linesize 140 pagesize 105
select owner,mview_name from dba_mviews;
select log_owner,master,log_table from dba_snapshot_logs;
select l.inst_id,o.owner, o.object_name , username, s.sid
 from gv$lock l, dba_objects o, gv$session s
 where o.object_id=l.id1 and
 l.inst_id = s.inst_id and
 l.type='JI' and
 l.lmode=6 and
 s.sid=l.sid and
 o.object_type='TABLE';

