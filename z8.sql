explain plan set statement_id='tsdb'
for
SELECT pid, page_name, url_format
 FROM pro_pg_page_int pppi, pro_pg_page ppp,
 pro_pg_product ppp2,pro_item
 WHERE pppi.pro_product_prodid=:"SYS_B_0"
 AND pro_pg_page_pid=pid
 AND pppi.pro_product_prodid=ppp2.pro_product_prodid
 AND pro_item_itid=itid
 ORDER BY sort_order
;
@exp

roll
