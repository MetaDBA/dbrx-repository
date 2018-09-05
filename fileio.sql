set echo off

@identstats;

select to_char(totalio,'999,999,999,999') "TotalIO (Blocks)" from dual;

select substr(file_name,1,50) "File Name", substr(tablespace_name,1,10) "Tablespace",
 phyrds, phywrts, phyblkrd, phyblkwrt,
 round(100*(phyblkrd+phyblkwrt)/totalio) "% of Total" 
from dba_data_files d, v$filestat f
where f.file# = d.file_id
order by file_name;

select to_char(sum(phyblkrd),'999,999,999,999') "TotBlkRd",
 to_char(sum(phyblkwrt),'999,999,999,999') "TotBlkWrt",
 round(10*sum(phyblkrd)/sum(phyblkwrt))/10 "R/W Ratio"
  from  v$filestat fs;
