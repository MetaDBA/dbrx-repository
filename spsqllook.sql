Rem
Rem $Header: sprepsql.sql 17-may-2004.17:15:09 cdialeri Exp $
Rem
Rem sprepsql.sql
Rem
Rem Copyright (c) 2000, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sprepsql.sql - StatsPack REPort SQL
Rem
Rem    DESCRIPTION
Rem      Statspack SQL report to show resource usage, SQL Text
Rem      and any SQL Plans
Rem
Rem    NOTES
Rem      Usually run as the PERFSTAT user
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    05/13/04 - 3566569
Rem    spommere    02/14/02 - cleanup RAC stats that are no longer needed
Rem    spommere    02/08/02 - 2212357
Rem    cdialeri    01/30/02 - 2184717
Rem    cdialeri    01/16/02 - 2185967
Rem    dtahara     01/10/02 - 2175923: check if divisor is zero in sql stats
Rem    cdialeri    04/22/01 - 9.0
Rem    cdialeri    09/29/00 - Created
Rem

clear break compute;
repfooter off;
ttitle off;
btitle off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 2 recsep off;
set trimspool on trimout on;
define top_n_events = 5;
define top_n_sql = 65;
define num_rows_per_hash=5;

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
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
column para  noprint    heading 'Cluster'  new_value para;
column level format 99  heading 'Snap|Level';
column snap_id     format 99999990 heading 'Snap|Id';
column snapdat      	heading 'Snap Started' just c	format a17;
column comment          heading 'Comment' format a20;

break on inst_name on db_name on instart_fmt skip 1;

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


--
--  Ask for the Hash Value of the SQL statement to be reviewed

prompt
prompt Specify the Hash Value
prompt ~~~~~~~~~~~~~~~~~~~~~~
prompt Hash Value specified is: &&hash_value
prompt


set termout on;
variable bid   number;
variable eid   number;
variable versn varchar2(10);
variable para  varchar2(9);
variable host_name varchar2(64);
variable hash_value number;
begin 
  :bid    := &&begin_snap; 
  :eid    := &&end_snap;
  :versn  := '&versn';
  :para   := '&para';
  :host_name := '&host_name';
  :hash_value := &&hash_value;
end;
/


--
--  Verify begin and end snapshot Ids exist for the database, and that
--  there wasn't an instance shutdown in between the two snapshots 
--  being taken.

set heading off;
whenever sqlerror exit sql.sqlcode;

declare
  rowcount number;
begin

  select count(1)
    into rowcount
    from stats$database_instance
   where instance_number = :inst_num
     and dbid            = :dbid;
  if rowcount = 0 then
    raise_application_error(-20101, 'Database/Instance does not exist in STATS$DATABASE_INSTANCE');
  end if;

  select count(1)
    into rowcount
    from stats$snapshot b
   where b.snap_id         = :bid
     and b.dbid            = :dbid
     and b.instance_number = :inst_num;
  if rowcount = 0 then
    raise_application_error(-20101, 'Begin Snapshot Id specified does not exist for this database/instance');
  end if;

  select count(1)
    into rowcount
    from stats$snapshot e
   where e.snap_id         = :eid
     and e.dbid            = :dbid
     and e.instance_number = :inst_num;
  if rowcount = 0 then
    raise_application_error(-20101, 'End Snapshot Id specified does not exist for this database/instance');
  end if;

  select count(1)
    into rowcount
    from stats$snapshot b
       , stats$snapshot e
   where b.snap_id         = :bid
     and e.snap_id         = :eid
     and b.dbid            = :dbid
     and e.dbid            = :dbid
     and b.instance_number = :inst_num
     and e.instance_number = :inst_num
     and b.startup_time    = e.startup_time;
  if rowcount = 0 then
    raise_application_error(-20101, 'Snapshots chosen span an instance shutdown: RESULTS ARE INVALID');
  end if;

  select count(1)
    into rowcount
    from stats$sql_summary ss1
   where ss1.snap_id         = :eid
     and ss1.dbid            = :dbid
     and ss1.instance_number = :inst_num
     and ss1.hash_value      = :hash_value;
  if rowcount = 0 then
    raise_application_error(-20101, 'ERROR: Hash value chosen does not exist in end snapshot');
  end if;

end;
/


-- 
-- Get Text subset and module
column text_subset new_value text_subset noprint;
column module      new_value module      noprint;
select replace(text_subset, '''', '''''') text_subset
     , decode(module, null, ' '
                    , 'Module: ' || module) module
  from stats$sql_summary
 where snap_id         = :eid
   and dbid            = :dbid
   and instance_number = :inst_num
   and hash_value      = :hash_value;


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

set heading on;


--
-- Use report name if specified, otherwise prompt user for output file 
-- name (specify default), then begin spooling

set termout off;
column dflt_name new_value dflt_name noprint;
select 'sp_'||:bid||'_'||:eid||'_'||:hash_value dflt_name from dual;
set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name, 
prompt press <return> to continue, otherwise enter an alternative.

set heading off;
set heading on;


--
--

set newpage 1 heading on;


--
--  Call statspack to calculate certain statistics
--

variable text_subset varchar2(31);
variable module      varchar2(64);

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
variable phyrd  number;
variable phyrdl number;
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
variable bocur  number;
variable eocur  number;

variable dmsd   number;
variable dmfc   number;
variable dmsi   number;
variable pmrv   number;
variable pmpt   number;
variable npmrv   number;
variable npmpt   number;
variable dbfr   number;
variable dpms   number;
variable dnpms   number;
variable glsg   number;
variable glag   number;
variable glgt   number;
variable glsc   number;
variable glac   number;
variable glct   number;
variable glrl   number;
variable gcdfr  number;
variable gcge   number;
variable gcgt   number;
variable gccv   number;
variable gcct   number;
variable gccrrv   number;
variable gccrrt   number;
variable gccurv   number;
variable gccurt   number;
variable gccrsv   number;
variable gccrbt   number;
variable gccrft   number;
variable gccrst   number;
variable gccusv   number;
variable gccupt   number;
variable gccuft   number;
variable gccust   number;
variable msgsq    number;
variable msgsqt   number;
variable msgsqk   number;
variable msgsqtk  number;
variable msgrq    number;
variable msgrqt   number;

begin
  STATSPACK.STAT_CHANGES
   ( :bid,    :eid
   , :dbid,   :inst_num
   , :para                 -- End of IN arguments
   , :lhtr,   :bfwt
   , :tran,   :chng
   , :ucal,   :urol
   , :rsiz
   , :phyr,   :phyrd
   , :phyrdl
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
   , :bspm,   :espm
   , :bfrm, :efrm
   , :blog,   :elog
   , :bocur,  :eocur
   , :dmsd,   :dmfc    -- Begin of RAC
   , :dmsi
   , :pmrv,   :pmpt 
   , :npmrv,  :npmpt 
   , :dbfr
   , :dpms,   :dnpms 
   , :glsg,   :glag 
   , :glgt,   :glsc 
   , :glac,   :glct 
   , :glrl,   :gcdfr
   , :gcge,   :gcgt 
   , :gccv,   :gcct
   , :gccrrv, :gccrrt 
   , :gccurv, :gccurt 
   , :gccrsv
   , :gccrbt, :gccrft 
   , :gccrst, :gccusv 
   , :gccupt, :gccuft 
   , :gccust
   , :msgsq,  :msgsqt
   , :msgsqk, :msgsqtk
   , :msgrq,  :msgrqt           -- End RAC
   );
   :call := :ucal + :recr;

   :module      := '&module';
   :text_subset := '&text_subset';

end;
/



--
--  Summary Statistics
--

--
--  Print database, instance, parallel, release, host and snapshot
--  information

prompt
prompt  STATSPACK SQL report for Hash Value: &&hash_value  &&module

set heading on;
column host_name heading "Host"     format a12 print;
column para      heading "Cluster"  format a7  print;
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

column instart_fmt new_value INSTART_FMT noprint;
column instart    new_value instart noprint;
column session_id new_value SESSION noprint;
column ela        new_value ELA     noprint;
column btim       new_value btim    heading 'Start Time' format a19 just c;
column etim       new_value etim    heading 'End Time'   format a19 just c;
column bid                          heading 'Start Id'         format 99999990;
column eid                          heading '  End Id'         format 99999990;
column dur        heading 'Duration(mins)' format 999,990.00 just r;
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
column ocs        format 99,999.0;
column nl         newline;

select b.snap_id                            bid
     , to_char(b.snap_time, 'dd-Mon-yy hh24:mi:ss')             btim
     , e.snap_id                                                eid
     , to_char(e.snap_time, 'dd-Mon-yy hh24:mi:ss')             etim
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)/60   dur  -- mins
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

--
--  SQL Reporting

col Gets      format 9,999,999,990  heading 'Buffer Gets';
col Reads     format 9,999,999,990  heading 'Physical|Reads';
col Rw        format 9,999,999,990  heading 'Rows | Processed';
col pc        format 9,999,999,999  heading 'Parse|Calls'
col cput      format 9,999,999,999  heading 'CPU Time'
col elat      format 9,999,999,999  heading 'Ela Time'
col Execs     format 9,999,999,990  heading 'Executes';
col shm       format 9,999,999,999  heading 'Sharable   |Memory (bytes)';
col vcount    format 9,999,999,999  heading 'Version|Count';
col sorts     format 9,999,999,999  heading 'Sorts'
col inv       format 9,999,999,999  heading 'Invali-|dations';

col GPX       format 9,999,999,990.0  heading 'Gets|per Exec'  just c;
col RPX       format 9,999,999,990.0  heading 'Reads|per Exec' just c;
col RWPX      format 9,999,999,990.0  heading 'Rows|per Exec'  just c;
col PPX       format 9,999,999,999.0  heading 'Parses|per Exec' just c;
col cpupx     format 9,999,999,999.0  heading 'CPU|per Exec'   just c;
col elapx     format 9,999,999,999.0  heading 'Ela|per Exec'   just c;
col spx       format 9,999,999,999.0  heading 'Sorts|per Exec' just c;

col ptg       format 999.99           heading '%Total|Gets';
col ptr       format 999.99           heading '%Total|Reads';

col hashval   format 99999999999    heading 'Hash Value';
col sql_text  format a500           heading 'SQL statement:'  wrap;
col rel_pct   format 999.9          heading '% of|Total';

column lhead  format a21 newline;

--
-- Show SQL statistics

set heading off;

select 'SQL Statistics'                                     nl
     , '~~~~~~~~~~~~~~'                                     nl
     , '-> CPU and Elapsed Time are in seconds (s) for Statement Total and in' nl
     , '   milliseconds (ms) for Per Execute'                           nl
     , '                                                       % Snap'  nl
     , '                     Statement Total      Per Execute   Total'  nl
     , '                     ---------------  ---------------  ------'  nl
     , '        Buffer Gets: '                              lhead
     , e.buffer_gets - nvl(b.buffer_gets,0)                 gets
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.buffer_gets - nvl(b.buffer_gets,0))
              / (e.executions - nvl(b.executions,0)))       gpx
     , decode(:gets
             , 0, to_number(null)
             , 100*(e.buffer_gets - nvl(b.buffer_gets,0))
              /:gets)                                       ptg
     , '         Disk Reads: '                              lhead
     , e.disk_reads - nvl(b.disk_reads,0)                   reads
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.disk_reads - nvl(b.disk_reads,0))
              / (e.executions - nvl(b.executions,0)))       rpx
     , decode(:phyr
             , 0, to_number(null)
             , 100*(e.disk_reads - nvl(b.disk_reads,0))
              /:phyr)                                       ptr
     , '     Rows processed: '                              lhead
     , e.rows_processed - nvl(b.rows_processed,0)           rw
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.rows_processed - nvl(b.rows_processed,0))
              / (e.executions - nvl(b.executions,0)))       rwpx
     , '     CPU Time(s/ms): '                              lhead
     , (e.cpu_time - nvl(b.cpu_time,0))/1000000             cput
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  ((e.cpu_time - nvl(b.cpu_time,0))/1000)
              /  (e.executions - nvl(b.executions,0)))      cpupx
     , ' Elapsed Time(s/ms): '                              lhead
     , (e.elapsed_time - nvl(b.elapsed_time,0))/1000000     elat
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  ((e.elapsed_time - nvl(b.elapsed_time,0))/1000)
              /  (e.executions - nvl(b.executions,0)))      elapx
     , '              Sorts: '                              lhead
     , e.sorts - nvl(b.sorts,0)                             sorts
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.sorts - nvl(b.sorts,0))
              / (e.executions - nvl(b.executions,0)))       spx
     , '        Parse Calls: '                              lhead
     , e.parse_calls - nvl(b.parse_calls,0)                 pc
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.parse_calls - nvl(b.parse_calls,0))
              / (e.executions - nvl(b.executions,0)))       ppx
     , '      Invalidations: '                              lhead
     , e.invalidations - nvl(b.invalidations,0)             inv
     , '      Version count: '                              lhead
     , e.version_count                                      vcount
     , '    Sharable Mem(K): '                              lhead
     , e.sharable_mem/1024                                  shm
     , '         Executions: '                              lhead
     , e.executions - nvl(b.executions,0)                   execs
  from stats$sql_summary e
     , stats$sql_summary b
 where b.snap_id(+)         = :bid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = e.instance_number
   and b.hash_value(+)      = e.hash_value
   and b.address(+)         = e.address
   and b.text_subset(+)     = e.text_subset
   and e.snap_id            = :eid
   and e.dbid               = :dbid
   and e.instance_number    = :inst_num
   and e.hash_value         = :hash_value;



--
--  Show complete SQL Text

ttitle lef 'SQL Text' -
       skip 1 -
       lef '~~~~~~~~' -
       skip 1;

select st.sql_text
  from stats$sql_summary e
     , stats$sqltext    st
 where e.snap_id            = :eid
   and e.dbid               = :dbid
   and e.instance_number    = :inst_num
   and e.hash_value         = :hash_value
   and st.text_subset       = e.text_subset
   and st.hash_value        = e.hash_value
order by st.piece;

set heading on;



--
-- Show Plan Hash Values for all known Plans

ttitle lef 'Known Optimizer Plan(s) for this Hash Value' -
       skip 1 -
       lef '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       lef 'Shows all known Optimizer Plans for this database instance, and the Snap Id''s' -
       skip 1 -
       lef 'they were first found in the shared pool.  A Plan Hash Value will appear' -
       skip 1 -
       lef 'multiple times if the cost has changed' -
       skip 1 -
       lef '-> ordered by Snap Id' -
       skip 2;

column plan_hash_value format 99999999999 heading 'Plan|Hash Value' just c;
column snap_id         format 9999999     heading 'First|Snap Id' just c;
column cost            format a10         heading 'Cost' just r;
column optimizer                          heading 'Optimizer';
column snap_time       format a15         heading 'First|Snap Time' just c;

select fsp.snap_id
     , to_char(s.snap_time, 'DD Mon YY HH24:MI') snap_time
     , fsp.plan_hash_value
     , lpad(decode(fsp.cost
                  , null, ' '
                  , -9,   ' '
                  , decode(  sign(cost-10000000)
                           , -1, cost||' '
                           , decode(  sign(cost-1000000000), -1, trunc(cost/1000000)||'M'
                                    , trunc(cost/1000000000)||'G'
                                   )
                          )
                  ), 10) cost
  from (select min(snap_id) snap_id
             , dbid
             , instance_number
             , plan_hash_value
             , cost
          from stats$sql_plan_usage spu
         where hash_value      = &&hash_value
           and text_subset     = '&&text_subset'
           and dbid            = &&dbid
           and instance_number = &&inst_num
         group by plan_hash_value, cost, dbid, instance_number
       ) fsp
       , stats$snapshot s
 where s.snap_id(+)             = fsp.snap_id
   and s.dbid(+)                = fsp.dbid
   and s.instance_number(+)     = fsp.instance_number
 order by fsp.snap_id, fsp.plan_hash_value;



--
--  Show all known Plans used between Snap Ids specified

ttitle lef 'Plans in shared pool between Begin and End Snap Ids' -
       skip 1 -
       lef '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       lef 'Shows the Execution Plans found in the shared pool between the begin and end' -
       skip 1 -
       lef 'snapshots specified.  The values for Rows, Bytes and Cost shown below are those' -
       skip 1 -
       lef 'which existed at the time the first-ever snapshot captured this plan - these' -
       skip 1 -
       lef 'values often change over time, and so may not be indicative of current values' -
       skip 1 -
       lef '-> Rows indicates Cardinality, PHV is Plan Hash Value' -
       skip 1 -
       lef '-> ordered by Plan Hash Value' -
       skip 2;

set heading off;

select '--------------------------------------------------------------------------------' from dual
union all
select '| Operation                      | PHV/Object Name     |  Rows | Bytes|   Cost |'  as "Optimizer Plan:" from dual
union all
select '--------------------------------------------------------------------------------' from dual
union all
select *
  from (select
       rpad('|'||substr(lpad(' ',1*(depth-1))||operation||
            decode(options, null,'',' '||options), 1, 32), 33, ' ')||'|'||
       rpad(decode(id, 0, '----- '||to_char(plan_hash_value)||' -----'
                     , substr(decode(substr(object_name, 1, 7), 'SYS_LE_', null, object_name)
                       ||' ',1, 20)), 21, ' ')||'|'||
       lpad(decode(cardinality,null,'  ',
                decode(sign(cardinality-1000), -1, cardinality||' ', 
                decode(sign(cardinality-1000000), -1, trunc(cardinality/1000)||'K', 
                decode(sign(cardinality-1000000000), -1, trunc(cardinality/1000000)||'M', 
                       trunc(cardinality/1000000000)||'G')))), 7, ' ') || '|' ||
       lpad(decode(bytes,null,' ',
                decode(sign(bytes-1024), -1, bytes||' ', 
                decode(sign(bytes-1048576), -1, trunc(bytes/1024)||'K', 
                decode(sign(bytes-1073741824), -1, trunc(bytes/1048576)||'M', 
                       trunc(bytes/1073741824)||'G')))), 6, ' ') || '|' ||
       lpad(decode(cost,null,' ',
                decode(sign(cost-10000000), -1, cost||' ', 
                decode(sign(cost-1000000000), -1, trunc(cost/1000000)||'M', 
                       trunc(cost/1000000000)||'G'))), 8, ' ') || '|' as "Explain plan"
          from stats$sql_plan
         where plan_hash_value in (select plan_hash_value
                                     from stats$sql_plan_usage spu
                                    where spu.snap_id   between :bid and :eid
                                      and spu.dbid            = :dbid
                                      and spu.instance_number = :inst_num
                                      and spu.hash_value      = :hash_value
                                      and text_subset         = :text_subset
                                      and spu.plan_hash_value > 0
                                  )
          order by plan_hash_value, id
)
union all
select '--------------------------------------------------------------------------------' from dual;

set heading on;


--
--

prompt
prompt                                 End of Report 
prompt
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;
undefine begin_snap
undefine end_snap
undefine top_n_sql
undefine top_n_events
undefine hash_value
whenever sqlerror continue;

--
--  End of script file;
