break on report
compute sum LABEL "Total Sessions" of sessions on report
select trunc(sysdate - s.last_call_et/86400) "Last Call Date", count(*) sessions from v$session s 
where type <> 'BACKGROUND'
group by trunc(sysdate - s.last_call_et/86400) order by trunc(sysdate - s.last_call_et/86400)
;
