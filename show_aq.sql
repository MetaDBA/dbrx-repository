set timing on   
select name,
           waiting,
           ready,
           dequeue_enabled,
           enqueue_enabled
    from dba_queues d,
         gv$aq q
         -- v$aq q
      where d.qid = q.qid  and
          d.owner = 'SFDC_Q' and
         d.name like 'Q_COMMON%'
/
