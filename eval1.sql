-- ******************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : eval1.sql - Version 1.0
-- * Author             : Craig A. Shallahamer
-- * Original           : 01-APR-99
-- * Last Modified      : 17-may-99
-- * Description        : Run OSM scripts for system perf eval
-- * Usage              : start eval1.sql
-- ******************************************************

set pagesize 40
set echo off
set feedback off

prompt Press ENTER if prompted for anything.
accept x

start sga.sql
start bc7.sql
start tss.sql
start users.sql
start chr.sql
start lc.sql
start rbs.sql
start dfl.sql
start ip.sql
start stu.sql
start dfio.sql
start latch.sql
start mts.sql
start sesstat.sql
start sysstat.sql
start swsw.sql
start swswc.sql
start swswp.sql %
start swsys.sql
start swenq.sql
start sqls1.sql 1000 1000
