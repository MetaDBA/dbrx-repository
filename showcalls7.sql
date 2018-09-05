REM  From Metalink Note 2070068.6; may be for Oracle 7.3 only  
REM
REM This routine displays all calls for all TXN 
REM  
REM It should be run in sqlplus connected as the REPADMIN or a user who 
REM has permissions to query the deftran and defcal views. 
REM  
REM Please Note: Output is limited to 1000000 bytes 
REM  
REM Created by Richard Jobin,  Oracle World Wide Technical Support 
REM 
REM  
 
spool trans.log 
set serveroutput on size 1000000 
DECLARE  
argno  number;  
argtyp number;  
typdsc char(15);  
rowid_val      rowid;  
char_val       varchar2(255);  
date_val       date;  
number_val     number;  
varchar2_val   varchar2(2000);  
raw_val        raw(255);  
callno number;  
start_time     varchar2(255); 
destination    varchar2(255); 
v_tranid deftran.deferred_tran_id%TYPE; 
origdb varchar2(200);  
origuser varchar2(200); 
local_node varchar2(300); 
tranid varchar2(70);  
schnam varchar2(35);  
pkgnam varchar2(35);  
prcnam varchar2(35); 
operation varchar2(35);  
argcnt number;  
cursor c_deftran is 
       select deferred_tran_id, origin_user  
       from deftran; 
cursor c_defcall is  
       select callno,   
              deferred_tran_db,   
              deferred_tran_id,  
              schemaname,  
   packagename,  
              procname,  
              argcount  
       from defcall  
         where deferred_tran_id = v_tranid;  
cursor c_operation is 
 select substr(procname,5,12)  
       from defcall 
         where deferred_tran_id = v_tranid; 
cursor c_started is 
       select to_char(start_time,'MON-DD-YYYY:HH24:MI:SS') 
       from deftran 
       where deferred_tran_id = v_tranid; 
cursor c_destination is 
       select dblink from deftrandest 
       where deferred_tran_id = v_tranid; 
begin  
  select global_name into local_node from global_name; 
  dbms_output.put_line(chr(10)||'PRINTING ALL CALLS FOR SITE: 
'||local_node||chr(10)); 
  FOR c_deftran_rec in c_deftran 
   LOOP 
  v_tranid := c_deftran_rec.deferred_tran_id; /* Assign bind variable */ 
  origuser := c_deftran_rec.origin_user; 
argno := 1;  
  open c_defcall;  
  open c_operation; 
  open c_started; 
  open c_destination; 
  while TRUE LOOP  
     fetch c_defcall into callno,origdb,tranid,schnam,pkgnam,prcnam,argcnt;  
     fetch c_operation into operation; 
     fetch c_started into start_time; 
     fetch c_destination into destination; 
     exit when c_defcall%NOTFOUND;  
     dbms_output.put_line('*******************************************'); 
     dbms_output.put_line('Transaction id: '||tranid); 
     dbms_output.put_line('Transaction logged by: '||origuser); 
     dbms_output.put_line('Transaction logged on: '||start_time); 
     dbms_output.put_line('DML operation is a ' || operation||'.'); 
     dbms_output.put_line('Originating from ' || origdb); 
     dbms_output.put_line('Destination to: ' || destination); 
  dbms_output.put_line('Call to ' || schnam||'.'||pkgnam||'.'||prcnam);  
     dbms_output.put_line('ARG ' || 'Data Type       ' || 'Value');  
     dbms_output.put_line('--- ' || '--------------- '   
                          || '-----------------------');  
     argno := 1;  
     while TRUE LOOP  
        if argno > argcnt then  
            exit;  
        end if;  
  
        argtyp := dbms_defer_query.get_arg_type(callno,  
                                             origdb,  
                                argno,  
                tranid);  
        if argtyp = 1 then  
           typdsc := 'VARCHAR2';  
           varchar2_val := dbms_defer_query.get_varchar2_arg(callno,  
             origdb,argno,tranid);  
         dbms_output.put_line(to_char(argno,'09')   
    || ') ' || typdsc||' '|| varchar2_val);  
        end if;  
        if argtyp = 2 then  
           typdsc := 'NUMBER';  
           number_val := dbms_defer_query.get_number_arg(callno,  
     origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| number_val);  
 end if;  
        if argtyp = 11 then  
           typdsc := 'ROWID';  
 rowid_val := dbms_defer_query.get_rowid_arg(callno,  
                        origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| rowid_val);  
        end if;  
        if argtyp = 12 then  
           typdsc := 'DATE';  
           date_val := dbms_defer_query.get_date_arg(callno,  
                                       origdb,argno,tranid);  
    dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '  
                                || to_char(date_val,'YYYY-MM-DD HH24:MI:SS'));  
        end if;  
        if argtyp = 23 then  
typdsc := 'RAW';  
raw_val := dbms_defer_query.get_raw_arg(callno,  
                   origdb,argno,tranid);  
    dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| raw_val);  
     end if;  
        if argtyp = 96 then  
           typdsc := 'CHAR';  
    char_val := dbms_defer_query.get_char_arg(callno,  
                            origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
               || ') ' || typdsc||' '|| char_val);  
     end if;  
  
 
        argno := argno + 1;  
     end loop;  
 end loop;  
 close c_defcall;  
 close c_operation; 
 close c_started; 
 close c_destination; 
 END LOOP; 
end; 
/ 
spool off 
 

