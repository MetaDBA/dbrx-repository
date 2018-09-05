col Hostname form a25 heading "Hostname"
col Instance form a8  heading "Instance"
col Version  form a12 heading "Version"

select to_char(sysdate, 'MM-DD-YY HH24:MI') "Stats as of",
        s.host_name Hostname,
        s.instance_name Instance,
        to_char(s.startup_time, '  MM-DD-YY HH24:MI:SS  ')
                        "Instance Startup Time",
        version Version,
        to_char(p.value,'999999999999') "DB Block Size"
from v$instance s, v$parameter p
where p.name = 'db_block_size';

