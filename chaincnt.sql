col table_name format a30
col owner format a10

select substr(owner,1,10) owner,
	substr(table_name,1,30) table_name,
	to_char(num_rows, '99999999') "Num Rows", 
	to_char(chain_cnt, '99999999') "Chain Cnt",
	to_char(round(100*(chain_cnt/num_rows)), '9999') "%Chnd",
	to_char(avg_space, '999999') "AvSpace",
	to_char(avg_row_len, '9999999') "AvRowLen",
	to_char(pct_free, '99999') "Pct_Fr"
  from sys.dba_tables
  where chain_cnt > 0   and
	owner <> 'SYS' and owner <> 'SYSTEM'
order by owner, table_name
/
