explain plan set statement_id='tsdb'
for
SELECT 
  /*+ INDEX (art_article art_article_sort_idx) */  /*070102 WXU - The original SQL is fine. Nothing to do here.*/aid id,
  title,
  blurb,
  :"SYS_B_0" path,
  :"SYS_B_1" graphic,
  live_date display_date,
  art_source_srcid,
  catid locid,
  cat_name loc
FROM 
  art_article,
  art_index_int x,
  art_categories ac,
  art_categories_int aci
WHERE 
  art_index_indexid=:"SYS_B_2" AND
  aci.is_primary=:"SYS_B_3" AND
  live_date <=  sysdate  AND
  statusid in (:"SYS_B_4",:"SYS_B_5")  AND
  aid NOT IN (:"SYS_B_6",:"SYS_B_7") AND
  x.art_article_aid=aid AND
  aci.art_article_aid= aid AND
  ac.catid=aci.art_categories_catid
ORDER BY live_date DESC
;
@exp

roll
