col ws1name format a30 heading "Parameter Name"
col ws1value format a40 heading "Websun1 Value"
col ws2value format a40 heading "Websun2 Value"

select ws1.name ws1name, ws1.value ws1value, ws2.value ws2value
 from v$system_parameter ws1, v$system_parameter@websun2 ws2
where ws1.name = ws2.name
and ws1.value <> ws2.value;
