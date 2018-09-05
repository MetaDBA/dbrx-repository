-- ********************************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename		: sessinfo.sql
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 18-jan-01
-- * Description	: Show session related information
-- * Usage		: start sessinfo.sql
-- ********************************************************************

-- Note that the blocking_session value is adjusted by 1 to deal with
-- an apparent bug in 10.2.0.1

def osm_prog    = 'sessinfo.sql'
def osm_title   = 'Session Information'
start osmtitle

--col "Session Info" form A80
col a              form a60 fold_after 1

set verify off

accept sid      prompt 'Please enter the value for Sid if known            : '
accept terminal prompt 'Please enter the value for terminal if known       : '
accept machine  prompt 'Please enter the machine name if known             : '
accept process  prompt 'Please enter the value for Client Process if known : '
accept spid     prompt 'Please enter the value for Server Process if known : '
accept osuser   prompt 'Please enter the value for OS User if known        : '
accept username prompt 'Please enter the value for DB User if known        : '
accept progname prompt 'Please enter the value for program name            : '

set heading off

select 'Sid, Serial#, Aud sid : '|| s.sid||' , '||s.serial#||' , '||s.audsid a,
       'DB User / OS User     : '||s.username||' / '||s.osuser a,
       'Machine - Terminal    : '||s.machine||' - '|| s.terminal a,
       'OS Process Ids        : '||s.process||' (Client)  '||p.spid||' (Server)' a,
       'Client Program Name   : '||s.program a ,
       'Logon Time            : '||to_char(s.logon_time,'DD-MON-YY HH24:MI:SS') a,
       'Last Call Time        : '||(sysdate - (s.last_call_et/86400)) a,
       'Status, Hash_value    : '||s.status  || '      ' || s.sql_hash_value a
  from v$process p,
       v$session s
 where p.addr              = s.paddr
   and s.sid               = nvl('&SID',s.sid)
   and nvl(s.terminal,' ') like nvl('%&terminal%',nvl(s.terminal,' '))
   and s.process           = nvl('&Process',s.process)
   and p.spid              = nvl('&spid',p.spid)
   and upper(s.username)         like nvl(upper('%&username%'),upper(s.username))
   and nvl(upper(s.osuser),' ')  like nvl(upper('%&OSUser%'),nvl(upper(s.osuser),' '))
   and nvl(upper(s.machine),' ') like nvl(upper('%&machine%'),nvl(upper(s.machine),' '))
   and upper(s.program)          like nvl(upper('%&progname%'),'%')
/

set heading on
start osmclear
