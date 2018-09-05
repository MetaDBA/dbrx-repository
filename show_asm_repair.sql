set pagesize 1000
set linesize 165
col name for a30
col value for a30

SELECT group_number, name, value 
FROM v$asm_attribute WHERE name='disk_repair_time';



--ALTER DISKGROUP FRA SET ATTRIBUTE 'disk_repair_time' = '7h';
--ALTER DISKGROUP DATA SET ATTRIBUTE 'disk_repair_time' = '7h';




