Prompt  Run this script once to confirm the kills make sense. Then spool to 
Prompt  /tmp/tempkill.sql and run the last query again, spool off, and @/tmp/tempkill

Prompt Hit <Enter to continue>
Accept x

select program, count(*) from v$process group by program;

Prompt Hit <Enter to continue>
Accept x

select '!kill -9 ' || spid from v$process where addr not in (select paddr from v$session);
/* and program = 'oracle@trac303.pixar.com' */


