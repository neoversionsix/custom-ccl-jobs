select distinct	; recorded diagnoses
/*updated information from July 2021 until now.
breakdown of either WHO ADDED THE DIAGNOSIS OR WHAT POSITION. 
KPI for a business case in Nutrition.
*/
	UR_number = ea_URN.alias
	, DIAGNOSED_BY = D.DIAG_PRSNL_NAME; ADDED THIS 	
	, patient_name = p.name_full_formatted ;"xxxx"	
	, patient_id = d.person_id	
	, encntr_dates = concat(format(e_orig.arrive_dt_tm, "dd/mm/yy hh:mm"), " - ", format(e_orig.depart_dt_tm, "dd/mm/yy hh:mm"))	
	, visit_no = ea_visit.alias	
	, d.encntr_id	
;	, treating_team = uar_get_code_display(e_orig.med_service_cd)	
	, facility_at_time_of_diagnosis = uar_get_code_display(e_orig.loc_facility_cd)	
	, unit_at_time_of_diagnosis =if(elh.loc_nurse_unit_cd > 0) uar_get_code_display(elh.loc_nurse_unit_cd)	
	else uar_get_code_display(e_orig.loc_nurse_unit_cd)	
	endif	
;	, current_facility = if (e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_facility_cd)	
;	else "no current facility"	
;	endif	
;	, current_unit = if (e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_nurse_unit_cd)	
;	else "no current unit"	
;	endif	
	, diagnosis = n_d.source_string	
	, diag_type = uar_get_code_display(d.diag_type_cd)	
	, d.nomenclature_id	
	, d.diagnosis_id	
;	, order_type = evaluate (o.orig_ord_as_flag,	
;	0, "Normal Order",	
;	1, "Prescription/Discharge Order",	
;	2, "Recorded / Home Meds",	
;	3, "Patient Owns Meds",	
;	4, "Pharmacy Charge Only",	
;	5, "Satellite (Super Bill) Meds"	
;	)	
;	, original_order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
;	, order_placed_by = p_o_a.name_full_formatted	
;	, current_order_status = uar_get_code_display(o.order_status_cd)	
;	, order_status_last_update = format(o.status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
;	, order_status_last_updater = if(o.order_id > 0 and o.status_prsnl_id = 0) "0"	
;	else p_o_stat.name_full_formatted	
;	endif	
;	, order_projected_stop_date = if ( o.projected_stop_dt_tm > o.orig_order_dt_tm) format(o.projected_stop_dt_tm, "dd/mm/yyyy hh:mm:ss")	
;	else null	
;	endif	
;	, o.clinical_display_line	
;	, o.order_id	
;	, o.ordered_as_mnemonic	
;	, synonym_mnemonic = ocs.mnemonic	
;	, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)	
;	, synonym_id = o.synonym_id	
	, diagnosis_rank = dense_rank() over (partition by 0	
	order by	
	d.beg_effective_dt_tm	
	, d.active_status_dt_tm	
	, d.diagnosis_id	
	)	
		
from		
	diagnosis d	
	, (left join nomenclature n_d on n_d.nomenclature_id = d.nomenclature_id)	
	, (left join encounter e_orig on e_orig.encntr_id = d.encntr_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = d.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = d.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
	, (left join encntr_loc_hist elh on elh.encntr_id = d.encntr_id	
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm < d.beg_effective_dt_tm	; encounter location began before order was placed
	and elh.end_effective_dt_tm >  d.end_effective_dt_tm	; encounter location ended after order was placed
	)	
	, (left join person p on p.person_id = d.person_id)	
;	, (left join encounter e_curr on e_curr.person_id = o.person_id	
;	and e_curr.encntr_type_cd in (309308, 309310)	; 'Inpatient' and 'Emergency' from codeset 71
;	and e_curr.active_ind = 1	
;	and e_curr.arrive_dt_tm < sysdate	; patient arrived in the past
;	and e_curr.depart_dt_tm = null	; but has not yet departed
;	)	
;	, orders o	
;	, (left join prsnl p_o_stat on p_o_stat.person_id = o.status_prsnl_id)	
;	, (left join order_action o_a on o_a.order_id = o.order_id	
;	 and o_a.action_type_cd = 2534	; 'order' from codeset 6003
;	)	
;	, (left join prsnl p_o_a on p_o_a.person_id = o_a.action_personnel_id)	
;	, (left join order_catalog_synonym ocs on ocs.synonym_id = o.synonym_id)	
		
plan	d	
where	d.active_ind = 1	; active disgnoses only
;and	d.diag_type_cd = 3538766	; 'Principwl Dx' from code set 17
and	d.end_effective_dt_tm > sysdate	; effective disgnoses only
and	d.nomenclature_id in ( select n.nomenclature_id	
	from nomenclature n	
	where n.source_string_keycap = "MALNUTRITION*"	
	)	
and 	d.updt_dt_tm between cnvtdatetime("01-JUL-2020") and cnvtdatetime("30-JUN-2021")	
join	n_d	
join	e_orig	
join	ea_URN	
join	ea_visit	
join	elh	
join	p	
;join	o	
;where	o.template_order_id = 0	; template orders only (ie not exploded orders based on frequency)
;and	o.order_status_cd in (	
;	2546	; Future
;	, 2547	; Incomplete
;	, 2548	; InProcess
;	, 2549	; On Hold, Med Student
;	, 2550	; Ordered
;	, 2551	; Pending Review
;	, 2552	; Suspended
;	, 2553	; Unscheduled
;	, 614538	; Transfer/Canceled
;	, 643466	; Pending Complete
;	)	
;and	o.orig_ord_as_flag = 0	; inpatient orders only
;and	o.orig_ord_as_flag = 1	; discharge prescriptions only
;and	o.orig_ord_as_flag = 2	; Recorded / Home Meds only
;and	o.active_ind = 1	; active orders only
;and	(	
;	o.projected_stop_dt_tm > sysdate	; current orders only (future stop date or no stop date)
;	or	
;	o.projected_stop_dt_tm = null	
;	)	
;and	o.catalog_cd = 87329508	; 'OT (Occupational Therapy) Referral'
;and	o.synonym_id in ()	
;join	p_o_stat	
;join	o_a	
;where	o_a.updt_id = 1235678	; orders placed by 'Surname, FirstName  - NP'
;and	o_a.updt_dt_tm between cnvtdatetime("01-DEC-2016") and cnvtdatetime("01-DEC-2020")	; between dates
;join	p_o_a	
;join	ocs	
;join	e_curr	
		
order by		
	d.beg_effective_dt_tm	
	, d.active_status_dt_tm	
	, d.diagnosis_id	
	, ea_URN.alias	
	, d.nomenclature_id	
	, 0	
		
with	time = 240	
