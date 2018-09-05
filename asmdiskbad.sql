col path           form a35
col name           form a18
col group_number   form 999999 heading "Group|Number"
col disk_number    form 999999 heading "Disk|Number"
col header_status  form a7 heading "Header|Status"
col mode_status    form a7 heading "Mode|Status"
col mount_status_p form a8 heading "Mount|Status"
col state          form a7 heading "State"

select group_number, disk_number, ' ' || mount_status mount_status_p,
 header_status, mode_status, state, path, name
from v$asm_disk
where mount_status <> 'CACHED'
order by mount_status, header_status, group_number, disk_number;

