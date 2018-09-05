
REM ALTER SESSION SET events '10046 trace name context forever, level 12';
REM ----------------------------------------------------------------------------

select 'execute sys.dbms_system.set_ev(' || s.sid ||
', ' || s.serial# || ', 10046, 12, '''');'
from v$session s
where s.machine like 'crowbar%'
and username like 'STEELWEDGE311%'
;


