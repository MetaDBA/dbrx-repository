-- ********************************************************************
-- * Copyright Notice  : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename          : osmi.sql
-- * Author            : Craig Shallahamer
-- * Original          : 24-SEP-98
-- * Last Update       : 08-jun-01
-- * Description       : OSM-Interactive menu
-- * Usage             : start osmi.sql
-- ********************************************************************

prompt OraPub System Monitor - Interactive Menu
prompt (c)2001 OraPub, Inc. - Free use, just keep company and author name
prompt 
prompt obcrobj  Create object growth objects
prompt ogbigld  Load selected objects into Object Growth tables (will prompt)
prompt ogobjset Set object(s) obj growth specifics
prompt ogdoit   Load growth management data for scheduled objects
prompt ogwhich  ID object owner and name in dba_objects and o$dba_objects
prompt ogobjlst List objects in Object Growth schedule
prompt 
prompt cu       Create an Oracle user (<uid> <pwd> <dft tbs> <dft tmp tbs> <prof>)
prompt users    Summary info about Oracle users
prompt tp       Top Oracle users/processes (will be prompted)
prompt
prompt rbs      Rollback configuration details
prompt tss      Tablespace space details *working*
prompt dfl      Database file listing
prompt tsmap    Tablespace map detail (<tbs name>)
prompt stu      Segment types and size per user summary
prompt idx      Index columns (<owner> <table>)
prompt
prompt istat    Index statistics (<owner> <index>)
prompt fgtbl    Table frag (<owner> <tblname>)
prompt fgidx    Index frag (<owner> <INDEX name>)
prompt ds[7]    Data selectivity for a col(s) (<own> <tbl> <col(s)>)
prompt dsn      Data selectivity for a numeric col(s) (<own> <tbl> <col(s)>)
prompt
prompt ip       Instance parameters (<partial param value>)
prompt ipx      Instance parameters (hidden also) (<partial param value>)
prompt sga      System global area summary
prompt bc[7]    Buffer cache stats.
prompt bcmap[7] Buffer cache map.
prompt chr      SGA cache hit ratios
prompt lc       Library cache details
prompt dboc     v$db_object_cache (<min execs> <min size>)
prompt mts      Multi-threaded activity details
prompt sessinfo Oracle session details / ID (prompted...)
prompt mysess   Your session details / ID (prompted...)
prompt sesstat  V$SESSTAT details (<sid> <name>)
prompt sysstat  V$SYSSTAT details (<name>)
prompt rlog     Redo log activity (v$log)
prompt rdohist  Redo log switching history (v$loghist)
prompt
prompt topcpu   Show top CPU process consumers (<platform>)
prompt sqls1    List "top" SQL statements (<phys read cut> <log read cut>)
prompt sqls2    List SQL statement in shared pool (<sql stmt address>)
prompt sqls3    List SQL statement in shared pool (<sql stmt hash value>)
prompt hashchk  Checks if all hashes in v$sqlarea are also in v$sqltext
prompt dfio     Oracle datafile I/O details
prompt latch    Latching statistics
prompt spstat   Shared Pool Statistics
prompt
prompt swsessid  SW session level for given SID (<sid>)
prompt swsid    SW session wait level for given SID (<sid>)
prompt swsw     SW session wait level
prompt swswp    SW session wait level w/paramters
prompt swswc    SW session wait level w/counts
prompt swsys    SW system event level summary
prompt swpct    SW system event percentage summary (<partial event>)
prompt swenq    SW enqueue details
prompt swenqc   SW enqueue details by count
prompt
prompt objloc   Object location listing (<owner> <partial name>)
prompt objfb    Object details for a given file and block (<file#> <blk#>)
prompt bcobjfb  Object details for a ... in cache         (<file#> <blk#>)
prompt
prompt mkodo    Create the odometer (odo) table and indexes.
prompt cycle    Cycle the current db instance.
prompt
prompt osmprep  Prepare the OSM Interactive environment (calls irtviews.sql)
prompt osmtitle Standard OSM Interactive title script
prompt osmclear Standard OSM Interactive end of script clear stuff
prompt
prompt Oracle System Monitor - Interactive Menu
prompt (c)2001 OraPub, Inc. - Free use, just keep company and author name

