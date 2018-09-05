break on dest_id skip 1

select dest_id, thread#, max(sequence#) from v$archived_log 
where applied='YES' group by dest_id, thread#
union
select dest_id, thread#, max(sequence#) from v$archived_log 
where dest_id = 1 group by dest_id, thread#
order by dest_id, thread#;

