SET LINESIZE 100 pagesize 900
COLUMN spid FORMAT A10
COLUMN username FORMAT A20 trunc
COLUMN program FORMAT A20 trunc

SELECT s.inst_id,
       s.sid,
       s.serial#,
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND'
ORDER By s.inst_id,s.username;