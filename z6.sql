explain plan set statement_id='tsdb'
for
select /*+ RULE*//*WXU 07/26/02*/d.fid aid, d.program_name title,
 d.blurb, d.upload_date live_date,
 nvl(n.total,'x') downloads, t.description
 from pcwlive.dow_file d, pcwlive.wfl_task w, pcwlive.dow_category_int ci,
 pcwlive.dow_count_total n, pcwlive.dow_type t
 where ci.art_categories_catid = :"SYS_B_4"
 and d.fid = ci.dow_file_fid
 and d.fid = w.recordid
 and w.wfl_process_prid = :"SYS_B_5"
 AND current_statusid=:"SYS_B_6"
 and n.dow_file_fid(+) = d.fid
 and t.typid = d.dow_type_typid
  order by downloads desc
@exp

roll
