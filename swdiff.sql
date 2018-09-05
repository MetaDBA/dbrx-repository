drop table previous_events;
CREATE TABLE previous_events
        AS
        SELECT SYSDATE timestamp, v$system_event.*
        FROM   v$system_event;

        EXECUTE dbms_lock.sleep (30);

        SELECT   A.event, 
                 A.total_waits - NVL (B.total_waits, 0) total_waits,
                 A.time_waited - NVL (B.time_waited, 0) time_waited
        FROM     v$system_event A, previous_events B
        WHERE    B.event (+) = A.event
	and  a.event not in (
'client message',
'dispatcher timer',
'gcs for action',
'gcs remote message',
'ges remote message',
'i/o slave wait',
'jobq slave wait',
'lock manager wait for remote message',
'null event',
'parallel query dequeue',
'pipe get',
'PL/SQL lock timer',
'pmon timer',
'PX Deq Credit: need buffer',
'PX Deq Credit: send blkd',
'PX Deq: Execute Reply',
'PX Deq: Execution Msg',
'PX Deq: Signal ACK',
'PX Deq: Table Q Normal',
'PX Deque Wait',
'PX Idle Wait',
'queue messages',
'rdbms ipc message',
'slave wait',
'smon timer',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net more data from client',
'virtual circuit status',
'wakeup time manager'
)
        ORDER BY time_waited, A.event;
