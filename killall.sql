select 'alter system kill session ''' || sid || ',' || serial# || ''';'
from v$session
where username = 'LISTAPP'
and status = 'ACTIVE'
order by sid desc;
