-- 10g +
select
      extract( day from snap_interval) *24*60+
      extract( hour from snap_interval) *60+
      extract( minute from snap_interval ) "Interval Minutes",
      extract( day from retention) "Retention Days"
from dba_hist_wr_control;
