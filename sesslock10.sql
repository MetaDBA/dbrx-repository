col username form a12
col serial# form 999999 heading "Ser#"
col ROW_WAIT_OBJ# form 9999999 heading "Obj #"
col row_wait_file# form 9999 heading "File#"
col row_wait_block# form 99999999 heading "Block#"
col row_wait_row# form 9999 heading "Row#"
col blocking_session form 9999 heading "Blk|Sess"
col blocking_instance form 999 heading "Blk|Inst"
col blk_sid form a8       heading "Blocking|Inst:SID"
col event  format     a25  heading "Wait Event" wrap
col state  format      a4  heading "Wait|State"
col siw    format    9999  heading "W'd So|Far|(secs)"
col wt     format    9999  heading "Time|W'd|(secs)"
col inst_sid form a8       heading "Inst:SID"

select inst_id||':'||sid inst_sid , serial#, username, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#,
 sql_hash_value, blocking_instance || ':' || blocking_session blk_sid, substr(event,1,25) event,
 decode(state,'WAITING','WG','WAITING UNKNOWN','W UN',
                     'WAITED KNOWN TIME','W KN','WAITED SHORT TIME','W SH',
                     'WAITED','WD','*') state,
 seconds_in_wait siw
-- , wait_time wt
 from gv$session where blocking_session is not null
order by inst_sid;

