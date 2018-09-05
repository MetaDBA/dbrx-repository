rem 
rem $Header: utllockt.sql 7020100.1 94/09/23 22:14:28 cli Generic<base> $ locktree.sql 
rem 
Rem Copyright (c) 1989 by Oracle Corporation
Rem NAME
REM    UTLLOCKT.SQL
Rem  FUNCTION   - Print out the lock wait-for graph in tree structured fashion.
Rem               This is useful for diagnosing systems that are hung on locks.
Rem  NOTES
Rem  MODIFIED
Rem     glumpkin   10/20/92 -  Renamed from LOCKTREE.SQL 
Rem     jloaiza    05/24/91 - update for v7 
Rem     rlim       04/29/91 - change char to varchar2 
Rem     Loaiza     11/01/89 - Creation
Rem

Rem Print out the lock wait-for graph in a tree structured fashion.
Rem  
Rem This script  prints  the  sessions in   the system  that  are waiting for
Rem locks,  and the locks that they  are waiting for.   The  printout is tree
Rem structured.  If a sessionid is printed immediately below and to the right
Rem of another session, then it is waiting for that session.  The session ids
Rem printed at the left hand side of the page are  the ones  that everyone is
Rem waiting for.
Rem  
Rem For example, in the following printout session 9 is waiting for
Rem session 8, 7 is waiting for 9, and 10 is waiting for 9.
Rem  
Rem WAITING_SESSION   TYPE MODE REQUESTED    MODE HELD         LOCK ID1 LOCK ID2
Rem ----------------- ---- ----------------- ----------------- -------- --------
Rem 8                 NONE None              None              0         0
Rem    9              TX   Share (S)         Exclusive (X)     65547     16
Rem       7           RW   Exclusive (X)     S/Row-X (SSX)     33554440  2
Rem       10          RW   Exclusive (X)     S/Row-X (SSX)     33554440  2
Rem  
Rem The lock information to the right of the session id describes the lock
Rem that the session is waiting for (not the lock it is holding).
Rem  
Rem Note that  this is a  script and not a  set  of view  definitions because
Rem connect-by is used in the implementation and therefore  a temporary table
Rem is created and dropped since you cannot do a join in a connect-by.
Rem  
Rem This script has two  small disadvantages.  One, a  table is created  when
Rem this  script is run.   To create  a table   a  number of   locks must  be
Rem acquired. This  might cause the session running  the script to get caught
Rem in the lock problem it is trying to diagnose.  Two, if a session waits on
Rem a lock held by more than one session (share lock) then the wait-for graph
Rem is no longer a tree  and the  conenct-by will show the session  (and  any
Rem sessions waiting on it) several times.
Rem


Rem Select all sids waiting for a lock, the lock they are waiting on, and the
Rem sid of the session that holds the lock.
Rem  UNION
Rem The sids of all session holding locks that someone is waiting on that
Rem are not themselves waiting for locks. These are included so that the roots
Rem of the wait for graph (the sessions holding things up) will be displayed.
Rem

set feed off
set line 999
set head off
set pages 999

create table LOCK_HOLDERS
(
  waiting_session   number,
  holding_session   number,
  lock_type         varchar2(26),
  mode_held         varchar2(40),
  mode_requested    varchar2(40),
  lock_id1          number,
  object_name1      varchar2(30),
  lock_id2          number,
  object_name2      varchar2(30),
  pid               varchar2(11),
  osuser            varchar2(12)
);

create table dba_locks_temp as select * from sys.dba_lock;

select to_char( sysdate, 'MM-DD-YYYY HH24:MI:SS' ) from dual;

Rem This is essentially a copy of the dba_waiters view but runs faster since
Rem it caches the result of selecting from dba_locks.

insert into lock_holders 
  select w.session_id,
         h.session_id,
         w.lock_type,
         w.mode_held,
         w.mode_requested,
         to_number( w.lock_id1 ),
         id1.object_name,
         to_number( w.lock_id2 ),
         id2.object_name,
         process,
         osuser
  from v$session, all_objects id1, all_objects id2,
       dba_locks_temp w, dba_locks_temp h
 where h.mode_held      !=  'None'
  and  h.mode_held      !=  'Null'
  and  w.mode_requested !=  'None'
  and  w.lock_type       =  h.lock_type
  and  w.lock_id1        =  h.lock_id1
  and  w.lock_id2        =  h.lock_id2
  and  id1.object_id (+) =  w.lock_id1
  and  id2.object_id (+) =  w.lock_id2
  and  v$session.sid     =  w.session_id;

commit;

drop table dba_locks_temp;

insert into lock_holders 
  select holding_session, null, 'None', null, null,
         lock_id1, null, null, null, null, null
    from lock_holders 
 minus
  select waiting_session, null, 'None', null, null,
         lock_id1, null, null, null, null, null
    from lock_holders;

update lock_holders
  set ( mode_held, object_name1, pid, osuser ) =
    ( select sys.dba_lock.mode_held,
             all_objects.object_name,
             v$session.process,
             v$session.osuser
         from all_objects, sys.dba_lock, v$session
        where sys.dba_lock.session_id   = v$session.sid
          and sys.dba_lock.lock_id1     = lock_holders.lock_id1
          and all_objects.object_id (+) = sys.dba_lock.lock_id1
          and v$session.sid             = lock_holders.waiting_session )
  where holding_session IS null;

commit;

/* Print out the result in a tree structured fashion */
set head on
column Session format a10;
column Held format a4;
column Req format a12;
column "Table Name" format a20;
select  lpad(' ',2*(level-1)) || waiting_session "Session",
	decode( mode_requested,
                'Exclusive',     'X',
                'Row-X (SX)',    'RX',
                'S/Row-X (SSX)', 'SRX',
                'Share',         'S',
                mode_requested ) "Req",
	decode( mode_held,
                'Exclusive',     'X',
                'Row-X (SX)',    'RX',
                'S/Row-X (SSX)', 'SRX',
                'Share',         'S',
                mode_held )      "Held",
        lock_id1 "Lock Id",
	object_name1 "Table Name",
        pid "Process",
        osuser "User"
 from lock_holders
connect by  prior waiting_session =
                    DECODE( holding_session,
                            waiting_session, null,
                            holding_session )
        and prior lock_id1  = lock_id1
  start with holding_session is null;

drop table lock_holders;
