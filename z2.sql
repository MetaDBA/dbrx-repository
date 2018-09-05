explain plan set statement_id='tsdb'
for
SELECT   
 dbl.lnkey 
,dbl.bnamekey
,dbl.user1key 
,dbl.user2key
,dbl.user3key 
,dbl.assignname
,dbl.assignto 
,dbl.mailbox
FROM
 empower.dblocks dbl
,empower.ls_urla lu
,	(
	SELECT branchid
	FROM empower.ess_branchid
	START WITH ess_branchid.branchid = :3
	CONNECT BY PRIOR ess_branchid.branchid = ess_branchid.parent_org_id
	AND ess_branchid.org_level > PRIOR ess_branchid.org_level
	) branches
WHERE 
dbl.bnamekey between :1 and :2
AND dbl.lnkey = lu.lnkey
AND lu.u_orig_branch = branches.branchid 
ORDER BY bnamekey
;
@exp

roll
