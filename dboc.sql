------------------------------------------------------------
-- file         dboc.sql
-- desc         v$db_object_cache stats
-- author       Craig A. Shallahamer, craig@orapub.com with SERIOUS help from
--              Nick Desai (nddesai@apollogrp.edu) and 
--              Dhanaji More (dhanaji@hotmail.com)
-- orig         29-nov-00
-- lst upt      13-dec-00
-- copyright    (c)2000 OraPub, Inc.
------------------------------------------------------------

def min_exec=&1
def min_size=&2

def osm_prog	= 'dboc.sql'
def osm_title	= 'Oracle Database Object Cache Summary'

start osmtitle

col ownerx format a12    heading "Owner"
col namex  format a35   heading "Obj Name"
col typex  format a4   heading "Obj|Type"
col loadsx format 9990  heading "Loads"
col execsx format 999,990  heading "Exe|(k)"
col sizex  format 9990    heading "Size|(KB)"
col keptx  format a5    heading "Kept?"

select a.owner ownerx,
       a.name  namex,
       decode(a.type,'PACKAGE','PKG','PACKAGE BODY','PBDY','FUNCTION','FNC','PROCEDURE','PRC') typex,
       a.loads loadsx,
       a.executions/1000 execsx,
       a.sharable_mem/1024 sizex,
       a.kept keptx
from   v$db_object_cache a
where  a.sharable_mem >= &min_size
  and  a.executions >= &min_exec
  and  a.type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order by executions desc, sharable_mem desc, name
/

start osmclear



