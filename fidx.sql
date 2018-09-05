-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename           : idx.sql - Version 1.0
-- * Author             : Craig A. Shallahamer
-- * Original           : 17-AUG-98
-- * Last Update        : 24-SEP-98
-- * Description        : Basic Oracle index column data
-- * Usage              : start idx.sql <schema> <table name>
-- ********************************************************************

def schema      = &&1
def tabname     = &&2

def osm_prog    = 'fidx.sql'
def osm_title   = 'Function Based Index Column Summary (&schema..&tabname)'

start osmtitle

col uniq    format a10 heading 'Uniqueness'  justify c trunc
col indname format a20 heading 'Index Name'  justify c trunc
col colname format a15 heading 'Column Name' justify c trunc
col expres  format a30 heading 'Function'    justify c trunc
col dist    format 999,999,999 heading 'Distinct Keys' justify c trunc
col segsize format 99,999      heading 'Size(MB)'     justify c trunc
col tsname  format a10 heading 'Tablespace'  justify c trunc

break on indname skip 1 on uniq

select
  ind.uniqueness                  uniq,
  ind.owner||'.'||col.index_name  indname,
  col.column_name                 colname,
  exp.column_expression		  expres,
  ind.distinct_keys               dist,
  round(seg.bytes/1048576)        segsize,
  ind.tablespace_name             tsname
from
  dba_ind_columns  col,
  dba_indexes      ind,
  dba_segments     seg,
  dba_ind_expressions exp
where
  ind.owner = upper('&schema')
    and
  ind.table_name = upper('&tabname')
    and
  col.index_owner = ind.owner 
    and
  col.index_name = ind.index_name
    and
  seg.owner = ind.owner
    and
  seg.segment_name  = ind.index_name
    and
  seg.segment_type = 'INDEX'
    and
  ind.index_type = 'FUNCTION-BASED NORMAL'
    and
  exp.index_owner = ind.owner
    and
  exp.index_name = ind.index_name
    and
  exp.column_position = col.column_position
order by
  col.index_name,
  col.column_position
/

undef schema
undef tabname
start osmclear

