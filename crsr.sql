def sid=&1

select * from v$open_cursor
where sid = &sid;
