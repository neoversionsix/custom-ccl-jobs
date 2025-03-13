drop program wh_path_order_placed go
create program wh_path_order_placed

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Ordered After:" = "SYSDATE"
	, "Ordered Before:" = "SYSDATE"
	, "Orderable Code (number):" = ""

with OUTDEV, ORDERED_AFTER_DT, ORDERED_BEFORE_DT, ORDERABLE_CD


select	; placed orders
	domain = build(curdomain ,' (', format(sysdate,"yyyymmdd hhmm;3;q"), ")" )
	, UR_number = ea_URN.alias
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

from
	orders o
	, (left join prsnl p_o on p_o.person_id = o.updt_id)
	, (left join prsnl p_o_stat on p_o_stat.person_id = o.status_prsnl_id)
	, (left join order_detail o_d8 on o_d8.order_id = o.order_id
	and o_d8.oe_field_id = 12584	; 'Specimen Type' oef field
	)
	, (left join encounter e_orig on e_orig.encntr_id = o.encntr_id)
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = o.encntr_id
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = o.encntr_id
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)
	, (left join encntr_loc_hist elh on elh.encntr_id = o.encntr_id
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm < o.orig_order_dt_tm	; encounter location began before order was placed
	and elh.end_effective_dt_tm >  o.orig_order_dt_tm	; encounter location ended after order was placed
	)
	, (left join order_action o_a_order on o_a_order.order_id = o.order_id
	 and o_a_order.action_type_cd = 2534	; 'order' from codeset 6003
	)
	, (left join prsnl p_o_a_order on p_o_a_order.person_id = o_a_order.action_personnel_id)
	, (left join person p on p.person_id = o.person_id)
	, (left join order_catalog_synonym ocs on ocs.synonym_id = o.synonym_id)
;	, (left join encounter e_curr on e_curr.person_id = o.person_id
;	and e_curr.encntr_type_cd in (309308, 309310)	; 'Inpatient' and 'Emergency' from codeset 71
;	and e_curr.active_ind = 1
;	and e_curr.arrive_dt_tm < sysdate	; patient arrived in the past
;	and e_curr.depart_dt_tm = null	; but has not yet departed
;	)

plan	o
where	o.catalog_cd = 7346865 ; Beta 2 Microglobulin (B2MG) Level Blood
and	o.orig_order_dt_tm > cnvtdatetime("01-DEC-2024") ; orders placed after this date
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
;and	o.catalog_cd in ()
;and	o.synonym_id  in ()
join	p_o
join	p_o_stat
join	o_d8
join	e_orig
join	ea_URN
join	ea_visit
join	elh
join	o_a_order
;where	o_a_order.updt_id = 1235678	; orders placed by …
;and	o_a_order.updt_dt_tm between cnvtdatetime("01-DEC-2016") and cnvtdatetime("01-DEC-2020")	; between dates
join	p_o_a_order
join	p
join	ocs
;join	e_curr

order by
	o.orig_order_dt_tm
	, o.status_dt_tm
	, o.order_id
	, ea_URN.alias

with	time = 1200


end
go
