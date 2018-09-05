set pagesize 100
col name for a30 trunc
col value$ for a40 trunc
SELECT name,value$ FROM sys.props$ WHERE name like 'NLS_%' ;

