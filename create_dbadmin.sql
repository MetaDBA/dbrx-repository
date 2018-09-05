create user dbadmin identified by password 
default tablespace users
temporary tablespace temp;
grant dba to dbadmin;
grant select_catalog_role, execute_catalog_role, delete_catalog_role to dbadmin;
grant select on sys.v_$filestat to dbadmin;

create user tsutton identified by password 
default tablespace users
temporary tablespace temp;
grant dba to tsutton;
grant select_catalog_role, execute_catalog_role, delete_catalog_role to tsutton;
grant select on sys.v_$filestat to tsutton;

select tablespace_name, to_char(sum(bytes),'999,999,999,999') "Free Space"
from dba_free_space 
group by tablespace_name;



