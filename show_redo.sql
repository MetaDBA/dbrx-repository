set linesize 140 pagesize 100
col member for a60 trunc
select inst_id,group#,status,member,is_recovery_dest_file from gv$logfile order by 2 desc;
select * from gv$log order by status;
-- real files - see http://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:18183400346178753
select group#,status,member,is_recovery_dest_file from v$logfile order by 2 desc;
select * from v$log order by thread#,group#;
select  instance_name, b.thread#,b.group#, member from gv$instance a, v$log b, v$logfile c  where b.thread#=a.inst_id  and b.group#=c.group# order by instance_name, group# asc;

