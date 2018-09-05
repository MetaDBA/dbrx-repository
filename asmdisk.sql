col path           form a25
col name           form a15
col group_number   form 999999 heading "Group|Number"
col disk_number    form 999999 heading "Disk|Number"
col header_status  form a9 heading "Header|Status"
col mode_status    form a7 heading "Mode|Status"
col mount_status_p form a8 heading "Mount|Status"
col state          form a7 heading "State"

select group_number, disk_number, ' ' || mount_status mount_status_p,
 header_status, mode_status, state, path, name, total_mb, free_mb
from v$asm_disk
order by mount_status, header_status, group_number, disk_number;

