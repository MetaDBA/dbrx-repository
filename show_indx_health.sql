column est_size heading 'Estimated|Leaf  |Blk Size' format 99,999,999 
column compare_s heading 'Comp|Size|  %' format 9999
column ti heading 'Table|index' format a30
column sav heading 'Full Index|Scan Save|Seconds' format 999999.9
column txt1 heading 'Comment' format a28
column Leaf_blocks heading 'Leaf|Blocks' format 9,999,999
select table_owner||table_name||'.'||index_name ti
      ,est_size
      ,leaf_blocks
      ,compare_s
      ,decode(floor(compare_s/10)
              ,0,'OK'
              ,1,'OK'
              ,2,'OK'
              ,3,'Re-build if performance is a problem using index scans'
              ,4,'Possible re-build especially if using Index Scans'
              ,5,'Re-build'
              ,6,'Re-build Soon '
              ,7,'Re-build Now'
              ,8,'Re-build Now - large areas empty'
              ,9,'Re-build now Urgent!'
              ,'Out of range - User stats or compressed?') txt1
      ,greatest((leaf_blocks-est_size),0)*.01 sav
from
     (select 
       i.table_owner
      , i.index_name
      ,i.table_name 
      ,trunc((&blksize-138-23*(max(i.ini_trans)-1))/(sum(tc.avg_col_len)+count(*)+11)) indexes_per_block
      ,ceil(max(i.num_rows) /trunc((&blksize-138-23*(max(i.ini_trans)-1))/(sum(tc.avg_col_len)+count(*)+11)))  est_size
      ,sum(tc.avg_col_len)
      ,count(*)
      ,max(num_rows) nrows
      ,i.leaf_blocks
      ,100-100*ceil(max(i.num_rows) /trunc((&blksize-138-23*(max(i.ini_trans)-1))/(sum(tc.avg_col_len)+count(*)+11)))/
         decode(leaf_blocks,'',1,0,1,leaf_blocks) Compare_s   
      ,i.user_stats
from
      all_indexes i
     ,all_ind_columns ic
     ,all_tab_columns tc
where
        i.table_owner = tc.owner
    and i.table_owner=ic.table_owner
    and i.table_name=tc.table_name
    and i.table_name=ic.table_name
    and tc.column_name =ic.column_name
    and i.index_type not in ('BITMAP')
    and i.table_owner not in ('SYS','SYSTEM')
    and tc.owner not in ('SYS','SYSTEM')
    and ic.table_owner not in ('SYS','SYSTEM')
    and i.index_name = ic.index_name
    and i.owner=ic.index_owner
    and i.leaf_blocks > 99
group by
       i.index_name
      ,i.table_owner
      ,i.leaf_blocks
      ,i.user_stats
      ,i.table_name
      ,i.user_stats) x
where compare_s < 0 or compare_s > 30
order by index_name
/
