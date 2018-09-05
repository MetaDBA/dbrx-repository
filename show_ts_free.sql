set linesize 130
column free heading 'Free(Mb)' format 999,999,999
column maxsize heading 'Total(Mb)' format 999,999,999
column used heading 'Used(Mb)' format 999,999,999
column pct_free heading 'Pct Free' format 999.9
column tablespace_name format a30

set pagesize 40
ttitle LEFT 'Space Usage Report' SKIP 2
compute sum of maxsize on report
compute sum of free on report
compute sum of used on report
break on report

SELECT substr(tablespace_name,1,30)tablespace_name,
       total_used used, 
       (total_size-total_used) free, 
       total_size maxsize,
       ROUND(((total_size-total_used)/total_size)*100,2) pct_free
FROM ( SELECT dbf.tablespace_name,round(sum(used_bytes),1) total_used,round(sum(max_bytes),1) total_size
       FROM ( SELECT df.tablespace_name,
                     CASE
                     WHEN ( ( SELECT sum(bytes) FROM dba_free_space
                               WHERE file_id = df.file_id
                                 AND tablespace_name = df.tablespace_name ) IS NULL )
                     THEN
                          df.bytes/1024/1024
                     ELSE
                        ( df.bytes - ( SELECT sum(bytes)
                                         FROM dba_free_space
                                        WHERE file_id = df.file_id
                                          AND tablespace_name = df.tablespace_name) )/1024/1024
                     END used_bytes,
                     CASE
                     WHEN (df.autoextensible = 'NO')
                     THEN df.bytes/1024/1024
                     ELSE df.maxblocks*ts.block_size/1024/1024
                     END max_bytes
                FROM dba_data_files df, dba_tablespaces ts
      WHERE df.tablespace_name = ts.tablespace_name) dbf
      GROUP BY dbf.tablespace_name
)
ORDER BY 5 desc
/



