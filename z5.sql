explain plan set statement_id='tsdb'
for
SELECT /*+ INDEX (art_article art_article_sort_idx) */
 aid id,title,blurb,:"SYS_B_00" path, :"SYS_B_01" graphic,
   live_date display_date, art_source_srcid, catid locid, cat_name loc
 FROM t_art_article a, art_index_int x,
   art_categories ac, art_categories_int aci
 WHERE art_index_indexid=:"SYS_B_02"
 AND aci.is_primary=:"SYS_B_03"
 AND live_date <=  sysdate
 AND statusid in (:"SYS_B_04",:"SYS_B_05")
  AND NOT EXISTS (select :"SYS_B_06"
		 from art_index_int
		 where art_article_aid=a.aid
		 and art_index_indexid=:"SYS_B_07"
		 and is_primary = :"SYS_B_08")
 AND aid NOT IN (:"SYS_B_09",:"SYS_B_10",:"SYS_B_11")
 AND x.art_article_aid=aid
 AND aci.art_article_aid= aid
 AND ac.catid=aci.art_categories_catid
 ORDER BY live_date DESC
;
@exp

roll
