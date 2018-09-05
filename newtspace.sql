
COL filecount	       FORMAT 9999  HEADING "# of|Files"
COL tablespace_name    FORMAT a25
COL current_size_mb    FORMAT 999,999,990.0 HEADING "Current|Size Mb"
COL current_mb_free    FORMAT 999,999,990.0 HEADING "Current|Mb Free"
COL pct_free           FORMAT 990.0     HEADING "Current|% Free"
COL potential_mb_free  FORMAT 999,999,990.0 HEADING "Potential|Mb Free"
COL potential_pct_free FORMAT 990.0     HEADING "Potential|% Free"

SELECT   A.tablespace_name, B.filecount, B.mb_size current_size_mb,
         NVL (C.mb_free, 0) current_mb_free,
         100 * NVL (C.mb_free, 0) / B.mb_size pct_free,
         B.mb_maximum - B.mb_size + NVL (C.mb_free, 0) potential_mb_free,
         100 * (B.mb_maximum - B.mb_size + NVL (C.mb_free, 0)) /
         B.mb_maximum potential_pct_free
FROM     dba_tablespaces A,
         (
         SELECT   tablespace_name, SUM (bytes) / 1024 / 1024 mb_size,
                  SUM (DECODE (autoextensible, 'YES', maxbytes, bytes))
                  / 1024 / 1024 mb_maximum,
		  count(*) filecount
         FROM     dba_data_files
         GROUP BY tablespace_name
         ) B,
         (
         SELECT   tablespace_name, SUM (bytes) / 1024 / 1024 mb_free
         FROM     dba_free_space
         GROUP BY tablespace_name
         ) C
WHERE    B.tablespace_name = A.tablespace_name
AND      C.tablespace_name (+) = A.tablespace_name
ORDER BY potential_pct_free;
