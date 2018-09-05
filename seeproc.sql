
def osm_prog    = 'seeproc.sql'
def osm_title   = 'Session Stuff'
def proc_num    = &&1
start osmtitle

col a              form a70 fold_after 1

set heading off feedback off

select 'Sid, Serial#, Aud sid : '|| s.sid||' , '||s.serial#||' , '||s.audsid a,
       'DB User / OS User     : '||s.username||'   /   '||s.osuser a,
       'Machine - Terminal    : '||s.machine||'  -  '||s.terminal a,
       'OS Process Ids        : '||s.process||' (Client)  '||p.spid||' (Server)' a,
       'Client Program Name   : '||s.program a
  from v$process p,
       v$session s
 where p.addr   = s.paddr
   and p.spid = &proc_num 
/
start osmclear
undef proc_num
