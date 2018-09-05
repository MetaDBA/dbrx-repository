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
define top_n_sql = 65;
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

prompt  STATSPACK Summary for

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
column blog       format 999,999;
column elog       format 999,999;
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
column bpctval  format 9990.99;

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
                                            ,round(:srtr/(:srtm+:srtd),2)) bpctval
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


--
--

set heading on;

--
--  Top Wait Events

col idle     noprint;
col event    format a44          heading 'Top 8 Wait Events|~~~~~~~~~~~~~~~~~|Event';
col waits    format 999,999,990  heading 'Waits';
col time     format 999,999,990  heading 'Wait|Time (cs)' just c;
col pctwtt   format 999.99       heading '% Total|Wt Time';
col total_wt_tm  format 999,999,990  heading 'Total Wait Time'


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


set heading off

select 'Total non-idle wait time for interval : ' || avg(:twt)/100 || ' seconds' total_wt_tm
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
);

prompt 

set heading on
--
--

-- set space 1 termout on newpage 0; whenever sqlerror exit;

--
--  Instance Activity Statistics


column st	format a33              heading 'CPU Used' trunc;
column dif	format 999,999,999,990	heading 'Total (sec)';
column ps	format 9,999,990.9	heading 'cs per Sec';
column pt       format 9,999,990.9      heading 'per Trans';

select substr(b.name,1,8) st
     , to_number(decode(instr(b.name,'current')
                     ,0,e.value - b.value,null)/100) dif
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
   and b.name like 'CPU used by this session'
;


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


repfooter center -
   '-------------------------------------------------------------';

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



prompt
prompt                                 End of Report 
prompt
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
