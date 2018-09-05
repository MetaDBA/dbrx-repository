-- ******************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename           : ogobjcr.sql
-- * Author             : Craig A. Shallahamer
-- * Original           : 21-may-99
-- * Last Modified      : 21-may-99
-- * Description        : Object Growth preperation script
-- * Usage              : start ogcrobj.sql 
-- * 			  Will prompt for passwords and tbs.
-- ******************************************************

accept mgrpwd prompt 'Please enter the SYSTEM password    : '
accept tbs    prompt 'Please enter the object tablespace  : '

set echo on feedback on

connect system/&mgrpwd

drop table o$obj_to_analyze;
create table o$obj_to_analyze
(
  owner		varchar2(30),
  obj_name	varchar2(30),
  obj_type	varchar2(30),
  doit		char(1),
  compute	char(1),
  est_pct	number
)
tablespace &tbs
storage (initial 32k next 32k pctincrease 100)
/
create index obj_to_analyze_u1 on o$obj_to_analyze
  (owner, obj_name, obj_type)
tablespace &tbs
storage (initial 32k next 32k pctincrease 100)
/

drop table o$dba_tables;
create table o$dba_tables
(
  the_key		number,
  the_date		date,
  owner			varchar2(30),
  table_name		varchar2(30),
  tablespace_name	varchar2(30),
  pct_free		number,
  pct_used		number,
  ini_trans		number,
  max_trans		number,
  initial_extent	number,
  next_extent		number,
  pct_increase		number,
  num_rows		number,
  blocks		number,
  empty_blocks		number,
  avg_space		number,
  chain_cnt		number,
  avg_row_len		number
)
tablespace &tbs
storage (initial 32k next 32k pctincrease 100)  
/ 
grant all on o$dba_tables to public;
drop   public synonym o$dba_tables;
create public synonym o$dba_tables for o$dba_tables;

create index o$dba_tables on o$dba_tables
  (the_key,owner, obj_name, obj_type)
tablespace &tbs
storage (initial 32k next 32k pctincrease 100)
/

insert into o$dba_tables values (1,null,null,null,null,null,null,null,
  null,null,null,null,null,null,null,null,null,null)
/

create or replace view o$dba_objects
(
  owner,			
  object_name,	
  type	
)
as
select owner, table_name, 'TABLE'
from   o$dba_tables
/

grant all on o$dba_objects to public;
drop   public synonym o$dba_objects;
create public synonym o$dba_objects for o$dba_objects;

undef mgrpwd
undef tbs
