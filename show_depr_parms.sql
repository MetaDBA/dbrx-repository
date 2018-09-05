set linesize 100
col name for a30 trunc
col value for a30 trunc
SELECT name FROM v$parameter WHERE isdeprecated = 'TRUE';
