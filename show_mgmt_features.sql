set lines 1000 set pages 999
break on version skip 1
select version, name, detected_usages, currently_used, first_usage_date, last_usage_date
  from DBA_FEATURE_USAGE_STATISTICS
  where detected_usages > 0
  order by 1, 2
/

