/*
This program will retrieve pathology orders associated with Emergency Encounters
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE" 

with OUTDEV, STA_DATE_TM, END_DATE_TM

SELECT INTO $OUTDEV	; placed orders	
	UR_number = ea_URN.alias
	, patient_name = p.name_full_formatted  ;"xxxx"	
	, patient_id = o.person_id	
	, encntr_dates = concat(format(e_orig.arrive_dt_tm, "dd/mm/yy hh:mm"), " - ", format(e_orig.depart_dt_tm, "dd/mm/yy hh:mm"))	
	, visit_no = ea_visit.alias	
	, o.encntr_id	
	, facility_at_time_of_order = uar_get_code_display(e_orig.loc_facility_cd)	
	, unit_at_time_of_order = if(elh.loc_nurse_unit_cd > 0) uar_get_code_display(elh.loc_nurse_unit_cd)	
	else uar_get_code_display(e_orig.loc_nurse_unit_cd)	
	endif	
;	, current_facility = if(e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_facility_cd)	
;	else "no current facility"	
;	endif	
;	, current_unit = if(e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_nurse_unit_cd)	
;	else "no current unit"	
;	endif	
	, order_type = evaluate (o.orig_ord_as_flag,	
	0, "Normal Order",	
	1, "Prescription/Discharge Order",	
	2, "Recorded / Home Meds",	
	3, "Patient Owns Meds",	
	4, "Pharmacy Charge Only",	
	5, "Satellite (Super Bill) Meds"	
	)	
;	, med_order_type = uar_get_code_display(o.med_order_type_cd)	
	, original_order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_placed_by = p_o_a_order.name_full_formatted	
	, order_projected_stop_date = format(o.projected_stop_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, current_order_status = uar_get_code_display(o.order_status_cd)	
	, order_status_last_update = format(o.status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_status_last_updater = if(o.order_id > 0 and o.status_prsnl_id = 0) "0"	
	else p_o_stat.name_full_formatted	
	endif	
	, order_last_update = format(o.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_last_updater = if(o.order_id > 0 and o.updt_id = 0) "0"	
	else p_o.name_full_formatted	
	endif	
	, specimen_type = o_d8.oe_field_display_value 	
	, o.clinical_display_line	
	, o.order_id	
	, o.ordered_as_mnemonic	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)	
	, synonym_id = o.synonym_id	
	, order_rank = dense_rank() over (partition by 0	
		order by	
		o.orig_order_dt_tm	
		, o.status_dt_tm	
		, o.order_id	
		)
		
FROM
	orders o
	,prsnl p_o		
	,prsnl p_o_stat 
	,encounter e_orig 	
	,order_detail o_d8
	,encntr_alias ea_URN
	,encntr_alias ea_visit 	
	,encntr_loc_hist elh 	
	,order_action o_a_order 
	,prsnl p_o_a_order 	
	,person p 	
	,order_catalog_synonym ocs	
;	, (left JOIN encounter e_curr on e_curr.person_id = o.person_id	
;	and e_curr.encntr_type_cd in (309308, 309310)	; 'Inpatient' and 'Emergency' from codeset 71
;	and e_curr.active_ind = 1	
;	and e_curr.arrive_dt_tm < sysdate	; patient arrived in the past
;	and e_curr.depart_dt_tm = null	; but has not yet departed
;	)	
		
PLAN	o	
	WHERE	
    ; o.synonym_id =
	o.orig_order_dt_tm 
		BETWEEN 
			CNVTDATETIME("15-JAN-2023 00:00:00") 
			AND 
			CNVTDATETIME("16-JAN-2023 00:00:00")

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
		and	o.catalog_type_cd in (2513.00); LABORATORY (PATHOLOGY)	
		;and	o.synonym_id  in ()	
JOIN	p_o	
		WHERE p_o.person_id = o.updt_id
JOIN	p_o_stat
		where p_o_stat.person_id = o.status_prsnl_id		
JOIN	o_d8
		WHERE
		o_d8.order_id = o.order_id
		and
		o_d8.oe_field_id = 12584	; 'Specimen Type' oef field
JOIN	e_orig
		where
		e_orig.encntr_id = o.encntr_id
		AND
		e_orig.encntr_type_cd = 309310	;Emergency Encounter Orders only
		/*
		CODE_VALUE	DISPLAY
		309308	Inpatient
		309309	Outpatient
		309310	Emergency
		309313	Pre-admit
		4085029	Unmatched
		4085032	Private
		4085028	Historical
		4038555	Community Client
		4038556	Not Applicable
		4038557	Same Day
		4038558	Unknown
		87933542	No Visit
		*/
JOIN	ea_URN
		WHERE ea_URN.encntr_id = o.encntr_id	
		and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
		and ea_URN.active_ind = 1	; active URNs only
		and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only		
JOIN	ea_visit
		WHERE ea_visit.encntr_id = o.encntr_id	
		and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
		and ea_visit.active_ind = 1	; active FIN NBRs only
		and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only	
JOIN	elh	
		WHERE elh.encntr_id = o.encntr_id
		and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
		and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
		and elh.beg_effective_dt_tm < o.orig_order_dt_tm	; encounter location began before order was placed
		and elh.end_effective_dt_tm >  o.orig_order_dt_tm	; encounter location ended after order was placed
	
JOIN	o_a_order
		WHERE o_a_order.order_id = o.order_id	
	 	and o_a_order.action_type_cd = 2534	; 'order' from codeset 6003	
;where	o_a_order.updt_id = 1235678	; orders placed by …
;and	o_a_order.updt_dt_tm between cnvtdatetime("01-DEC-2022") and cnvtdatetime("10-DEC-2022")	; ORGINAL ORDER between dates
JOIN	p_o_a_order
		WHERE p_o_a_order.person_id = o_a_order.action_personnel_id
JOIN	p
		WHERE p.person_id = o.person_id
JOIN	ocs
		WHERE ocs.synonym_id = o.synonym_id
;JOIN	e_curr	
		
ORDER BY		
	o.orig_order_dt_tm	
	, o.status_dt_tm	
	, o.order_id	
	, ea_URN.alias	
		
WITH	time = 10, FORMAT

END
GO