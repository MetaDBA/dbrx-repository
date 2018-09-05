explain plan set statement_id='tsdb'
for
select 
  a.art_article_aid, aa.title, path
 from art_article aa, art_categories_int a, art_chart_int ac,
 cha_chart cc, cha_type ct, v_art_primary_index v,
 art_index ai, art_index_top t
 where art_categories_catid = :"SYS_B_0"
 and is_primary = :"SYS_B_1"
 and aa.AID = a.ART_ARTICLE_AID
 and a.ART_ARTICLE_AID = ac.ART_ARTICLE_AID
 and ac.CHA_CHART_CHID = cc.CHID
 and NOT EXISTS
	 (select :"SYS_B_2" from art_chart_int
	 where art_article_aid in (:"SYS_B_3",:"SYS_B_4"))
 and typid not in (:"SYS_B_5",:"SYS_B_6")
 and cc.CHA_TYPE_TYPID = ct.TYPID
 and v.art_article_aid = aa.aid
 and v.art_index_indexid = t.ART_INDEX_INDEXID
 and t.top_indexid = ai.INDEXID
 and ct.IS_LIVE = :"SYS_B_7"
 AND statusid in (:"SYS_B_8",:"SYS_B_9")
 order by live_date desc
;
@exp

roll
