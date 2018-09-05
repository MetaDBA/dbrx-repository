col space_limit form 999,999,999,999
col space_used  form 999,999,999,999
col space_free  form 999,999,999,999
col space_reclaimable  form 999,999,999,999
col name        form a20

select name, space_limit, space_used, space_limit - space_used space_free,
 space_reclaimable, number_of_files
from v$recovery_file_dest;

