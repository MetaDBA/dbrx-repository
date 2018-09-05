select to_char(a.value, '999,999,999,999') "redo entries",
 to_char(b.value, '99,999,999,999,999,999') "redo log space requests",
 to_char(a.value/(b.value + .0001), '99,999,999,999,999') "Ratio (s.b. > 5000)",
 to_char(c.value, '999,999,999,999') "Log Buffer Size"
from v$sysstat a, v$sysstat b, v$parameter c
where a.name = 'redo entries'
and b.name = 'redo log space requests'
and c.name = 'log_buffer';

