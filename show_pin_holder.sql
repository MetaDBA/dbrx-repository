column waiter format a15
column holder format a15
column held_object format a47
column lock_or_pin format a15
column address format a15
column mode_requested format a15
set feedback off
set echo off
select /*+ ORDERED */ w1.sid || '/' ||  w1.username waiter, h1.sid || '/' || h1.username holder,
o.to_owner || '.' || o.to_name held_object, w.kgllktype lock_or_pin, w.kgllkhdl address,
decode(h.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown') mode_held,
decode(w.kgllkreq, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown') mode_requested
from dba_kgllock w, dba_kgllock h, v$session w1, v$session h1, v$object_dependency o
where   (((h.kgllkmod != 0)
and (h.kgllkmod != 1)
and ((h.kgllkreq = 0)
 or (h.kgllkreq = 1)))
 and      (((w.kgllkmod = 0)
 or (w.kgllkmod= 1))
   and ((w.kgllkreq != 0)
   and (w.kgllkreq != 1))))
     and  w.kgllktype    =  h.kgllktype
         and  w.kgllkhdl         =  h.kgllkhdl
         and  w.kgllkuse     =   w1.saddr
         and  h.kgllkuse     =   h1.saddr
         and  w.kgllkhdl     =  o.to_address
;

