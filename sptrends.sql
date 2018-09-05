COL NAME FOR A30
/**********************************************************************
 * File:        sptrends.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (SageLogix, Inc.)
 * Date:        15-Jul-2003
 *
 * Description:
 *      Query to display "trends" for specific statistics captured by
 *the STATSPACK package, and display summarized totals daily and
 *hourly as a deviation from average.  The intent is to find the
 *readings with the greatest positive deviation from the average
 *value, as these are likely to be "periods of interest" for
 *further research...
 *
 * Modifications:
 *********************************************************************/
set echo off feedback off timing off pagesize 200 lines 130 trimout on
trimspool on verify off recsep off
col sort0 noprint
col day heading "Day"
col hr heading "Hour"
col value format 999,999,999,990 heading "Value"
col deviation format a100 heading "Relative Deviation from Average Value"
 
accept V_NBR_DAYS prompt "How many days of data to examine? "
prompt Some useful database statistics to search upon:
select  rpad(' ',4,' ')||name name
from v$statname
where   name like '%logical%'
or      name like '%physical%'
or      name like '%redo%'
or      name like '%sort%'
or      lower(name) like '%cpu%'
order by 1;
accept V_STATNAME prompt "What statistic? "
col spoolname new_value V_SPOOLNAME noprint
select replace(replace(replace(lower('&&V_STATNAME'),'
','_'),'(',''),')','') spoolname
from dual;
spool sptrends_&&V_SPOOLNAME
clear breaks computes
col value format 999,999,999,990 heading "Value"
prompt
prompt Daily trends for "&&V_STATNAME"...
select sort0,
day,
value,
rpad('*', decode(greatest(round(((value - (avg(value) over ()))/(avg(value)
over ()))*100,-1),0),
 0, 0, round(((value - (avg(value) over ()))/(avg(value) over
()))*100,-1))/2,'*') deviation
from (select sort0,
day,
sum(value) value
 from (select to_char(ss.snap_time, 'YYYYMMDD') sort0,
to_char(ss.snap_time, 'DD-MON') day,
s.snap_id,
s.name,
nvl(decode(greatest(s.value, nvl(lag(s.value) over (order by s.dbid,
s.instance_number, s.snap_id),0)),
   s.value, s.value - lag(s.value) over (order by s.dbid, s.instance_number,
s.snap_id),
  s.value), 0) value
 from stats$sysstat   s,
      stats$snapshot ss
 where ss.snap_id = s.snap_id
 and ss.dbid = s.dbid
 and ss.instance_number = s.instance_number
 and ss.snap_time between (sysdate - &&V_NBR_DAYS) and sysdate
 and s.name = '&&V_STATNAME')
 group by sort0,
  day)
order by sort0;
clear breaks computes
break on day skip 1 on report
col value format 999,999,990 heading "Value"
prompt
prompt Daily/hourly trends for "&&V_STATNAME"...
select sort0,
day,
hr,
value,
rpad('*', decode(greatest(round(((value - (avg(value) over ()))/(avg(value)
over ()))*100,-1),0),
 0, 0, round(((value - (avg(value) over ()))/(avg(value) over
()))*100,-1))/2,'*') deviation
from(select sort0,
day,
hr,
name,
sum(value) value
 from (select to_char(ss.snap_time, 'YYYYMMDDHH24') sort0,
to_char(ss.snap_time, 'DD-MON') day,
to_char(ss.snap_time, 'HH24')||':00' hr,
s.snap_id,
s.name,
nvl(decode(greatest(s.value, nvl(lag(s.value) over (order by s.dbid,
s.instance_number, s.snap_id),0)),
   s.value, s.value - lag(s.value) over (order by s.dbid, s.instance_number,
s.snap_id),
  s.value), 0) value
 from stats$sysstat   s,
      stats$snapshot ss
 where ss.snap_id = s.snap_id
 and ss.dbid = s.dbid
 and ss.instance_number = s.instance_number
 and ss.snap_time between (sysdate - &&V_NBR_DAYS) and sysdate
 and s.name = '&&V_STATNAME')
 group by sort0,
  day,
  hr,
  name)
order by sort0;
spool off
set verify on recsep each

