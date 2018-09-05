set termout off

col tracefile new_value trcfile
col command new_value dyncmd

-- Find tracefile location
-- Note you might need to change the "_ora_" part if Oracle uses different names for 
-- tracefiles on your platform 

select value ||'/'||(select lower(instance_name) from v$instance) ||'_ora_'||
       (select spid from v$process where addr = (select paddr from v$session
                                         where sid = (select sid from v$mystat
                                                    where rownum = 1
                                               )
                                    )
       ) || '.trc' tracefile
from v$parameter where name = 'user_dump_dest';

-- End tracing
alter session set events '&1 trace name context off';

-- Close trafefile
-- Could use oradebug close_trace for sys user, changing tracefile_identifier works for all
-- with alter session privilege (just altering trcfile to a temporary file)

alter session set tracefile_identifier=cleanup;

host &trcfile._cleanup.sh

host rm -f &trcfile._cleanup.sh

set termout on
