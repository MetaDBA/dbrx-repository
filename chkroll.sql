@identstats;

col usn         form 999
col exts        form 9999
col xacts       form 999
col rssize      form 999,999,999 heading 'Size'
col writes      form 9,999,999,999  heading 'Writes'
col optsize     form 999,999,999  heading 'Optimal'
col hwmsize     form 999,999,999 heading 'HiWater'
col shrinks     form 999999  heading 'Shrnks'
col wraps       form 99999   heading 'Wraps'
col extends     form 99999 heading 'Extnds'
col aveshrink   form 999999999 heading 'Avshrk'
col aveactive   form 999,999,999 heading 'Avactv'
col waits       form 9999 heading 'Waits'

select
usn,
EXTENTS EXTS,
xacts,
RSSIZE,
WRITES,
OPTSIZE,
HWMSIZE hwmsize,
SHRINKS,
WRAPS,
EXTENDS,
AVESHRINK,
AVEACTIVE,
WAITS
from v$rollstat
order by to_number(usn);
