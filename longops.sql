col sid form 9999
col username form a10
col target form a20
col opname form a15
col units form a8
col elapsed_seconds form 999999 heading "Elapsed|Seconds"
col time_remaining  form 999999 heading "Time|Remain"
col time            form a8     heading "Current|Time"
col completion      form a8     heading "Estimate|Complete"


select	sid, 
	substr(username, 1,8) "username",
        substr(opname, 1,15) "opname",
        substr(target, 1,30) "target",
        sofar,
        totalwork,
        substr(units, 1,8) "units",
        elapsed_seconds,
        time_remaining,
        to_char(100*sofar/totalwork, '99') || '%' "PctDone",
        to_char(sysdate,'HH24:MI:SS') "Time",
        to_char((sysdate + time_remaining/86400),'HH24:MI:SS') completion
   from v$session_longops
 where sofar < totalwork;

