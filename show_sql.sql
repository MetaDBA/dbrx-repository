column status format a10
set feedback off
set serveroutput on
column username format a20
column sql_text format a55 word_wrapped

set serveroutput on size 1000000
declare
    x number;
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,' Day HH24:MI') logon_time,
             to_char(sysdate,' Day HH24:MI') current_time,
             sql_address, LAST_CALL_ET,
             sql_id,
             sql_hash_value
        from v$session
       where status = 'ACTIVE'
         and rawtohex(sql_address) <> '00'
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null)) ||
                          max(decode(piece,4,sql_text,null)) ||
                          max(decode(piece,5,sql_text,null)) ||
                          max(decode(piece,6,sql_text,null)) ||
                          max(decode(piece,7,sql_text,null)) ||
                          max(decode(piece,8,sql_text,null)) ||
                          max(decode(piece,9,sql_text,null)) ||
                          max(decode(piece,10,sql_text,null)) ||
                          max(decode(piece,11,sql_text,null)) ||
                          max(decode(piece,12,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 13)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( x.username );
                dbms_output.put_line( x.logon_time || ' ' ||
                                      x.current_time||
                                      ' last et = ' ||
                                      x.LAST_CALL_ET);
                dbms_output.put_line(
                          substr( y.sql_text, 1, 900 ) );
            end if;
        end loop;
    end loop;
end;
/

column username format a15 word_wrapped
column module format a15 word_wrapped
column action format a15 word_wrapped
column client_info format a30 word_wrapped

