col name 	      form a43
col description       form a45
col detected_usages   form 9999 heading "Usages"
col first_usage_date  form a11  heading "First Usage"
col last_usage_date   form a11  heading "Last Usage"



select name, detected_usages, to_char(first_usage_date, 'DD-MON-YYYY') first_usage_date,
 to_char(last_usage_date, 'DD-MON-YYYY') last_usage_date, description 
from DBA_FEATURE_USAGE_STATISTICS
/
