-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename		: mkodo.sql - Version 1.0
-- * Author		: Craig A. Shallahamer
-- * Original		: 06-OCT-98
-- * Last Update	: 06-OCT-98
-- * Description	: Create odometer table and index
-- * Usage		: start mkodo.sql
-- ********************************************************************

pause Press enter to create the ODO and indexes in your default tablespace.
pause Press enter if your reall sure about this.

drop table odo;
create table odo (c1 number, c2 number, c3 number, c4 number,
  text char(4));

prompt Loading 10,000 rows into table ODO w/a single ending commit.

set echo on feedback on

declare
  i number;
  j number;
  k number;
  l number;
begin
  for i in 0..9 loop
    for j in 0..9 loop
      for k in 0..9 loop
        for l in 0..9 loop
          insert into odo values (i,j,k,l,to_char(i)||to_char(j)||
                                          to_char(k)||to_char(l));
        end loop;
      end loop;
    end loop;
  end loop;
  commit;
end;
/
create index odo_n1 on odo (c1);
create index odo_n2 on odo (c2);
create index odo_n3 on odo (c3);
create index odo_n4 on odo (c4);
create index odo_n1234 on odo (c1,c2,c3,c4);

ttitle off
select count(*) from odo;

set echo off feedback off
start osmclear

