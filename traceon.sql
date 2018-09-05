--
-- Note that the trace file name under udump may vary by plaftorm
-- You might meed to change this "_ora_" part to something different..
-- 

set echo off
set termout off

col tracefile new_value trcfile


select value ||'/'||(select lower(instance_name) from v$instance) ||'_ora_'||
       (select spid from v$process where addr = (select paddr from v$session
                                         where sid = (select sid from v$mystat
                                                    where rownum = 1
                                               )
                                    )
       ) || '.trc' tracefile
from v$parameter where name = 'user_dump_dest';

host mknod &trcfile p


host ./traceon.sh &trcfile "&3"

alter session set tracefile_identifier='';
alter session set events '&1 trace name context forever, level &2';

set termout on
set echo on

