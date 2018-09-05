set echo on timing on
select min(sample_time),count(1) from sys.WRH$_ACTIVE_SESSION_HISTORY; 
select sysdate - retention from dba_hist_wr_control;
