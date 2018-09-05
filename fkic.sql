SET ECHO off 
REM NAME:   TFSFKCHLK.SQL 
REM USAGE:"@path/tfsfkchk" 
REM USAGE:"@fkic <schema_name>
REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    Privs on the DBA views. 
REM -------------------------------------------------------------------------- 
REM PURPOSE: 
REM    This file checks the specified user's Foreign Keys to make sure of the  
REM    following: 
REM 
REM    1) All the FK columns have indexes to prevent a possible locking 
REM       problem that can slow down the database. 
REM 
REM    2) Checks the ORDER OF THE INDEXED COLUMNS. To prevent the locking 
REM       problem the columns MUST be index in the same order as the FK is 
REM       defined. 
REM    
REM    3) If the script finds a mismatch the script reports the correct  
REM       order of columns that need to be added to prevent the locking 
REM       problem. 
REM 
REM    NOTES: 
REM 
REM      - This locking problem is discussed in the  
REM        Oracle 7 Server, Application Developer's Guide Page 6-10  
REM        under the section "No Index on the Foreign Key" 
REM  
REM ----------------------------------------------------------------------- 
REM EXAMPLE: 
REM    LINEMSG  
REM    ------------------------------------------------------------------- 
REM    Changing data in table ITEMS will lock table ITEM_CATEGORIES 
REM    Create an index on the following columns to remove lock problem 
REM 
REM    Column = ITEM_CAT (1) 
REM    Column = ITEM_BUS_UNIT (2) 
REM     
REM    Changing data in table ITEMS will lock table ITEM_CATEGORIES 
REM    Create an index on the following columns to remove lock problem 
REM  
REM    Column = ITEM_CAT (1) 
REM    Column = ITEM_BUS_UNIT (2) 
REM ----------------------------------------------------------------------- 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. It is NOT  
REM    supported by Oracle World Wide Technical Support. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM ------------------------------------------------------------------------- 
REM Main text of script follows: 

def ownname     = &&1

drop table ck_log purge; 
 
create table ck_log ( 
LineNum number, 
LineMsg varchar2(2000)); 
 
declare 
t_CONSTRAINT_TYPE           
dba_constraints.CONSTRAINT_TYPE%type; 
t_CONSTRAINT_NAME           
dba_CONSTRAINTS.CONSTRAINT_NAME%type; 
t_TABLE_NAME   dba_CONSTRAINTS.TABLE_NAME%type; 
t_R_CONSTRAINT_NAME          dba_CONSTRAINTS.R_CONSTRAINT_NAME%type; 
tt_CONSTRAINT_NAME           dba_CONS_COLUMNS.CONSTRAINT_NAME%type; 
tt_TABLE_NAME               
dba_CONS_COLUMNS.TABLE_NAME%type; 
tt_COLUMN_NAME              
dba_CONS_COLUMNS.COLUMN_NAME%type; 
tt_POSITION             
dba_CONS_COLUMNS.POSITION%type; 
tt_Dummy                    
number; 
tt_dummyChar                
varchar2(2000); 
l_Cons_Found_Flag            VarChar2(1); 
Err_TABLE_NAME               
dba_CONSTRAINTS.TABLE_NAME%type; 
Err_COLUMN_NAME              
dba_CONS_COLUMNS.COLUMN_NAME%type; 
Err_POSITION          dba_CONS_COLUMNS.POSITION%type; 
 
tLineNum number; 
 
cursor UserTabs is 
       select table_name 
       from   dba_tables where owner = upper('&ownname') -- owner1
       -- where Table_Name = 'WORKERS_COMP_CLAIMS' 
       order by table_name; 
 
cursor TableCons is 
       select CONSTRAINT_TYPE, 
              CONSTRAINT_NAME, 
              R_CONSTRAINT_NAME 
       from dba_constraints 
       where owner = upper('&ownname') 	--owner2
       and table_name = t_Table_Name 
       and CONSTRAINT_TYPE  = 'R' 
       order by TABLE_NAME, CONSTRAINT_NAME; 
 
cursor ConColumns is 
       select CONSTRAINT_NAME, 
    TABLE_NAME, 
              COLUMN_NAME, 
              POSITION 
       from DBA_cons_columns 
       where owner = upper('&ownname') 	--owner3
       and   CONSTRAINT_NAME = t_CONSTRAINT_NAME 
       order by POSITION; 
 
cursor IndexColumns is 
       select TABLE_NAME, 
              COLUMN_NAME, 
              POSITION 
       from DBA_cons_columns 
       where owner = upper('&ownname') 	--owner4
       and   CONSTRAINT_NAME = t_CONSTRAINT_NAME 
       order by POSITION; 
 
DebugLevel number := 99; -- >> 99 = dump all info` 
DebugFlag varchar(1) := 'N'; -- Turn Debugging on 
t_Error_Found  varchar(1); 
 
begin 
 
  tLineNum := 1000; 
  open UserTabs; 
  LOOP 
    Fetch UserTabs into t_TABLE_NAME; 
    t_Error_Found := 'N'; 
    exit when UserTabs%NOTFOUND; 
 
    -- Log current table 
    tLineNum := tLineNum + 1; 
    insert into ck_log ( LineNum, LineMsg ) values 
    ( tLineNum, NULL ); 
 
    tLineNum := tLineNum + 1; 
    insert into ck_log ( LineNum, LineMsg ) values 
    ( tLineNum, 'Checking Table '||t_Table_Name); 
 
    l_Cons_Found_Flag := 'N'; 
    open TableCons; 
    LOOP 
      FETCH TableCons INTO t_CONSTRAINT_TYPE, 
                   
t_CONSTRAINT_NAME, 
               t_R_CONSTRAINT_NAME; 
      exit when TableCons%NOTFOUND; 
 
      if ( DebugFlag = 'Y' and DebugLevel >= 99 ) 
      then 
        begin 
          tLineNum := tLineNum + 1; 
          insert into ck_log ( LineNum, LineMsg ) values 
          ( tLineNum, 'Found CONSTRAINT_NAME = '|| t_CONSTRAINT_NAME); 
 
   tLineNum := tLineNum + 1; 
          insert into ck_log ( LineNum, LineMsg ) values 
          ( tLineNum, 'Found CONSTRAINT_TYPE = '|| t_CONSTRAINT_TYPE); 
 
        tLineNum := tLineNum + 1; 
          insert into ck_log ( LineNum, LineMsg ) values 
          ( tLineNum, 'Found R_CONSTRAINT_NAME = '|| t_R_CONSTRAINT_NAME); 
          commit; 
        end; 
      end if; 
 
      open ConColumns; 
 LOOP 
        FETCH ConColumns INTO 
                         
tt_CONSTRAINT_NAME, 
                         
tt_TABLE_NAME, 
                         
tt_COLUMN_NAME, 
                         
tt_POSITION; 
        exit when ConColumns%NOTFOUND; 
        if ( DebugFlag = 'Y' and DebugLevel >= 99 ) 
        then 
          begin 
            tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, NULL ); 
 
            tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
   ( tLineNum, 'Found CONSTRAINT_NAME = '|| tt_CONSTRAINT_NAME); 
 
            tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'Found TABLE_NAME = '|| tt_TABLE_NAME); 
 
tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'Found COLUMN_NAME = '|| tt_COLUMN_NAME); 
 
    tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'Found POSITION = '|| tt_POSITION); 
          commit; 
          end; 
      end if; 
 
      begin 
        select 1 into tt_Dummy 
        from DBA_ind_columns 
        where   TABLE_NAME =  tt_TABLE_NAME
  AND index_owner = upper('&ownname') 	-- owner5
  and     COLUMN_NAME = tt_COLUMN_NAME 
        and     COLUMN_POSITION = tt_POSITION; 
 
        if ( DebugFlag = 'Y' and DebugLevel >= 99 ) 
        then 
  begin 
            tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'Row Has matching Index' ); 
       end; 
        end if; 
      exception 
      when Too_Many_Rows then 
  if ( DebugFlag = 'Y' and DebugLevel >= 99 ) 
        then 
          begin 
       tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'Row Has matching Index' ); 
          end; 
        end if; 
 
      when no_data_found then 
        if ( DebugFlag = 'Y' and DebugLevel >= 99 ) 
        then 
          begin 
            tLineNum := tLineNum + 1; 
            insert into ck_log ( LineNum, LineMsg ) values 
            ( tLineNum, 'NO MATCH FOUND' ); 
          commit; 
          end; 
        end if; 
 
      t_Error_Found := 'Y'; 
 
        select distinct TABLE_NAME 
        into tt_dummyChar 
        from DBA_cons_columns 
        where owner = upper('&ownname') 	--owner6
        and   CONSTRAINT_NAME = t_R_CONSTRAINT_NAME; 
 
        tLineNum := tLineNum + 1; 
    insert into ck_log ( LineNum, LineMsg ) values 
        ( tLineNum, 'Changing data in table '||tt_TABLE_NAME 
                   
||' will lock table ' ||tt_dummyChar); 
 
        commit; 
        tLineNum := tLineNum + 1; 
        insert into ck_log ( LineNum, LineMsg ) values 
        ( tLineNum,'Create an index on the following columns to remove lock  
problem'); 
        open IndexColumns ; 
 loop 
          Fetch IndexColumns into Err_TABLE_NAME, 
              Err_COLUMN_NAME, 
              Err_POSITION; 
          exit when IndexColumns%NotFound; 
        tLineNum := tLineNum + 1; 
          insert into ck_log ( LineNum, LineMsg ) values 
          ( tLineNum,'Column = '||Err_COLUMN_NAME||' ('||Err_POSITION||')'); 
          end loop; 
        close IndexColumns; 
      end; 
    end loop; 
    commit; 
  close ConColumns; 
  end loop; 
  if ( t_Error_Found = 'N' ) 
  then 
    begin 
      tLineNum := tLineNum + 1; 
      insert into ck_log ( LineNum, LineMsg ) values 
      ( tLineNum,'No foreign key errors found'); 
    end; 
  end if; 
  commit; 
  close TableCons; 
end loop; 
commit; 
end; 
 
/ 
 
select LineMsg 
from ck_log 
where LineMsg NOT LIKE 'Checking%' AND 
      LineMsg NOT LIKE 'No Probl%' 
order by LineNum 
/ 
 
