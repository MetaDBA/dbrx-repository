-- ******************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001 OraPub, Inc.
-- * Filename           : osmprep.sql 
-- * Author             : Craig A. Shallahamer
-- * Original           : 17-AUG-98
-- * Last Modified      : 10-may-01
-- * Description        : OSM preperation script
-- * Usage              : start osmprep.sql 
-- * 			  Will prompt for system and sys passwords.
-- ******************************************************

prompt 
prompt OraPub System Monitor - Interactive (OSM-I) installation script.
prompt 

prompt 
prompt The standard OSM-I views will now be created...
prompt 

accept sys_pass prompt 'Please enter the SYS       password    : '

set echo on feedback on

connect sys/&sys_pass

col val1 new_val db_block_size noprint
select value val1
from   v$parameter
where  name = 'db_block_size'
/

create or replace view ts_free
as
  select 
    ts.name				ts_name,
    sum(fet.length*&db_block_size)	free_space,
    max(fet.length*&db_block_size)	max_frag_size,
    count(fet.length)			num_frags
  from
    sys.fet$ fet,
    sys.ts$  ts
  where 
    fet.ts# = ts.ts#
  group by 
    ts.name
union
  select
    f.tablespace_name		ts_name,
    sum(f.blocks*&db_block_size)-nvl(sum(u.blocks*&db_block_size),0) free_space,
    -1				max_frag_size,
    -1				max_frags
  from
    dba_temp_files f,
    v$sort_usage   u
  where 
    f.tablespace_name = u.tablespace (+)
  group by
    f.tablespace_name
/
grant all on ts_free to public;
drop   public synonym ts_free;
create public synonym ts_free for ts_free;

create or replace view ts_used
as
  select 
    ts.name				ts_name,
    sum(uet.length*&db_block_size)	used_space,
    max(uet.length*&db_block_size)	max_ext_size,
    count(uet.length)			num_exts
  from
    sys.uet$ uet,
    sys.ts$  ts
  where 
    uet.ts# = ts.ts#
  group by 
    ts.name
union
  select
    tablespace				ts_name,
    sum(blocks*&db_block_size)		used_space,
    max(extents)			max_ext_size,
    count(extents)			num_exts
  from
    v$sort_usage
  group by
  tablespace
/

grant all on ts_used to public;
drop   public synonym ts_used;
create public synonym ts_used for ts_used;

set echo off

disconnect

prompt
prompt You have been disconnected.  
prompt You may want to reconnect.
prompt

