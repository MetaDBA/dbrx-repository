
ALTER SESSION SET events '10046 trace name context forever, level 12';
----------------------------------------------------------------------------

select 'execute sys.dbms_system.set_ev(' || s.sid ||
', ' || s.serial# || ', 10046, 12, '''');'
from v$session s
where s.machine like 'WORKGROUP\TERRYSUTTO%'
and username = 'ANTUSER'
;

select 'execute sys.dbms_system.set_ev(' || s.sid ||
', ' || s.serial# || ', 10046, 0, '''');'
from v$session s
where s.machine like 'WORKGROUP\TERRYSUTTO%'
;


select 'execute sys.dbms_system.set_ev(' || s.sid ||
', ' || s.serial# || ', 10046, 4, '''');'
from v$session s
where s.machine like 'wbiqark1p%'
and username = 'IBM_USER'
;


select 'execute sys.dbms_system.set_ev(' || s.sid ||
', ' || s.serial# || ', 10046, 0, '''');'
from v$session s
where s.machine like 'wbiqark1p%'
and username = 'IBM_USER'
;
