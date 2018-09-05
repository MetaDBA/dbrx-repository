set pagesize 10000
set linesize 140
column d_name format a20
column p_name format a20
select do.obj# d_obj,do.name d_name, u.name owner, po.obj# p_obj,po.name p_name,
to_char(p_timestamp,'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",
to_char(po.stime ,'DD-MON-YYYY HH24:MI:SS') "STIME",
decode(sign(po.stime-p_timestamp),0,'SAME','*DIFFER*') X
from sys.obj$ do, sys.dependency$ d, sys.obj$ po, sys.user$ u
where P_OBJ#=po.obj#(+)
and D_OBJ#=do.obj#
and do.status=1 /*dependent is valid*/
and po.status=1 /*parent is valid*/
and po.stime!=p_timestamp /*parent timestamp not match*/
and do.owner#=u.user#
and do.type# = 5
order by 2,1;
