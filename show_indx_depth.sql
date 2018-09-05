Script to check Index depth for Rebuild
set serveroutput on size 1000000
declare
print        varchar2(1);
cursor c1 is
select table_owner
    ,table_name
    ,index_name 
    ,est_size
    ,leaf_blocks
    ,compare_s
    ,blevel
    ,estbl
    ,cfg
from
     (select 
       i.table_owner
       ,i.index_name
      ,i.table_name 
 ,max(100*(i.clustering_factor-leaf_blocks)/(i.num_rows-leaf_blocks) )  cfG
      ,ceil(max(i.num_rows) /trunc((&blksize-39-23*(max(i.ini_trans)-1))/(sum(tc.avg_col_len)
		+count(*)+11)))  est_size  
      ,sum(tc.avg_col_len)
      ,count(*)
      ,i.leaf_blocks
      ,i.blevel
      ,100-100*ceil(max(i.num_rows) /trunc((&blksize-39-23*(max(i.ini_trans)-1))/
               (sum(tc.avg_col_len)+count(*)+11)))/
         decode(leaf_blocks,'',1,0,1,leaf_blocks) Compare_s   
        ,i.user_stats
      ,log(trunc((&blksize-39-23*(max(i.ini_trans)-1))/
               (sum(tc.avg_col_len)+count(*)+11)),i.num_rows) estbl
from
      all_indexes i
     ,all_ind_columns ic
     ,all_tab_columns tc
where
        i.table_owner = tc.owner
    and i.table_owner=ic.table_owner
    and i.index_type not in ('BITMAP')
    and i.table_name=tc.table_name
    and i.table_name=ic.table_name
    and tc.column_name =ic.column_name
    and i.table_owner not in ('SYS','SYSTEM')
    and tc.owner not in ('SYS','SYSTEM')
    and ic.table_owner not in ('SYS','SYSTEM')
    and i.index_name = ic.index_name
    and i.owner=ic.index_owner
    and i.leaf_blocks is not null
    and leaf_blocks > 8
group by
      i.table_owner,
     , i.index_name
      ,i.table_name 
      ,i.leaf_blocks
      ,i.user_stats
      ,i.num_rows
      ,i.blevel) x
order by index_name;
begin
print:='N';
dbms_output.put_line('Block Depth Rebuild recommendations');
dbms_output.put_line('-----------------------------------');
for cr in c1 loop
   If cr.blevel > cr.estbl then
     if cr.compare_s > 70 then
	dbms_output.put_line('Table/Index '||cr.table_name||'.'||cr.index_name||
       ' has a very high PCTfree (> 70) and the depth of the index can be reduced by rebuilding the index');
        dbms_output.put_line('Recommend rebuilding this index ASAP with a pctfree of 20 or less');
        print:='Y';
     else
      dbms_output.put_line('Table/Index '||cr.table_name||'.'||cr.index_name||
           ' has block depth of '||cr.blevel
          ||' which is greater then estimated block level '
          ||to_char(cr.estbl,'99.99')||',');
      dbms_output.put_line('Re-build should reduce depth of index.'
          ||' Re-build index reducing current pctfree '
          ||to_char(cr.compare_s,'999.9')
          ||' to a lower value. Set to 0 if sequential index else to '
          ||to_char(least(20,cr.compare_s/2),'99')||' or lower.'   ); 
        print:='Y';
      end if;
   end if;
     if cr.cfg < 2 and cr.compare_s > 5 then
        Dbms_output.put_line('Table/Index '||cr.table_name||'.'||cr.index_name||
           ' Appears to be based on a sequential index (has a low Cluster factor) but has a pctfree('
           ||to_char(cr.compare_s,'99.9')||'). Investigate rebuilding with a pctfree of 1%');
        print:='Y';
     end if; 
     if cr.blevel=trunc(cr.estbl) and cr.estbl-cr.blevel < cr.blevel*0.1
          and cr.compare_s > 10 then
        Dbms_output.put_line('Table/Index '||cr.table_name||'.'||cr.index_name||
        ' has a block level depth of '||cr.blevel
        ||'. Although the estimated block depth is the same the index has a high pctfree ('
        ||to_char(cr.compare_s,'999.9')||') and the depth of the index may be reduced if the index was rebuilt.');
        dbms_output.put_line('The Higher the pctfree the more probable the depth can be reduced.'
        ||' Suggest trying '||to_char(least(20,cr.compare_s/2),'99')||' or lower.'  );
        print:='Y';
     end if;
     if print = 'Y' then      dbms_output.put_line('___________________________________________________________________'); 
       print:='N';
     end if;
end loop;
end;
/
Note
This only applies to B*-Tree indexes
Ignores SYS and System indexes. These do not use CBO.
Recommendations are based on statistics in the dictionary. If these are not up to date, based on user entered statistics or estimated, then accuracy of the report for those indexes will be reduced. 
In all cases detail knowledge of the application and future knowledge of changes to the data or application will take precedence over these recommendations.
Either change &blksize to your block size or define it before executing code.
