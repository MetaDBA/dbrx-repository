
def osm_prog    = 'sqlproc.sql'
def osm_title   = 'Session Stuff'
def proc_num    = &&1
start osmtitle

col a              form a70 fold_after 1
col sid form 9999
col spid form a6

-- set heading off feedback off

select s.sid sid, p.spid spid, t.hash_value, t.sql_text
  from v$process p,
       v$session s,
       v$sqltext t
 where p.addr   = s.paddr
   and t.address = s.sql_address
   and p.spid = &proc_num 
   order by piece
/
start osmclear
undef proc_num
