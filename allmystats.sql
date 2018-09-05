select  c.value, nc.name
from v$mystat c, v$statname nc
where nc.statistic# = c.statistic#
order by nc.name;
