set linesize 1000 trimspool on
column mb_used for 9,999,999,999
column mb_reclaimable for 9,999,999,999
break on report
compute sum of mb_used on report
compute sum of mb_reclaimable on report
compute sum of number_of_files on report

select FILE_TYPE , 
      PERCENT_SPACE_USED, 
      PERCENT_SPACE_USED * p.value / 100 / 1024 / 1024 "MB_USED",
      PERCENT_SPACE_RECLAIMABLE pct_space_rec,
      NUMBER_OF_FILES, 
      PERCENT_SPACE_RECLAIMABLE * p.value / 100 / 1024 / 1024 "MB_RECLAIMABLE" 
      from v$flash_recovery_area_usage f, v$parameter p 
where p.name='db_recovery_file_dest_size'; 
