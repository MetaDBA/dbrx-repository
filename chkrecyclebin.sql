select count(*), round((sysdate -  to_date(min(droptime), 'yyyy-mm-dd:hh24:mi:ss')) *1440) minutes, sum(space) * 8192 bytes from dba_recyclebin
/
