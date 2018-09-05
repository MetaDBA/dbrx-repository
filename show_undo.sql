col mbactive for '999999'
select a.tablespace_name,a.mbactive,b.maxsizemb
from   (select ue.tablespace_name,sum(ue.bytes)/(1024*1024) mbactive
       from   dba_undo_extents ue
       where  ue.segment_name in (select name from v$rollname)
       and    ue.status ='ACTIVE'
       group  by  ue.tablespace_name) a
     ,
      (select df.tablespace_name
            , sum((df.maxbytes/1024)/1024) MaxsizeMb
      from dba_data_files df
      where tablespace_name = (select upper(value) from v$parameter
where name='undo_tablespace' )
      group by tablespace_name) b
where a.tablespace_name = b.tablespace_name
/


SET LINESIZE 163
SET PAGESIZE 9999

COLUMN instance_name  FORMAT a8      HEADING 'Instance'
COLUMN roll_name      FORMAT a13     HEADING 'Rollback Name'
COLUMN userID         FORMAT a20     HEADING 'OS/Oracle'
COLUMN usercode       FORMAT a12     HEADING 'SID/Serial#'
COLUMN program        FORMAT a31     HEADING 'Program'
COLUMN machine        FORMAT a32     HEADING 'Machine'
COLUMN status         FORMAT a8      HEADING 'Status'

SELECT
    i.instance_name                 instance_name
  , r.name                          roll_name
  , s.osuser || '/' ||  s.username  userID
  , s.sid || '/' || s.serial#       usercode
  , s.program                       program
  , s.status                        status
  , s.machine                       machine
FROM
                     gv$session  s
    INNER JOIN       gv$instance i ON (s.inst_id = i.inst_id)
    INNER JOIN       gv$lock     l ON (s.sid = l.sid AND i.inst_id = l.inst_id)
    LEFT OUTER JOIN  sys.undo$   r ON (TRUNC(l.id1/65536) = r.us#)
WHERE
      l.type  = 'TX'
  AND l.lmode = 6
ORDER BY r.name
/

SELECT s.sid, t.used_ublk
    FROM v$transaction t,
         v$session s,
         v$rollname r
    WHERE saddr = t.ses_addr AND
         r.usn = t.xidusn 
/


