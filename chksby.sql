select * from ops$dbrx.dbrx_metric_1_data;
select max(sequence#) from v$log where archived = 'YES'; 
