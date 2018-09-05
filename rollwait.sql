select substr(name, 1, 14) "Rollback Name", gets "Gets", waits "Waits",
 to_char(100*waits/gets, '990.99') "PctWait"
from v$rollstat s, v$rollname n
where s.usn = n.usn;
select sum(gets), sum(waits),
 to_char(100*sum(waits)/sum(gets), '990.99') "PctWait"
from v$rollstat s;
