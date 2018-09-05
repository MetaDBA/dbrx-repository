/* You can use DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('trans_id') to clean up the entries in DBA_2PC_PENDING.

exec DBMS_TRANSACTION.rollback_force('<local_tran_id>');
exec dbms_transaction.purge_lost_db_entry('<local_tran_id>');

<local_tran_id> is from DBA_2PC_PENDING table; Now, the DBA_2PC_PENDING has no more transaction.

*/

