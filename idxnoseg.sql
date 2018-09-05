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

def osm_prog    = 'idx.sql'
def osm_title   = 'Index Column Summary (&schema..&tabname)'

start osmtitle

col uniq    format a10 heading 'Uniqueness'  justify c trunc
col indname format a40 heading 'Index Name'  justify c trunc
col colname format a25 heading 'Column Name' justify c trunc
col dist    format 999,999,999,999 heading 'Distinct Keys' justify c trunc
col segsize format 99,999      heading 'Size (MB)'     justify c trunc
col tsname  format a20 heading 'Tablespace'  justify c trunc

break on indname skip 1 on uniq

select
  ind.uniqueness                  uniq,
  ind.owner||'.'||col.index_name  indname,
  col.column_name                 colname,
  ind.distinct_keys               dist,
  ind.tablespace_name             tsname
from
  dba_ind_columns  col,
  dba_indexes      ind
where
  ind.table_owner = upper('&schema')
    and
  ind.table_name = upper('&tabname')
    and
  col.index_owner = ind.owner 
    and
  col.index_name = ind.index_name
    and
  col.table_owner = ind.table_owner
    and
  col.table_name = ind.table_name
order by
  col.index_name,
  col.column_position
/

undef schema
undef tabname
start osmclear

