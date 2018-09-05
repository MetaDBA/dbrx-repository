set numwidth 15
column shared_pool_size format 999,999,999
column sum_obj_size format 999,999,999
column sum_sql_size format 999,999,999
column sum_user_size format 999,999,999
column min_shared_pool format 999,999,999
select to_number(value) shared_pool_size, 
                         sum_obj_size,
                         sum_sql_size, 
                         sum_user_size, 
(sum_obj_size + sum_sql_size+sum_user_size)* 1.3 min_shared_pool
  from (select sum(sharable_mem) sum_obj_size 
          from v$db_object_cache),
               (select sum(sharable_mem) sum_sql_size
          from v$sqlarea),
               (select sum(250 * users_opening) sum_user_size
          from v$sqlarea), v$parameter
 where name = 'shared_pool_size';

