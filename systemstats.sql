col sname form a15
col pname form a15
col pval2 form a20

break on sname skip 1

select * from sys.aux_stats$ order by sname, pname;
