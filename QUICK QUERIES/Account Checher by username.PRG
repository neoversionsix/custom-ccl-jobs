select	
; Brings Back users from a given list of usernames
	p.username
	, p.name_last	
	, p.name_first	
	, p.name_full_formatted
	, credential = uar_get_code_display(cred.credential_cd)	
	, prsnl_active = p.active_ind
	, physician_ind = p.physician_ind	
	, postion = uar_get_code_display(p.position_cd)
	, prsnl_beg_dt = format(p.beg_effective_dt_tm, "dd/mm/yyyy HH:MM:SS")	
	, prsnl_end_dt = format(p.end_effective_dt_tm, "dd/mm/yyyy HH:MM:SS")	
	, prsnl_last_update = format(p.updt_dt_tm, "dd/mm/yy hh:mm:ss")	
	, prsnl_last_updater = if(p.person_id > 0 and p.updt_id = 0) "0"	
	else p_p.name_full_formatted	
	endif	
	, p.person_id	
	, last_logon = format( p_activity.last_act , "dd/mm/yyyyy HH:MM:SS")	
	, Demo1_org = if(p_org_r_Demo.prsnl_org_reltn_id > 0) "x"	
	else ""	
	endif	
	, Footscray_org = if(p_org_r_Foots.prsnl_org_reltn_id > 0) "x"	
	else ""	
	endif	
	, Sunbury_org = if(p_org_r_Sunb.prsnl_org_reltn_id > 0) "x"	
	else ""	
	endif	
	, Sunshine_org = if(p_org_r_Suns.prsnl_org_reltn_id > 0) "x"	
	else ""	
	endif	
	, Williamstown_org = if(p_org_r_Will.prsnl_org_reltn_id > 0) "x"	
	else ""	
	endif	
	, wh_org_count = p_org_r_Foots.active_ind + p_org_r_Sunb.active_ind + p_org_r_Suns.active_ind + p_org_r_Will.active_ind 	
	, wh_org_group = if(p_org_set_r_wh.org_set_prsnl_r_id > 0) "x"	
	else ""	
	endif	
	, mpages_org_group = if(p_org_set_r_mpages.org_set_prsnl_r_id > 0) "x"	
	else ""	
	endif	
	, organization_doctor  = p_a_org_dr.alias	
	, org_dr_alias_active = if(p_a_org_dr.prsnl_alias_id > 0) cnvtstring(p_a_org_dr.active_ind)	
	else ""	
	endif	
;	, org_dr_alias_active_status = uar_get_code_display(p_a_org_dr.active_status_cd)	
;	, org_dr_alias_active_status_cd = if(p_a_org_dr.prsnl_alias_id > 0) cnvtstring(p_a_org_dr.active_status_cd)	
;	else ""	
;	endif	
	, external_id_alias = p_a_ext_id.alias
from		
	prsnl p	
	, (left join prsnl p_p on p_p.person_id = p.updt_id)	
	, (left join prsnl p_p_create on p_p_create.person_id = p.create_prsnl_id)	
	, (left join prsnl p_p_act_stat on p_p_act_stat.person_id = p.active_status_prsnl_id)	
	, (left join prsnl_org_reltn p_org_r_Demo on p_org_r_Demo.person_id = p.person_id	
	and p_org_r_Demo.active_ind = 1	
	and p_org_r_Demo.beg_effective_dt_tm < sysdate	
	and p_org_r_Demo.end_effective_dt_tm > sysdate	
	and p_org_r_Demo.organization_id = 617843	; 'Demonstration 1 Hospital' organisation
	)	
	, (left join prsnl_org_reltn p_org_r_Foots on p_org_r_Foots.person_id = p.person_id	
	and p_org_r_Foots.active_ind = 1	
	and p_org_r_Foots.beg_effective_dt_tm < sysdate	
	and p_org_r_Foots.end_effective_dt_tm > sysdate	
	and p_org_r_Foots.organization_id = 680563	; 'WHS Footscray Hospital' organisation
	)	
	, (left join prsnl_org_reltn p_org_r_Sunb on p_org_r_Sunb.person_id = p.person_id	
	and p_org_r_Sunb.active_ind = 1	
	and p_org_r_Sunb.beg_effective_dt_tm < sysdate	
	and p_org_r_Sunb.end_effective_dt_tm > sysdate	
	and p_org_r_Sunb.organization_id = 680566	; 'WHS Sunbury Day Hospital' organisation
	)	
	, (left join prsnl_org_reltn p_org_r_Suns on p_org_r_Suns.person_id = p.person_id	
	and p_org_r_Suns.active_ind = 1	
	and p_org_r_Suns.beg_effective_dt_tm < sysdate	
	and p_org_r_Suns.end_effective_dt_tm > sysdate	
	and p_org_r_Suns.organization_id = 680564	; 'WHS Sunshine Hospital' organisation
	)	
	, (left join prsnl_org_reltn p_org_r_Will on p_org_r_Will.person_id = p.person_id	
	and p_org_r_Will.active_ind = 1	
	and p_org_r_Will.beg_effective_dt_tm < sysdate	
	and p_org_r_Will.end_effective_dt_tm > sysdate	
	and p_org_r_Will.organization_id = 680565	; 'WHS Williamstown Hospital' organisation
	)	
	, (left join org_set_prsnl_r p_org_set_r_wh on p_org_set_r_wh.prsnl_id = p.person_id	
	and p_org_set_r_wh.active_ind = 1	
	and p_org_set_r_wh.beg_effective_dt_tm < sysdate	
	and p_org_set_r_wh.end_effective_dt_tm > sysdate	
	and p_org_set_r_wh.org_set_id = 620126	; 'Western Health' org group
	)	
	, (left join org_set_prsnl_r p_org_set_r_mpages on p_org_set_r_mpages.prsnl_id = p.person_id	
	and p_org_set_r_mpages.active_ind = 1	
	and p_org_set_r_mpages.beg_effective_dt_tm < sysdate	
	and p_org_set_r_mpages.end_effective_dt_tm > sysdate	
	and p_org_set_r_mpages.org_set_id = 680584	; 'MPages Mobile Review' org group
	)	
	, (left join prsnl_alias p_a_ext_id on p_a_ext_id.person_id = p.person_id	
	and p_a_ext_id.active_ind = 1	
	and p_a_ext_id.beg_effective_dt_tm < sysdate	
	and p_a_ext_id.end_effective_dt_tm > sysdate	
	and p_a_ext_id.alias_pool_cd = 683991	; 'External Id' from code set 263
	)	
	, (left join prsnl p_p_a_ext_id on p_p_a_ext_id.person_id = p_a_ext_id.updt_id)	
	, (left join credential cred on cred.prsnl_id = p.person_id	
	and cred.active_ind = 1	
	and cred.beg_effective_dt_tm < sysdate	
	and cred.end_effective_dt_tm > sysdate	
	)	
	, (left join prsnl p_cred on p_cred.person_id = cred.updt_id)	
	, (left join prsnl_alias p_a_org_dr on p_a_org_dr.person_id = p.person_id 	

	and p_a_org_dr.alias_pool_cd = 9633666	; 'IPM MAIN CODE' from code set 263
	)	
	, (left join prsnl p_p_a_org_dr on p_p_a_org_dr.person_id = p_a_org_dr.updt_id)	
	, (left join prsnl_alias p_a_Foots_pn on p_a_Foots_pn.person_id = p.person_id 	
	and p_a_Foots_pn.active_ind = 1	
	and p_a_Foots_pn.beg_effective_dt_tm < sysdate	
	and p_a_Foots_pn.end_effective_dt_tm > sysdate	
	and p_a_Foots_pn.alias_pool_cd = 87458279	; 'WHS FOOTSCRAY PROVIDER NUMBER' from code set 263
	)	
	, (left join prsnl_alias p_a_Sunb_pn on p_a_Sunb_pn.person_id = p.person_id	
	and p_a_Sunb_pn.active_ind = 1	
	and p_a_Sunb_pn.beg_effective_dt_tm < sysdate	
	and p_a_Sunb_pn.end_effective_dt_tm > sysdate	
	and p_a_Sunb_pn.alias_pool_cd = 87458282	; 'WHS SUNBURY PROVIDER NUMBER' from code set 263
	)	
	, (left join prsnl_alias p_a_Suns_pn on p_a_Suns_pn.person_id = p.person_id	
	and p_a_Suns_pn.active_ind = 1	
	and p_a_Suns_pn.beg_effective_dt_tm < sysdate	
	and p_a_Suns_pn.end_effective_dt_tm > sysdate	
	and p_a_Suns_pn.alias_pool_cd = 87458285	; 'WHS SUNSHINE PROVIDER NUMBER' from code set 263
	)	
	, (left join prsnl_alias p_a_Will_pn on p_a_Will_pn.person_id = p.person_id	
	and p_a_Will_pn.active_ind = 1	
	and p_a_Will_pn.beg_effective_dt_tm < sysdate	
	and p_a_Will_pn.end_effective_dt_tm > sysdate	
	and p_a_Will_pn.alias_pool_cd = 87458288	; 'WHS WILLIAMSTOWN PROVIDER NUMBER' from code set 263
	)	
	, (left join (select p_act.person_id , last_act = max(p_act.start_day)	
	from OMF_APP_CTX_DAY_ST p_act 	
	group by p_act.person_id	
	) p_activity on p_activity.person_id = p.person_id	
	)	
plan	p	
where	p.person_id > 0	; ignore '0' database row
		and 
		p.username in ; ENTER USERNAMES BELOW
(
"user1"
, "user2"
, "user3"
)
join	p_p
join	p_p_create	
join	p_p_act_stat	
join	p_org_r_Demo	
join	p_org_r_Foots	
join	p_org_r_Sunb	
join	p_org_r_Suns	
join	p_org_r_Will	
join	p_org_set_r_wh	
join	p_org_set_r_mpages	
join	p_a_ext_id	
join	p_p_a_ext_id	
join	cred	
join	p_cred	
join	p_a_org_dr	
join	p_p_a_org_dr	
join	p_a_Foots_pn	
join	p_a_Sunb_pn	
join	p_a_Suns_pn	
join	p_a_Will_pn	
join	p_activity	
order by		
;	p.active_status_dt_tm	; use one of these switches as the first sort option
	p.updt_dt_tm desc	; use one of these switches as the first sort option
	, p.name_last desc
with		
	time = 120