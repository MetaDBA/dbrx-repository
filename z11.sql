explain plan set statement_id='tsdb'
for
SELECT aid,title,blurb, live_date
 FROM dbadmin.t_art_article a, pcwlive.art_index_int i
 WHERE i.art_index_indexid=:"SYS_B_0"
 AND a.aid=i.art_article_aid
 AND art_source_srcid
   IN (:"SYS_B_1",:"SYS_B_2",:"SYS_B_3",:"SYS_B_4")
 AND a.statusid=:"SYS_B_5"
 ORDER BY a.live_date desc
;
@exp

roll
