-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: mysess.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 24-SEP-98
-- * Last Update	: 24-SEP-98
-- * Description	: Show the executers session stuff
-- * Usage		: start mysess.sql
-- ********************************************************************

def osm_prog    = 'mysess.sql'
def osm_title   = 'Your Session Stuff'
start osmtitle

col a              form a70 fold_after 1

set heading off feedback off

select 'Sid, Serial#, Aud sid : '|| s.sid||' , '||s.serial#||' , '||s.audsid a,
       'DB User / OS User     : '||s.username||'   /   '||s.osuser a,
       'Machine - Terminal    : '||s.machine||'  -  '||s.terminal a,
       'OS Process Ids        : '||s.process||' (Client)  '||p.spid||' (Server)' a,
       'Client Program Name   : '||s.program a ,
       'Logon Time            : '||to_char(s.logon_time,'DD-MON-YY HH24:MI:SS') a
  from v$process p,
       v$session s
 where p.addr   = s.paddr
   and s.audsid = userenv('SESSIONID')
/
start osmclear
set heading on feedback on
