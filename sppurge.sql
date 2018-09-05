Rem
Rem $Header: sppurge.sql 11-apr-00.11:45:52 cdialeri Exp $
Rem
Rem sppurge.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      sppurge.sql - STATSPACK Purge
Rem
Rem    DESCRIPTION
Rem      Purge a range of Snapshot Id's between the specified
Rem      begin and end Snap Id's
Rem
Rem    NOTES
Rem      Should be run as STATSPACK user, PERFSTAT.
Rem
Rem      Running purge may require the use of a large rollback
Rem      segment; to avoid rollback segment related errors
Rem      explicitly specify a large rollback segment before running
Rem      this script by using the 'set transaction use rollback segment..'
Rem      command, or alternatively specify a smaller range of 
Rem      Snapshot Id's to purge.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    04/11/00 - 1261813
Rem    cdialeri    03/15/00 - Conform to new structure
Rem    densor.uk   05/00/94 - Allow purge of range of snaps
Rem    gwood.uk    10/12/92 - Use RI for deletes to most tables
Rem    cellis.uk   11/15/89 - Created
Rem

set feedback off verify off pages 999
undefine dbid inst_num losnapid hisnapid
whenever sqlerror exit rollback

spool sppurge.lis


/* ------------------------------------------------------------------------- */

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

prompt
prompt
prompt Database Instance currently connected to
prompt ========================================

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance|Name"  new_value inst_name format a10;
column db_name   heading "DB Name"   new_value db_name   format a10;
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
--  List Snapshots

column snap_id       format 9999990 heading 'Snap Id'
column snap_date     format a21	  heading 'Snapshot Started'
column host_name     format a15   heading 'Host'
column parallel      format a3    heading 'OPS' trunc
column level         format 99    heading 'Snap|Level'
column versn         format a7    heading 'Release'
column ucomment          heading 'Comment' format a25;

prompt
prompt
prompt Snapshots for this database instance
prompt ====================================

select s.snap_id
     , s.snap_level                                      "level"
     , to_char(s.snap_time,' dd Mon YYYY HH24:mi:ss')    snap_date
     , di.host_name                                      host_name
     , s.ucomment
  from stats$snapshot s
     , stats$database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and s.instance_number   = :inst_num
   and di.instance_number  = :inst_num
   and di.startup_time     = s.startup_time
 order by db_name, instance_name, snap_id;



--
--  Post warning

prompt
prompt
prompt Warning
prompt ~~~~~~~
prompt sppurge.sql deletes all snapshots ranging between the lower and
prompt upper bound Snapshot Id's specified, for the database instance
prompt you are connected to.
prompt
prompt You may wish to export this data before continuing.
prompt



--
--  Obtain snapshot ranges

prompt
prompt Specify the Lo Snap Id and Hi Snap Id range to purge
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Using &&LoSnapId for lower bound.
prompt
prompt Using &&HiSnapId for upper bound.

variable lo_snap   number;
variable hi_snap   number;
begin 
  :lo_snap   :=  &losnapid;
  :hi_snap   :=  &hisnapid; 
end;
/

set heading off

select 'WARNING: LoSnapId or HiSnapId specified does not exist in STATS$SNAPSHOT'
  from dual
 where not exists
      (select null
         from stats$snapshot
        where instance_number = :inst_num
          and dbid            = :dbid
          and snap_id         = :lo_snap)
    or not exists
      (select null
         from stats$snapshot
        where instance_number = :inst_num
          and dbid            = :dbid
          and snap_id         = :hi_snap);

set heading on



--
--  Delete all data for the specified ranges

/*  Use RI to delete parent snapshot and all child records  */

prompt
prompt Deleting snapshots &&losnapid - &&hisnapid..
delete from stats$snapshot
 where instance_number = :inst_num
   and dbid            = :dbid
   and snap_id between :lo_snap and :hi_snap;


set termout off;
/*  Delete any dangling SQLtext  */
/*
Rem  The following statement deletes any dangling SQL statements which
Rem  are no longer referred to by ANY snapshots.  This statment has been
Rem  commented out as it can be very resource intensive. 

alter session set hash_area_size=1048576;
delete /*+ index_ffs(st) 
  from stats$sqltext st
 where (hash_value, text_subset) not in
       (select /*+ hash_aj full(ss) no_expand 
               hash_value, text_subset
          from stats$sql_summary ss
         where (   (   snap_id     < :lo_snap
                    or snap_id     > :hi_snap
                   )
                   and dbid            = :dbid
                   and instance_number = :inst_num
               )
            or (   dbid            != :dbid
                or instance_number != :inst_num)
        );
*/
set termout on;


/*  Delete any dangling database instance rows for that startup time  */

delete from stats$database_instance di
 where instance_number = :inst_num
   and dbid            = :dbid
   and not exists (select 1
                     from stats$snapshot s
                    where s.dbid            = di.dbid
                      and s.instance_number = di.instance_number
                      and s.startup_time    = di.startup_time);



/*  Delete any dangling statspack parameter rows for the database instance  */

delete from stats$statspack_parameter sp
 where instance_number = :inst_num
   and dbid            = :dbid
   and not exists (select 1
                     from stats$snapshot s
                    where s.dbid            = sp.dbid
                      and s.instance_number = sp.instance_number);


--
--

prompt
prompt
prompt Purge of specified Snapshot range complete.  If you wish to ROLLBACK 
prompt the purge, it is still possible to do so.  Exitting from SQL*Plus will 
prompt automatically commit the purge.
prompt

--
--

spool off
set feedback on termout on
whenever sqlerror continue
