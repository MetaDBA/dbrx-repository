undefine wk_tran_id  
REM  
REM  This routine displays all calls for a given deferred TXN  
REM     
REM  from Metalink Note 2063747.4
REM  
set serveroutput on size 1000000  
column deferred_tran_db format a20 trunc
column deferred_tran_id format a20 trunc
PROMPT DEFCALL Entries:
PROMPT ===============
REM select deferred_tran_id from defcall;
PROMPT DEFERROR Entries:
PROMPT =================
SELECT deferred_tran_id, start_time || ' (GMT?)'
error_number, error_msg FROM DEFERROR;
DECLARE  
argno  number;  
argtyp number;  
typdsc char(15);  
rowid_val      rowid;  
char_val       varchar2(255);  
date_val       date;  
number_val number;  
varchar2_val   varchar2(2000);  
raw_val        raw(255);  
callno number;  
origdb varchar2(200);  
tranid varchar2(70);  
schnam varchar2(35);  
pkgnam varchar2(35);  
prcnam varchar2(35); 
operation varchar2(35);  
argcnt number;  
cursor c_defcall is  
       select callno,   
        deferred_tran_id,  
              schemaname,  
              packagename,  
              procname,  
              argcount  
       from defcall  
       where deferred_tran_id = '&&wk_tran_id.';  
cursor c_operation is 
       select substr(procname,5,12)  
       from defcall 
       where deferred_tran_id = '&&wk_tran_id.'; 
begin  
  argno := 1;  
  open c_defcall;  
  open c_operation; 
  while TRUE LOOP  
     fetch c_defcall into callno,tranid,schnam,pkgnam,prcnam,argcnt;  
     fetch c_operation into operation; 
     exit when c_defcall%NOTFOUND;  
     dbms_output.put_line('Transaction id: '||tranid); 
     dbms_output.put_line('DML operation is an ' || operation||'.'); 
     dbms_output.put_line('Originating from ' || '.'); 
     dbms_output.put_line('Call to ' || schnam||'.'||pkgnam||'.'||prcnam);  
     dbms_output.put_line('ARG ' || 'Data Type       ' || 'Value');  
     dbms_output.put_line('--- ' || '--------------- '   
                  || '----------------------');  
     argno := 1;  
     while TRUE LOOP  
        if argno > argcnt then  
            exit;  
        end if;  
  
        argtyp := dbms_defer_query.get_arg_type(callno,  
                                             argno,  
                                             tranid);  
        if argtyp = 1 then  
           typdsc := 'VARCHAR2';  
           varchar2_val := dbms_defer_query.get_varchar2_arg(callno,  
       argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| varchar2_val);  
     end if;  
        if argtyp = 2 then  
           typdsc := 'NUMBER';  
     number_val := dbms_defer_query.get_number_arg(callno,  
                                     argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| number_val);  
        end if;  
        if argtyp = 11 then  
  typdsc := 'ROWID';  
           rowid_val := dbms_defer_query.get_rowid_arg(callno,  
                                                         argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
            || ') ' || typdsc||' '|| rowid_val);  
        end if;  
        if argtyp = 12 then  
           typdsc := 'DATE';  
           date_val := dbms_defer_query.get_date_arg(callno,  
  argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '  
       || to_char(date_val,'YYYY-MM-DD HH24:MI:SS'));  
        end if;  
if argtyp = 23 then  
           typdsc := 'RAW';  
           raw_val := dbms_defer_query.get_raw_arg(callno,  
  argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| raw_val);  
        end if;  
        if argtyp = 96 then  
           typdsc := 'CHAR';  
           char_val := dbms_defer_query.get_char_arg(callno,  
                   argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| char_val);  
        end if;  
  
          
        argno := argno + 1;  
     end loop;  
 end loop;  
 close c_defcall;  
 close c_operation; 
end; 
/ 


