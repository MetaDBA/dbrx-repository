select dest_id, thread#, max(sequence#) from v$archived_log 
where applied='YES' group by dest_id, thread#
order by dest_id, thread#;


