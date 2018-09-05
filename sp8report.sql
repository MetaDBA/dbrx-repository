Rem
Rem $Header: spreport.sql 10-jul-00.08:50:58 cdialeri Exp $
Rem
Rem spreport.sql
Rem
Rem  Copyright (c) Oracle Corporation 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      spreport.sql
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to report on differences between
Rem      values recorded in two snapshots.
Rem
Rem    NOTES
Rem      Usually run as the STATSPACK owner, PERFSTAT
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    07/10/00 - 1349995
Rem    cdialeri    06/21/00 - 1336259
Rem    cdialeri    04/06/00 - 1261813
Rem    cdialeri    03/28/00 - sp_purge
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    11/01/99 - Enhance, 1059172
Rem    cgervasi    06/16/98 - Remove references to wrqs
Rem    cmlim       07/30/97 - Modified system events
Rem    gwood.uk    02/30/94 - Modified
Rem    densor.uk   03/31/93 - Modified
Rem    cellis.uk   11/15/89 - Created
Rem

clear break compute;
repfooter off;
ttitle off;
btitle off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 2 recsep off;
set trimspool on trimout on;
define top_n_events = 8;
define top_n_sql = 200;
define num_rows_per_hash=5;

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

column inst_num  heading "Inst Num"    new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;
select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

variable dbid       number;
variable inst_num   number;
variable inst_name  varchar2(20);
variable db_name    varchar2(20);
begin 
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num; 
  :inst_name := '&inst_name';
  :db_name   := '&db_name';
end;
/


--
--  Ask for the snapshots Id's which are to be compared

set termout on;
column instart_fmt noprint;
column versn noprint    heading 'Release'  new_value versn;
column host_name noprint heading 'Host'    new_value host_name;
column para  noprint    heading 'OPS'      new_value para;
column level format 99  heading 'Snap|Level';
column snap_id      	heading 'Snap|Id' format 99990;
column snapdat      	heading 'Snap Started' just c	format a17;
column comment          heading 'Comment' format a22;
break on inst_name on db_name on instart_fmt;
ttitle lef 'Completed Snapshots' skip 2;

select di.instance_name                                  inst_name
     , di.host_name                                      host_name
     , di.db_name                                        db_name
     , di.version                                        versn
     , di.parallel                                       para
     , to_char(s.startup_time,' dd Mon "at" HH24:mi:ss') instart_fmt
     , s.snap_id
     , to_char(s.snap_time,'dd Mon YYYY HH24:mi')       snapdat
     , s.snap_level                                      "level"
     , substr(s.ucomment, 1,60)                          "comment"
  from stats$snapshot s
     , stats$database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and s.instance_number   = :inst_num
   and di.instance_number  = :inst_num
   and di.startup_time     = s.startup_time
 order by db_name, instance_name, snap_id;
clear break;
ttitle off;

prompt
prompt
prompt Specify the Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Begin Snapshot Id specified: &&begin_snap
prompt
prompt End   Snapshot Id specified: &&end_snap
prompt

set termout on;
variable bid   number;
variable eid   number;
variable versn varchar2(10);
variable para  varchar2(9);
variable host_name varchar2(64);
begin 
  :bid    := &&begin_snap; 
  :eid    := &&end_snap;
  :versn  := '&versn';
  :para   := '&para';
  :host_name := '&host_name';
end;
/


--
-- Use report name if specified, otherwise prompt user for output file 
-- name (specify default), then begin spooling

set termout off;
column dflt_name new_value dflt_name noprint;
select 'sp_'||:bid||'_'||:eid dflt_name from dual;
set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name, 
prompt press <return> to continue, otherwise enter an alternative.

set heading off;
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , nvl('&&report_name','&dflt_name') report_name
  from sys.dual;
spool &report_name;
set heading on;
prompt


--
--  Verify begin and end snapshot Ids exist for the database, and that
--  there wasn't an instance shutdown in between the two snapshots 
--  being taken.

set heading off;

select 'ERROR: Database/Instance does not exist in STATS$DATABASE_INSTANCE'
  from dual
 where not exists
      (select null
         from stats$database_instance
        where instance_number = :inst_num
          and dbid            = :dbid);


select 'ERROR: Begin Snapshot Id specified does not exist for this database/instance'
  from dual
 where not exists
      (select null
         from stats$snapshot b
        where b.snap_id         = :bid
          and b.dbid            = :dbid
          and b.instance_number = :inst_num);


select 'ERROR: End Snapshot Id specified does not exist for this database/instance'
  from dual
 where not exists
      (select null
         from stats$snapshot e
        where e.snap_id         = :eid
          and e.dbid            = :dbid
          and e.instance_number = :inst_num);


select 'WARNING: timed_statitics setting changed between begin/end snaps: TIMINGS ARE INVALID'
  from dual
 where not exists
      (select null
         from stats$parameter b
            , stats$parameter e
        where b.snap_id         = :bid
          and e.snap_id         = :eid
          and b.dbid            = :dbid
          and e.dbid            = :dbid
          and b.instance_number = :inst_num
          and e.instance_number = :inst_num
          and b.name            = e.name
          and b.name            = 'timed_statistics'
          and b.value           = e.value);


select 'ERROR: Snapshots chosen span an instance shutdown: RESULTS ARE INVALID'
  from dual
 where not exists
      (select null
         from stats$snapshot b
            , stats$snapshot e
        where b.snap_id         = :bid
          and e.snap_id         = :eid
          and b.dbid            = :dbid
          and e.dbid            = :dbid
          and b.instance_number = :inst_num
          and e.instance_number = :inst_num
          and b.startup_time    = e.startup_time);

select 'ERROR: Session statistics are for different sessions: RESULTS NOT PRINTED'
  from dual
 where not exists
      (select null
         from stats$snapshot b
            , stats$snapshot e
        where b.snap_id         = :bid
          and e.snap_id         = :eid
          and b.dbid            = :dbid
          and e.dbid            = :dbid
          and b.instance_number = :inst_num
          and e.instance_number = :inst_num
          and b.session_id      = e.session_id
          and b.serial#         = e.serial#);
set heading on;


--
--

set newpage 1 heading on;


--
--  Call statspack to calculate certain statistics
--

set heading off;
variable lhtr   number;
variable bfwt   number;
variable tran   number;
variable chng   number;
variable ucal   number;
variable urol   number;
variable ucom   number;
variable rsiz   number;
variable phyr   number;
variable phyw   number;
variable prse   number;
variable hprs   number;
variable recr   number;
variable gets   number;
variable rlsr   number;
variable rent   number;
variable srtm   number;
variable srtd   number;
variable srtr   number;
variable strn   number;
variable call   number;
variable lhr    number;
variable sp     varchar2(512);
variable bc     varchar2(512);
variable lb     varchar2(512);
variable bs     varchar2(512);
variable twt    number;
variable logc   number;
variable prscpu number;
variable prsela number;
variable tcpu   number;
variable exe    number;
variable bspm   number;
variable espm   number;
variable bfrm   number;
variable efrm   number;
variable blog   number;
variable elog   number;
begin STATSPACK.STAT_CHANGES
   ( :bid,    :eid
   , :dbid,   :inst_num  -- End of IN arguments
   , :lhtr,   :bfwt
   , :tran,   :chng
   , :ucal,   :urol
   , :rsiz,   :phyr
   , :phyw,   :ucom
   , :prse,   :hprs
   , :recr,   :gets
   , :rlsr,   :rent
   , :srtm,   :srtd
   , :srtr,   :strn
   , :lhr,    :bc
   , :sp,     :lb
   , :bs,     :twt
   , :logc,   :prscpu
   , :tcpu,   :exe
   , :prsela
   , :bspm,   :espm, :bfrm, :efrm
   , :blog,   :elog
   );
   :call := :ucal + :recr;
end;
/

--
--  Summary Statistics
--

--
--  Print database, instance, parallel, release, host and snapshot
--  information

prompt  STATSPACK report for

set heading on;
column host_name heading "Host"     format a12 print;
column para      heading "OPS"      format a3  print;
column versn     heading "Release"  format a11  print;

select :db_name    db_name
     , :dbid       dbid
     , :inst_name  inst_name
     , :inst_num   inst_num
     , :versn      versn
     , :para       para
     , :host_name  host_name
  from sys.dual;


--
--  Print snapshot information

column inst_num   noprint
column instart_fmt new_value INSTART_FMT noprint;
column instart    new_value instart noprint;
column session_id new_value SESSION noprint;
column ela        new_value ELA     noprint;
column btim       new_value btim    heading 'Start Time' format a19 just c;
column etim       new_value etim    heading 'End Time'   format a19 just c;
column bid                          heading 'Start Id'         format 99999990;
column eid                          heading '  End Id'         format 99999990;
column dur        heading 'Duration(mins)' format 999,990.00 just r;
column scnds      heading 'Duration(secs)' format 999,990 just r;
column sess_id    new_value sess_id noprint;
column serial     new_value serial  noprint;
column bbgt       new_value bbgt noprint;
column ebgt       new_value ebgt noprint;
column bdrt       new_value bdrt noprint;
column edrt       new_value edrt noprint;
column bet        new_value bet  noprint;
column eet        new_value eet  noprint;
column bsmt       new_value bsmt noprint;
column esmt       new_value esmt noprint;
column bvc        new_value bvc  noprint;
column evc        new_value evc  noprint;
column blog       format 99,999;
column elog       format 99,999;
column nl         newline;

set heading off;
select '                Snap Id     Snap Time      Sessions'
     , '                ------- ------------------ --------'    nl
     , ' Begin Snap: ' nl, b.snap_id                            bid
     , to_char(b.snap_time, 'dd-Mon-yy hh24:mi:ss')             btim
     , :blog                                                    blog
     , '   End Snap: '                                          nl
     , e.snap_id                                                eid
     , to_char(e.snap_time, 'dd-Mon-yy hh24:mi:ss')             etim
     , :elog                                                    elog
     , '    Elapsed:'                                           nl
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)/60   dur  -- mins
     , '(mins)'
     , '                  '                                           nl
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)      scnds  -- secs
     , '(secs)'
     , b.instance_number                                        inst_num
     , to_char(b.startup_time, 'dd-Mon-yy hh24:mi:ss')          instart_fmt
     , b.session_id
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)      ela  -- secs
     , to_char(b.startup_time,'YYYYMMDD HH24:MI:SS')            instart
     , e.session_id                                             sess_id
     , e.serial#                                                serial
     , b.buffer_gets_th                                         bbgt
     , e.buffer_gets_th                                         ebgt
     , b.disk_reads_th                                          bdrt
     , e.disk_reads_th                                          edrt
     , b.executions_th                                          bet
     , e.executions_th                                          eet
     , b.sharable_mem_th                                        bsmt
     , e.sharable_mem_th                                        esmt
     , b.version_count_th                                       bvc
     , e.version_count_th                                       evc
  from stats$snapshot b
     , stats$snapshot e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.startup_time    = e.startup_time
   and b.snap_time       < e.snap_time;
set heading on;

variable btim    varchar2 (20);
variable etim    varchar2 (20);
variable ela     number;
variable instart varchar2 (18);
variable bbgt    number;
variable ebgt    number;
variable bdrt    number;
variable edrt    number;
variable bet     number;
variable eet     number;
variable bsmt    number;
variable esmt    number;
variable bvc     number;
variable evc     number;
begin
   :btim    := '&btim'; 
   :etim    := '&etim'; 
   :ela     :=  &ela;
   :instart := '&instart';
   :bbgt    := &bbgt;
   :ebgt    := &ebgt;
   :bdrt    := &bdrt;
   :edrt    := &edrt;
   :bet     := &bet;
   :eet     := &eet;
   :bsmt    := &bsmt;
   :esmt    := &esmt;
   :bvc     := &bvc;
   :evc     := &evc;
end;
/

--
--

set heading off;

--
--  Cache Sizes

column dscr format a20 newline;
column val  format a10 just r;

select 'Cache Sizes'                                     dscr
      ,'~~~~~~~~~~~'                                     dscr
      ,'db_block_buffers:' dscr, lpad(:bc,10) val      
      ,'       log_buffer:', lpad(:lb,10)              val            
      ,'   db_block_size:' dscr, lpad(:bs,10) val                  
      ,' shared_pool_size:', lpad(:sp,10)              val                        
  from sys.dual;

--
--  Load Profile

column dscr  format a28 newline;
column val   format 9,999,999,999,990.99;
column sval  format 99,990.99;
column svaln format 99,990.99 newline;
column totcalls new_value totcalls noprint
column pctval format 990.99;

select 'Load Profile'
      ,'~~~~~~~~~~~~                            Per Second       Per Transaction'
      ,'                                   ---------------       ---------------'
      ,'                  Redo size:' dscr, round(:rsiz/:ela,2)  val
                                          , round(:rsiz/:tran,2) val
      ,'              Logical reads:' dscr, round(:gets/:ela,2)  val
                                          , round(:gets/:tran,2) val
      ,'              Block changes:' dscr, round(:chng/:ela,2)  val
                                          , round(:chng/:tran,2) val
      ,'             Physical reads:' dscr, round(:phyr/:ela,2)  val
                                          , round(:phyr/:tran,2) val
      ,'            Physical writes:' dscr, round(:phyw/:ela,2)  val
                                          , round(:phyw/:tran,2) val
      ,'                 User calls:' dscr, round(:ucal/:ela,2)  val
                                          , round(:ucal/:tran,2) val
      ,'                     Parses:' dscr, round(:prse/:ela,2)  val
                                          , round(:prse/:tran,2) val
      ,'                Hard parses:' dscr, round(:hprs/:ela,2)  val
                                          , round(:hprs/:tran,2) val
      ,'                      Sorts:' dscr, round((:srtm+:srtd)/:ela,2)  val
                                          , round((:srtm+:srtd)/:tran,2) val
      ,'                     Logons:' dscr, round(:logc/:ela,2)  val
                                          , round(:logc/:tran,2) val
      ,'                   Executes:' dscr, round(:exe/:ela,2)   val
                                          , round(:exe/:tran,2)  val
      ,'               Transactions:' dscr, round(:tran/:ela,2)  val
      , '                           ' dscr
      ,'  % Blocks changed per Read:' dscr, round(100*:chng/:gets,2) pctval
      ,'   Recursive Call %:'     , round(100*:recr/:call,2) pctval
      ,' Rollback per transaction %:' dscr, round(100*:urol/:tran,2) pctval
      ,'      Rows per Sort:'     , decode((:srtm+:srtd)
						   ,0,to_number(null)
                                            ,round(:srtr/(:srtm+:srtd),2)) pctval
 from sys.dual;


--
--  Instance Efficiency Percentages

column ldscr  format a50

column nl format a60 newline;
select 'Instance Efficiency Percentages (Target 100%)' ldscr
      ,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' ldscr
      ,'            Buffer Nowait %:'                  dscr
      , round(100*(1-:bfwt/:gets),2)                   pctval
      ,'      Redo NoWait %:'     
      , decode(:rent,0,to_number(null), round(100*(1-:rlsr/:rent),2))  pctval
      ,'            Buffer  Hit   %:'                  dscr
      , round(100*(1-:phyr/:gets),2)                   pctval
      ,'   In-memory Sort %:'     
      , decode((:srtm+:srtd),0,to_number(null),
                               round(100*:srtm/(:srtd+:srtm),2))       pctval
      ,'            Library Hit   %:'                  dscr
      , round(100*:lhtr,2)                             pctval
      ,'       Soft Parse %:'     
      , round(100*(1-:hprs/:prse),2)                   pctval
      ,'         Execute to Parse %:'                  dscr
      , round(100*(1-:prse/:exe),2)                    pctval
      ,'        Latch Hit %:'     
      , round(100*(1-:lhr),2)                          pctval
      ,'Parse CPU to Parse Elapsd %:'                  dscr
      , decode(:prsela, 0, to_number(null)
                      , round(100*:prscpu/:prsela,2))  pctval
      ,'    % Non-Parse CPU:'
      , decode(:tcpu, 0, to_number(null)
                    , round(100*1-(:prscpu/:tcpu),2))  pctval
  from sys.dual;

select  ' Shared Pool Statistics        Begin   End'        nl
      , '                               ------  ------'
      , '             Memory Usage %:'                 dscr
      , 100*(1-:bfrm/:bspm)                            pctval
      , 100*(1-:efrm/:espm)                            pctval
      , '    % SQL with executions>1:'                 dscr
      , 100*(1-b.single_use_sql/b.total_sql)           pctval
      , 100*(1-e.single_use_sql/e.total_sql)           pctval
      , '  % Memory for SQL w/exec>1:'                 dscr
      , 100*(1-b.single_use_sql_mem/b.total_sql_mem)   pctval
      , 100*(1-e.single_use_sql_mem/e.total_sql_mem)   pctval
  from stats$sql_statistics b
     , stats$sql_statistics e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.dbid            = :dbid
   and e.dbid            = :dbid;


--
--

set heading on;
repfooter center -
   '-------------------------------------------------------------';

--
--  Top Wait Events

col idle     noprint;
col event    format a44          heading 'Top 5 Wait Events|~~~~~~~~~~~~~~~~~|Event';
col waits    format 999,999,990  heading 'Waits';
col time     format 999,999,990  heading 'Wait|Time (cs)' just c;
col pctwtt   format 999.99       heading '% Total|Wt Time';

select event
     , waits
     , time
     , pctwtt
  from (select e.event                               event
             , e.total_waits - nvl(b.total_waits,0)  waits
             , e.time_waited - nvl(b.time_waited,0)  time
             , decode(:twt, 0, 0,
                100*((e.time_waited - nvl(b.time_waited,0))/:twt))  pctwtt
          from stats$system_event b
             , stats$system_event e
         where b.snap_id(+)          = :bid
           and e.snap_id             = :eid
           and b.dbid(+)             = :dbid
           and e.dbid                = :dbid
           and b.instance_number(+)  = :inst_num
           and e.instance_number     = :inst_num
           and b.event(+)            = e.event
           and e.total_waits         > nvl(b.total_waits,0)
           and e.event not in
               ( select event
                   from stats$idle_event
               )
           order by time desc, waits desc
     )
where rownum <= &&top_n_events;


--
--

set space 1 termout on newpage 0;
whenever sqlerror exit;


--
--  System Events

ttitle lef 'Wait Events for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> cs - centisecond -  100th of a second' -
       skip 1 -
           '-> ms - millisecond - 1000th of a second' -
       skip 1 -
       lef '-> ordered by wait time desc, waits desc (idle events last)' -
       skip 2;

col idle noprint;
col event    format a28         heading 'Event' trunc;
col waits    format 999,999,990 heading 'Waits';
col timeouts format 9,999,990   heading 'Timeouts';
col time     format 99,999,990  heading 'Total Wait|Time (cs)';
col wt       format 99990       heading 'Avg|wait|(ms)';
col txwaits  format 990.0       heading 'Waits|/txn';

select e.event 
     , e.total_waits - nvl(b.total_waits,0)       waits
     , e.total_timeouts - nvl(b.total_timeouts,0) timeouts
     , e.time_waited - nvl(b.time_waited,0)       time
     , decode ((e.total_waits - nvl(b.total_waits, 0)),
                0, to_number(NULL),
                (e.time_waited - nvl(b.time_waited,0)) /
                (e.total_waits - nvl(b.total_waits,0))*10) wt
     , (e.total_waits - nvl(b.total_waits,0))/:tran txwaits
     , decode(i.event, null, 0, 99)               idle
  from stats$system_event b
     , stats$system_event e
     , stats$idle_event   i
 where b.snap_id(+)          = :bid
   and e.snap_id             = :eid
   and b.dbid(+)             = :dbid
   and e.dbid                = :dbid
   and b.instance_number(+)  = :inst_num
   and e.instance_number     = :inst_num
   and b.event(+)            = e.event
   and e.total_waits         > nvl(b.total_waits,0)
   and e.event       not like '%timer%'
   and e.event       not like 'rdbms ipc%'
   and i.event(+)            = e.event
 order by idle, time desc, waits desc;



--
--  Background process wait events

ttitle lef 'Background Wait Events for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> ordered by wait time desc, waits desc (idle events last)' -
       skip 2;

break on idle;
select e.event
     , e.total_waits - nvl(b.total_waits,0)                waits
     , e.total_timeouts - nvl(b.total_timeouts,0)          timeouts
     , e.time_waited - nvl(b.time_waited,0)                time
     , decode ((e.total_waits - nvl(b.total_waits, 0)),
               0, to_number(NULL),
               (e.time_waited - nvl(b.time_waited,0)) /
               (e.total_waits - nvl(b.total_waits,0))*10)  wt
     , (e.total_waits - nvl(b.total_waits,0))/:tran        txwaits
     , decode(i.event, null, 0, 99)                        idle
  from stats$bg_event_summary   b
     , stats$bg_event_summary   e
     , stats$idle_event         i
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.event(+)           = e.event
   and e.total_waits        > nvl(b.total_waits,0)
   and i.event(+)           = e.event
 order by idle, time desc, waits desc;
clear break;


--
--  SQL Reporting

col Execs     format 999,999,990    heading 'Executes';
col GPX       format 999,999,990.0  heading 'Gets|per Exec'  just c;
col RPX       format 999,999,990.0  heading 'Reads|per Exec' just c;
col RWPX      format 9,999,990.0    heading 'Rows|per Exec'  just c;
col Gets      format 9,999,999,990  heading 'Buffer Gets';
col Reads     format 9,999,999,990  heading 'Physical|Reads';
col Rw        format 9,999,999,990  heading 'Rows | Processed';
col hashval   format 99999999999    heading 'Hash Value';
col sql_text  format a500           heading 'SQL statement'  wrap;
col rel_pct   format 999.9          heading '% of|Total';
col shm       format 999,999,999    heading 'Sharable   |Memory (bytes)';
col vcount    format 9,999          heading 'Version|Count';

--
--  SQL statements ordered by buffer gets

ttitle lef 'SQL ordered by Gets for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> End Buffer Gets Threshold: '   ebgt -
       skip 1 -
           '-> Note that resources reported for PL/SQL includes the ' -
           'resources used by' skip 1 -
           '   all SQL statements called within the PL/SQL code.  As ' -
           'individual SQL'    skip 1 -
           '   statements are also reported, it is possible and valid ' -
           'for the summed'    skip 1 -
           '   total % to exceed 100' -
       skip 2;

-- Bug 1313544 requires this rather bizarre SQL statement

set underline off;
col aa format a80 heading -
'  Buffer Gets    Executions  Gets per Exec  % Total  Hash Value |--------------- ------------ -------------- ------- ------------' 
column hv noprint;
break on hv skip 1;

select aa, hv
  from ( select /*+ ordered */
          decode( st.piece
                , 0
                , lpad(to_char((e.buffer_gets - nvl(b.buffer_gets,0))
                               ,'99,999,999,999')
                      ,15)||' '||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad((to_char(decode(e.executions - nvl(b.executions,0)
                                     ,0, to_number(null)
                                     ,(e.buffer_gets - nvl(b.buffer_gets,0)) /
                                      (e.executions - nvl(b.executions,0)))
                               ,'999,999,990.0'))
                      ,14) ||' '||
                  lpad((to_char(100*(e.buffer_gets - nvl(b.buffer_gets,0))/:gets
                               ,'990.0'))
                      , 7) ||' '||
                  lpad(e.hash_value,12)||' '||
                  rpad(' ',15)||
                  st.sql_text
                , st.sql_text) aa
          , e.hash_value hv
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st 
      where b.snap_id(+)         = :bid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
      order by (e.buffer_gets - nvl(b.buffer_gets,0)) desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql;



--
--  SQL statements ordered by physical reads

ttitle lef 'SQL ordered by Reads for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> End Disk Reads Threshold: '   edrt -
       skip 2;

col aa format a80 heading -
' Physical Reads  Executions  Reads per Exec % Total  Hash Value |--------------- ------------ -------------- ------- ------------' 

select aa, hv
  from ( select /*+ ordered */
          decode( st.piece
                , 0
                , lpad(to_char((e.disk_reads - nvl(b.disk_reads,0))
                               ,'99,999,999,999')
                      ,15)||' '||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad((to_char(decode(e.executions - nvl(b.executions,0)
                                     ,0, to_number(null)
                                     ,(e.disk_reads - nvl(b.disk_reads,0)) /
                                      (e.executions - nvl(b.executions,0)))
                               ,'999,999,990.0'))
                      ,14) ||' '||
                  lpad((to_char(100*(e.disk_reads - nvl(b.disk_reads,0))/:phyr
                               ,'990.0'))
                      , 7) ||' '||
                  lpad(e.hash_value,12)||' '||
                  rpad(' ',15)||
                  st.sql_text
                , st.sql_text) aa
          , e.hash_value hv
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st 
      where b.snap_id(+)         = :bid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
        and :phyr                > 0
      order by (e.disk_reads - nvl(b.disk_reads,0)) desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql;



--
--  SQL statements ordered by executions

ttitle lef 'SQL ordered by Executions for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> End Executions Threshold: '   eet -
       skip 2;

col aa format a80 heading -
' Executions   Rows Processed    Rows per Exec   Hash Value |------------ ---------------- ---------------- ------------' 

select aa, hv
  from ( select /*+ ordered */
          decode( st.piece
                , 0
                , lpad(to_char((e.executions - nvl(b.executions,0))
                               ,'999,999,999')
                      ,12)||' '||
                  lpad(to_char((nvl(e.rows_processed,0) - nvl(b.rows_processed,0))
                              ,'999,999,999,999')
                      ,16)||' '||
                  lpad((to_char(decode(nvl(e.rows_processed,0) - nvl(b.rows_processed,0)
                                     ,0, 0
                                     ,(e.rows_processed - nvl(b.rows_processed,0)) /
                                      (e.executions - nvl(b.executions,0)))
                               ,'9,999,999,990.0'))
                      ,16) ||' '||
                  lpad(e.hash_value,12)||' '||
                  rpad(' ',20)||
                  st.sql_text
                , st.sql_text) aa
          , e.hash_value hv
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st 
      where b.snap_id(+)         = :bid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
      order by (e.executions - nvl(b.executions,0)) desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql;



--
--  SQL statements ordered by Sharable Memory

ttitle lef 'SQL ordered by Sharable Memory for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> End Sharable Memory Threshold: ' format 99999999 bsmt -
       skip 2;

col aa format a80 heading -
'Sharable Mem (b)  Executions  % Total  Hash Value |---------------- ------------ ------- ------------' 

select aa, hv
  from ( select /*+ ordered */
          decode( st.piece
                , 0
                , lpad(to_char( e.sharable_mem
                               ,'999,999,999,999')
                      ,16)||' '||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad((to_char(100*e.sharable_mem/:espm
                               ,'990.0'))
                      , 7) ||' '||
                  lpad(e.hash_value,12)||' '||
                  rpad(' ',29)||
                  st.sql_text
                , st.sql_text) aa
          , e.hash_value hv
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st 
      where b.snap_id(+)         = :bid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
        and e.sharable_mem       > :esmt
      order by e.sharable_mem desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql;



--
--  SQL statements ordered by Version Count

ttitle lef 'SQL ordered by Version Count for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '-> End Version Count Threshold: ' format 99999999 bvc -
       skip 2;

col aa format a80 heading -
' Version|   Count  Executions   Hash Value |-------- ------------ ------------' 

select aa, hv
  from ( select /*+ ordered */
          decode( st.piece
                , 0
                , lpad(to_char( e.version_count
                               ,'999,999')
                      ,8)||' '||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad(e.hash_value,12)||' '||
                  rpad(' ',45)||
                  st.sql_text
                , st.sql_text) aa
          , e.hash_value hv
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st 
      where b.snap_id(+)         = :bid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
        and e.version_count      > :evc
      order by e.version_count desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql;

set underline '-';



--
--  Instance Activity Statistics

ttitle lef 'Instance Activity Stats for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 2;

column st	format a33              heading 'Statistic' trunc;
column dif	format 999,999,999,990	heading 'Total';
column ps	format 9,999,990.9	heading 'per Second';
column pt       format 9,999,990.9      heading 'per Trans';

select b.name st
     , to_number(decode(instr(b.name,'current')
                     ,0,e.value - b.value,null)) dif
     , to_number(decode(instr(b.name,'current')
                       ,0,round((e.value - b.value) 
					/:ela,2),null)) ps
     , to_number(decode(instr(b.name,'current')
                       ,0,round((e.value - b.value) 
                                     /:tran,2),null)) pt
 from  stats$sysstat b
     , stats$sysstat e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.name            = e.name
   and e.value          >= b.value
   and e.value          >  0
 order by st;


--
--  Session Wait Events

ttitle lef 'Session Wait Events for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef 'Session Id: ' sess_id '  Serial#: ' serial -
       skip 1 -
       lef '-> ordered by wait time desc, waits desc (idle events last)' -
       skip 2;

select e.event 
     , e.total_waits - nvl(b.total_waits,0)       waits
     , e.total_timeouts - nvl(b.total_timeouts,0) timeouts
     , e.time_waited - nvl(b.time_waited,0)       time
     , decode ((e.total_waits - nvl(b.total_waits, 0)),
                0, to_number(NULL),
                (e.time_waited - nvl(b.time_waited,0)) /
                (e.total_waits - nvl(b.total_waits,0))*10) wt
     , (e.total_waits - nvl(b.total_waits,0))/:tran txwaits
     , decode(i.event, null, 0, 99)               idle
  from stats$session_event b
     , stats$session_event e
     , stats$idle_event    i
     , stats$snapshot      bs
     , stats$snapshot      es
 where b.snap_id             = :bid
   and e.snap_id             = :eid
   and b.dbid                = :dbid
   and e.dbid                = :dbid
   and b.instance_number     = :inst_num
   and e.instance_number     = :inst_num
   and b.event               = e.event
   and e.total_waits         > nvl(b.total_waits,0)
   and i.event(+)            = e.event
   and bs.snap_id            = b.snap_id
   and es.snap_id            = e.snap_id
   and bs.dbid               = b.dbid
   and es.dbid               = b.dbid
   and bs.dbid               = e.dbid
   and es.dbid               = e.dbid
   and bs.instance_number    = b.instance_number
   and es.instance_number    = b.instance_number
   and bs.instance_number    = e.instance_number
   and es.instance_number    = e.instance_number
   and bs.session_id         = es.session_id
   and bs.serial#            = es.serial#
 order by idle, time desc, waits desc;



--
--  Session Statistics

ttitle lef 'Session Statistics for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef 'Session Id: ' sess_id '  Serial#: ' serial -
       skip 2;


select lower(substr(ss.name,1,38)) st
     , to_number(decode(instr(ss.name,'current')
                     ,0,e.value - b.value,null)) dif
     , to_number(decode(instr(ss.name,'current')
                       ,0,round((e.value - b.value)
                                        /:ela,2),null)) ps
     , to_number(decode(instr(ss.name,'current')
                       ,0,decode(:strn, 
				 0, round(e.value - b.value), 
			            round((e.value - b.value)
                                     /:strn,2),null))) pt
  from stats$sesstat b
     , stats$sesstat e
     , stats$sysstat ss
     , stats$snapshot bs
     , stats$snapshot es
 where b.snap_id          = :bid
   and e.snap_id          = :eid
   and b.dbid             = :dbid
   and e.dbid             = :dbid
   and b.instance_number  = :inst_num
   and e.instance_number  = :inst_num
   and ss.snap_id         = :eid
   and ss.dbid            = :dbid
   and ss.instance_number = :inst_num
   and b.statistic#       = e.statistic#
   and ss.statistic#      = e.statistic#
   and e.value            > b.value
   and bs.snap_id         = b.snap_id
   and es.snap_id         = e.snap_id
   and bs.dbid            = b.dbid
   and es.dbid            = b.dbid
   and bs.dbid            = e.dbid
   and es.dbid            = e.dbid
   and bs.dbid            = ss.dbid
   and es.dbid            = ss.dbid
   and bs.instance_number = b.instance_number
   and es.instance_number = b.instance_number
   and bs.instance_number = ss.instance_number
   and es.instance_number = ss.instance_number
   and bs.instance_number = e.instance_number
   and es.instance_number = e.instance_number
   and bs.session_id      = es.session_id
   and bs.serial#         = es.serial#
 order by st;



--
--  Tablespace IO summary statistics

ttitle lef 'Tablespace IO Stats for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->ordered by IOs (Reads + Writes) desc' -
       skip 2;

col tsname     format a30           heading 'Tablespace';
col reads      format 9,999,999,990 heading 'Reads' newline;
col atpr       format 990.0         heading 'Av|Rd(ms)'     just c;
col writes     format 999,999,990   heading 'Writes';
col waits      format 9,999,990     heading 'Buffer|Waits'
col atpwt      format 990.0         heading 'Av Buf|Wt(ms)' just c;
col rps        format 99,999        heading 'Av|Reads/s'    just c;
col wps        format 99,999        heading 'Av|Writes/s'   just c;
col bpr        format 99.0          heading 'Av|Blks/Rd'    just c;
col ios        noprint

select e.tsname
     , sum (e.phyrds - nvl(b.phyrds,0))                     reads
     , sum (e.phyrds - nvl(b.phyrds,0))/:ela                rps
     , decode( sum(e.phyrds - nvl(b.phyrds,0))
             , 0, 0
             , (sum(e.readtim - nvl(b.readtim,0)) /
                sum(e.phyrds  - nvl(b.phyrds,0)))*10)       atpr
     , decode( sum(e.phyrds - nvl(b.phyrds,0))
             , 0, to_number(NULL)
             , sum(e.phyblkrd - nvl(b.phyblkrd,0)) / 
               sum(e.phyrds   - nvl(b.phyrds,0)) )          bpr
     , sum (e.phywrts    - nvl(b.phywrts,0))                writes
     , sum (e.phywrts    - nvl(b.phywrts,0))/:ela           wps
     , sum (e.wait_count - nvl(b.wait_count,0))             waits
     , decode (sum(e.wait_count - nvl(b.wait_count, 0))
            , 0, 0
            , (sum(e.time       - nvl(b.time,0)) / 
               sum(e.wait_count - nvl(b.wait_count,0)))*10) atpwt
     , sum (e.phyrds  - nvl(b.phyrds,0))  +  
       sum (e.phywrts - nvl(b.phywrts,0))                   ios
  from stats$filestatxs e
     , stats$filestatxs b
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  )  + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 group by e.tsname
union
select e.tsname                                             tbsp
     , sum (e.phyrds - nvl(b.phyrds,0))                     reads
     , sum (e.phyrds - nvl(b.phyrds,0))/:ela                rps
     , decode( sum(e.phyrds - nvl(b.phyrds,0))
             , 0, 0
             , (sum(e.readtim - nvl(b.readtim,0)) /
                sum(e.phyrds  - nvl(b.phyrds,0)))*10)       atpr
     , decode( sum(e.phyrds - nvl(b.phyrds,0))
             , 0, to_number(NULL)
             , sum(e.phyblkrd - nvl(b.phyblkrd,0)) / 
               sum(e.phyrds   - nvl(b.phyrds,0)) )          bpr
     , sum (e.phywrts    - nvl(b.phywrts,0))                writes
     , sum (e.phywrts    - nvl(b.phywrts,0))/:ela           wps
     , sum (e.wait_count - nvl(b.wait_count,0))             waits
     , decode (sum(e.wait_count - nvl(b.wait_count, 0))
            , 0, 0
            , (sum(e.time       - nvl(b.time,0)) / 
               sum(e.wait_count - nvl(b.wait_count,0)))*10) atpwt
     , sum (e.phyrds  - nvl(b.phyrds,0))  +  
       sum (e.phywrts - nvl(b.phywrts,0))                   ios
  from stats$tempstatxs e
     , stats$tempstatxs b
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  )  + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 group by e.tsname
 order by ios desc;



--
--  File IO statistics

ttitle lef 'File IO Stats for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->ordered by Tablespace, File' -
       skip 2;

col tsname     format a24           heading 'Tablespace';
col filename   format a52           heading 'Filename';
col reads      format 9,999,999,990 heading 'Reads'

break on tsname skip 1;

select e.tsname
     , e.filename
     , e.phyrds- nvl(b.phyrds,0)                       reads
     , (e.phyrds- nvl(b.phyrds,0))/:ela                rps
     , decode ((e.phyrds - nvl(b.phyrds, 0)), 0, to_number(NULL),
          ((e.readtim  - nvl(b.readtim,0)) /
           (e.phyrds   - nvl(b.phyrds,0)))*10)         atpr
     , decode ((e.phyrds - nvl(b.phyrds, 0)), 0, to_number(NULL),
          (e.phyblkrd - nvl(b.phyblkrd,0)) / 
          (e.phyrds   - nvl(b.phyrds,0)) )             bpr
     , e.phywrts - nvl(b.phywrts,0)                    writes
     , (e.phywrts - nvl(b.phywrts,0))/:ela             wps
     , e.wait_count - nvl(b.wait_count,0)              waits
     , decode ((e.wait_count - nvl(b.wait_count, 0)), 0, to_number(NULL),
          ((e.time       - nvl(b.time,0)) /
           (e.wait_count - nvl(b.wait_count,0)))*10)   atpwt
  from stats$filestatxs e
     , stats$filestatxs b
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  ) + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
union
select e.tsname
     , e.filename
     , e.phyrds- nvl(b.phyrds,0)                       reads
     , (e.phyrds- nvl(b.phyrds,0))/:ela                rps
     , decode ((e.phyrds - nvl(b.phyrds, 0)), 0, to_number(NULL),
          ((e.readtim  - nvl(b.readtim,0)) /
           (e.phyrds   - nvl(b.phyrds,0)))*10)         atpr
     , decode ((e.phyrds - nvl(b.phyrds, 0)), 0, to_number(NULL),
          (e.phyblkrd - nvl(b.phyblkrd,0)) / 
          (e.phyrds   - nvl(b.phyrds,0)) )             bpr
     , e.phywrts - nvl(b.phywrts,0)                    writes
     , (e.phywrts - nvl(b.phywrts,0))/:ela             wps
     , e.wait_count - nvl(b.wait_count,0)              waits
     , decode ((e.wait_count - nvl(b.wait_count, 0)), 0, to_number(NULL),
          ((e.time       - nvl(b.time,0)) /
           (e.wait_count - nvl(b.wait_count,0)))*10)   atpwt
  from stats$tempstatxs e
     , stats$tempstatxs b
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname 
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  ) + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 order by tsname, filename;



--
--  Buffer pools

ttitle lef 'Buffer Pool Statistics for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> Pools   D: default pool,  K: keep pool,  R: recycle pool' -
       skip 2;

col id      format 99            heading 'Set|Id';
col name    format a1            heading 'P|-' trunc;
col buffs   format 999,999,999   heading 'Buffer|Gets|-----------';
col conget  format 9,999,999,999 heading 'Consistent|Gets|-------------';
col phread  format 999,999,999   heading 'Physical|Reads|-----------';
col phwrite format 99,999,999    heading 'Physical|Writes|----------';
col fbwait  format 999,999       heading 'Free|Buffer|Waits|-------';
col wcwait  format 999,999       heading 'Write| Complete|Waits|--------';
col bbwait  format 99,999,999    heading 'Buffer|Busy|Waits|----------'

set colsep '' underline off;
select e.name                                        name
     , e.buf_got             - b.buf_got	     buffs
     , e.consistent_gets     - b.consistent_gets     conget
     , e.physical_reads      - b.physical_reads	     phread
     , e.physical_writes     - b.physical_writes     phwrite
     , e.free_buffer_wait    - b.free_buffer_wait    fbwait
     , e.write_complete_wait - b.write_complete_wait wcwait
     , e.buffer_busy_wait    - b.buffer_busy_wait    bbwait
  from stats$buffer_pool_statistics b
     , stats$buffer_pool_statistics e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.id              = e.id
 order by e.name;
set colsep ' ' underline on;



--
--  Buffer waits summary

set newpage 5;
ttitle lef 'Buffer wait Statistics for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> ordered by wait time desc, waits desc' -
       skip 2;

column class	                        heading 'Class';
column icnt	format 99,999,990	heading 'Waits';
column itim	format  9,999,990	heading 'Tot Wait|Time (cs)';
column iavg     format    999,990	heading 'Avg|Time (cs)' just c;

select e.class
     , e.wait_count  - nvl(b.wait_count,0)     icnt
     , e.time        - nvl(b.time,0)           itim
     , (e.time       - nvl(b.time,0)) / 
       (e.wait_count - nvl(b.wait_count,0))    iavg  
  from stats$waitstat b
     , stats$waitstat e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.class           = e.class
   and b.wait_count      < e.wait_count
 order by itim desc, icnt desc;



--
--  Enqueue activity

ttitle lef 'Enqueue activity for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> ordered by waits desc, gets desc' -
       skip 2;

col gets  format 999,999,990  heading 'Gets';
col ename format a10          heading 'Enqueue'
col waits format 9,999,990    heading 'Waits'

select e.name                   ename
     , e.gets - nvl(b.gets,0)   gets
     , e.waits - nvl(b.waits,0) waits
  from stats$enqueuestat b
     , stats$enqueuestat e
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.name(+)            = e.name
   and e.waits - nvl(b.waits,0) > 0
 order by waits desc, gets desc;
set newpage 0;



--
--  Rollback segment

ttitle lef 'Rollback Segment Stats for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->A high value for "Pct Waits" suggests more rollback segments may be required'-
       skip 2;

 
column usn      format 990	      heading 'RBS No' Just Cen;
column gets     format 9,999,990.9    heading 'Trans Table|Gets' Just Cen;
column waits    format 990.99         heading 'Pct|Waits';
column writes   format 99,999,999,990 heading 'Undo Bytes|Written' Just Cen;
column wraps    format 999,990        heading 'Wraps';
column shrinks  format 999,990        heading 'Shrinks';
column extends  format 999,990        heading 'Extends';
column rssize   format 99,999,999,990 heading 'Segment Size';
column active   format 99,999,999,990 heading 'Avg Active';
column optsize  format 99,999,999,990 heading 'Optimal Size';
column hwmsize  format 99,999,999,990 heading 'Maximum Size';

select b.usn
     , e.gets    - b.gets     gets
     , to_number(decode(e.gets ,b.gets, null,
       (e.waits  - b.waits) * 100/(e.gets - b.gets))) waits
     , e.writes  - b.writes   writes
     , e.wraps   - b.wraps    wraps
     , e.shrinks - b.shrinks  shrinks
     , e.extends - b.extends  extends
  from stats$rollstat b
     , stats$rollstat e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and e.usn             = b.usn
 order by e.usn;


ttitle lef 'Rollback Segment Storage for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->Optimal Size should be larger than Avg Active'-
       skip 2;

select b.usn                                                       
     , e.rssize
     , e.aveactive active
     , to_number(decode(e.optsize, -4096, null,e.optsize)) optsize
     , e.hwmsize
  from stats$rollstat b
     , stats$rollstat e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and e.usn             = b.usn
 order by e.usn;


--
--  Latch Activity

ttitle lef 'Latch Activity for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->"Get Requests", "Pct Get Miss" and "Avg Slps/Miss" are ' -
           'statistics for ' skip 1 -
           '  willing-to-wait latch get requests' -
       skip 1 -
       lef '->"NoWait Requests", "Pct NoWait Miss" are for ' -
           'no-wait latch get requests' -
       skip 1 -
       lef '->"Pct Misses" for both should be very close to 0.0'-
       skip 2;

column name    	format a29    	        heading 'Latch Name' trunc;
column gets   	format 9,999,999,990	heading 'Get|Requests';
column missed   format 990.9            heading 'Pct|Get|Miss';
column sleeps	format 990.9 	        heading 'Avg|Slps|/Miss';
column nowai	format 999,999,990	heading 'NoWait|Requests';
column imiss	format 990.9 	        heading 'Pct|NoWait|Miss';

select b.name                                            name
     , e.gets    - b.gets                                gets
     , to_number(decode(e.gets, b.gets, null,
       (e.misses - b.misses) * 100/(e.gets - b.gets)))   missed
     , to_number(decode(e.misses, b.misses, null,
       (e.sleeps - b.sleeps)/(e.misses - b.misses)))     sleeps
     , e.immediate_gets - b.immediate_gets               nowai
     , to_number(decode(e.immediate_gets,
			b.immediate_gets, null,
                        (e.immediate_misses - b.immediate_misses) * 100 /
	                (e.immediate_gets   - b.immediate_gets)))     imiss
 from  stats$latch b
     , stats$latch e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.name            = e.name
   and e.gets - b.gets   > 0
 order by name, sleeps;



--
--  Latch Sleep breakdown

ttitle lef 'Latch Sleep breakdown for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> ordered by misses desc'-
       skip 2;

column name    	 format a26    	        heading 'Latch Name' trunc;
column sleeps	 format 99,999,990 	heading 'Sleeps';
column spin_gets format 99,999,990 	heading 'Spin|Gets';
column misses    format 99,999,990 	heading 'Misses';
column sleep4 	 format a12 	        heading 'Spin &|Sleeps 1->4' just c;

select b.name                                      name
     , e.gets        - b.gets                      gets
     , e.misses      - b.misses                    misses
     , e.sleeps      - b.sleeps                    sleeps
     , to_char(e.spin_gets          - b.spin_gets)
       ||'/'||to_char(e.sleep1      - b.sleep1) 
       ||'/'||to_char(e.sleep2      - b.sleep2)
       ||'/'||to_char(e.sleep3      - b.sleep3)
       ||'/'||to_char(e.sleep4      - b.sleep4)    sleep4
  from stats$latch b
     , stats$latch e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.name            = e.name
   and e.sleeps - b.sleeps > 0
 order by misses desc;


--
--  Latch Miss sources

ttitle lef 'Latch Miss Sources for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> only latches with sleeps are shown' -
       skip 1 -
       lef '-> ordered by name, sleeps desc' -
       skip 2;

column parent        format a24       heading 'Latch Name' trunc;
column where_from    format a26       heading 'Where'      trunc;
column nwmisses      format 99,990    heading 'NoWait|Misses';
column sleeps	     format 9,999,990 heading '   Sleeps';
column waiter_sleeps format 99,999    heading 'Waiter|Sleeps';


select e.parent_name                              parent
     , e.where_in_code                            where_from
     , e.nwfail_count  - nvl(b.nwfail_count,0)    nwmisses
     , e.sleep_count   - nvl(b.sleep_count,0)     sleeps
     , e.wtr_slp_count - nvl(b.wtr_slp_count,0)   waiter_sleeps
  from stats$latch_misses_summary b
     , stats$latch_misses_summary e
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.parent_name(+)     = e.parent_name
   and b.where_in_code(+)   = e.where_in_code
   and e.sleep_count        > nvl(b.sleep_count,0)
 order by e.parent_name, sleeps desc;


--
--  Parent Latch

ttitle lef 'Parent Latch Statistics ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> only latches with sleeps are shown' -
       skip 1 -
       lef '-> ordered by name' -
       skip 2;

column name       format a29          heading 'Latch Name' trunc;

select l.name parent
     , lp.gets
     , lp.misses
     , lp.sleeps
     , lp.sleep4
  from (select e.instance_number, e.dbid, e.snap_id, e.latch#
             , e.gets        - b.gets                      gets
             , e.misses      - b.misses                    misses
             , e.sleeps      - b.sleeps                    sleeps
             , to_char(e.spin_gets          - b.spin_gets)
               ||'/'||to_char(e.sleep1      - b.sleep1) 
               ||'/'||to_char(e.sleep2      - b.sleep2)
               ||'/'||to_char(e.sleep3      - b.sleep3)
               ||'/'||to_char(e.sleep4      - b.sleep4)    sleep4
          from stats$latch_parent b
             , stats$latch_parent e
         where b.snap_id         = :bid
           and e.snap_id         = :eid
           and b.dbid            = :dbid
           and e.dbid            = :dbid
           and b.dbid            = e.dbid
           and b.instance_number = :inst_num
           and e.instance_number = :inst_num
           and b.instance_number = e.instance_number
           and b.latch#          = e.latch#
           and e.sleeps - b.sleeps > 0
       )            lp
     , stats$latch  l
 where l.snap_id         = lp.snap_id
   and l.dbid            = lp.dbid
   and l.instance_number = lp.instance_number
   and l.latch#          = lp.latch#
 order by name;


--
--  Latch Children

ttitle lef 'Child Latch Statistics ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '-> only latches with sleeps are shown' -
       skip 1 -
       lef '-> ordered by name, gets desc' -
       skip 2;

column name       format a22          heading 'Latch Name' trunc;
column child      format 99999        heading 'Child|Num';
column sleep4 	  format a13 	      heading 'Spin &|Sleeps 1->4' just c;

select l.name
     , lc.child
     , lc.gets
     , lc.misses
     , lc.sleeps
     , lc.sleep4
  from (select /*+ ordered use_hash(b) */
               e.instance_number, e.dbid, e.snap_id, e.latch#
             , e.child#                                    child
             , e.gets        - b.gets                      gets
             , e.misses      - b.misses                    misses
             , e.sleeps      - b.sleeps                    sleeps
             , to_char(e.spin_gets          - b.spin_gets)
               ||'/'||to_char(e.sleep1      - b.sleep1) 
               ||'/'||to_char(e.sleep2      - b.sleep2)
               ||'/'||to_char(e.sleep3      - b.sleep3)
               ||'/'||to_char(e.sleep4      - b.sleep4)    sleep4
          from stats$latch_children e
             , stats$latch_children b
         where b.snap_id         = :bid
           and e.snap_id         = :eid
           and b.dbid            = :dbid
           and e.dbid            = :dbid
           and b.dbid            = e.dbid
           and b.instance_number = :inst_num
           and e.instance_number = :inst_num
           and b.instance_number = e.instance_number
           and b.latch#          = e.latch#
           and b.child#          = e.child#
           and e.sleeps - b.sleeps > 0
       )            lc
     , stats$latch  l
 where l.snap_id         = lc.snap_id
   and l.dbid            = lc.dbid
   and l.instance_number = lc.instance_number
   and l.latch#          = lc.latch#
 order by name, gets desc;



--
--  Dictionary Cache

ttitle lef 'Dictionary Cache Stats for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
       lef '->"Pct Misses"  should be very low (< 2% in most cases)'-
       skip 1 -
       lef '->"Cache Usage" is the number of cache entries being used'-
       skip 1 -
       lef '->"Pct SGA"     is the ratio of usage to allocated size for that cache'-
       skip 2;

column param	format a22 	heading 'Cache'  trunc;
column gets	format 999,999,990	heading 'Get|Requests';
column getm	format 990.9	heading 'Pct|Miss';
column scans	format 999,990	heading 'Scan|Requests';
column scanm	format 90.9	heading 'Pct|Miss';
column mods	format 999,990	heading 'Mod|Req';
column usage	format 9,990	heading 'Final|Usage';
column sgapct	format 990 	heading 'Pct|SGA';

select lower(b.parameter)                                        param
     , e.gets - b.gets                                           gets
     , to_number(decode(e.gets,b.gets,null,
       (e.getmisses - b.getmisses) * 100/(e.gets - b.gets)))     getm
     , e.scans - b.scans                                         scans
     , to_number(decode(e.scans,b.scans,null,
       (e.scanmisses - b.scanmisses) * 100/(e.scans - b.scans))) scanm
     , e.modifications - b.modifications                         mods
     , e.usage                                                   usage
     , e.usage * 100/e.total_usage                               sgapct
  from stats$rowcache_summary b
     , stats$rowcache_summary e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.parameter       = e.parameter
 order by param;



--
--  Library Cache

set newpage 2;
ttitle lef 'Library Cache Activity for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 1 -
           '->"Pct Misses"  should be very low  ' skip 2;

column namespace                      heading 'Namespace';
column gets	format 999,999,990    heading 'Get|Requests';
column pins	format 9,999,999,990  heading 'Pin|Requests' just c;
column getm	format 990.9	      heading 'Pct|Miss' just c;
column pinm	format 990.9	      heading 'Pct|Miss' just c;
column reloads  format 9,999,990      heading 'Reloads';
column inv      format 999,990        heading 'Invali-|dations';

select b.namespace
     , e.gets - b.gets                                         gets  
     , to_number(decode(e.gets,b.gets,null,
       100 - (e.gethits - b.gethits) * 100/(e.gets - b.gets))) getm
     , e.pins - b.pins                                         pins  
     , to_number(decode(e.pins,b.pins,null,
       100 - (e.pinhits - b.pinhits) * 100/(e.pins - b.pins))) pinm
     , e.reloads - b.reloads                                   reloads
     , e.invalidations - b.invalidations                       inv
  from stats$librarycache b
     , stats$librarycache e
 where b.snap_id         = :bid   
   and e.snap_id         = :eid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.namespace       = e.namespace;



--
--  SGA

set newpage 0;
column name	format a30	  heading 'SGA regions';
column value	format 999,999,999,990 heading 'Size in Bytes';

break on report;
compute sum of value on report;
ttitle lef 'SGA Memory Summary for ' -
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 2;

select name
     , value
  from stats$sga
 where snap_id         = :eid
   and dbid            = :dbid
   and instance_number = :inst_num
 order by name;
clear break compute;

set newpage 2;
column name    format a30            heading 'SGA Component';
column b_value format 99,999,999,990 heading 'Start snap';
column e_value format 99,999,999,990 heading 'End snap';
column change  format 99,999,990     heading 'Change |End - Start' just cen;

ttitle lef 'SGA breakdown difference for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 2;

column pool heading 'Pool' format a11;
column name heading "Name" format a24;
column snap1 format 9,999,999,999  heading 'Begin value';
column snap2 format 9,999,999,999  heading 'End value';
column diff  format    99,999,999  heading 'Difference';

select b.pool            pool
     , b.name            name
     , b.bytes           snap1
     , e.bytes           snap2
     , e.bytes - b.bytes diff
  from stats$sgastat b
     , stats$sgastat e
 where e.snap_id         = :eid
   and b.snap_id         = :bid
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.dbid            = e.dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.instance_number = e.instance_number
   and b.name            = e.name
   and nvl(b.pool, 'a')  = nvl(e.pool, 'a')   
 order by b.pool, b.name;



--
--  Initialization Parameters

set newpage 0;
column name     format a29      heading 'Parameter Name'         trunc;
column bval     format a33      heading 'Begin value'            trunc;
column eval     format a14      heading 'End value|(if different)' trunc just c;
 
ttitle lef 'init.ora Parameters for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'Snaps: ' format 999999 begin_snap ' -' format 999999 end_snap -
       skip 2;

select e.name
     , b.value                                bval
     , decode(b.value, e.value, ' ', e.value) eval
  from stats$parameter b
     , stats$parameter e
 where b.snap_id(+)         = :bid
   and e.snap_id            = :eid
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.name(+)            = e.name
   and (   nvl(b.isdefault, 'X')   = 'FALSE'
        or nvl(b.ismodified,'X')  != 'FALSE'
        or     e.ismodified       != 'FALSE'
        or nvl(e.value,0)         != nvl(b.value,0)
       );

prompt
prompt                                 End of Report 
prompt
spool off;
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6;
undefine begin_snap
undefine end_snap
undefine report_name
undefine top_n_sql
undefine top_n_events
whenever sqlerror continue;

-- for Terry's profile
set linesize 132

--
--  End of script file;
