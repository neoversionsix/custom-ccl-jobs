select	

/*
https://community.cerner.com/t5/CCL-Discern-Explorer-Client-and-Cerner-Collaboration/Medication-scheduled-administration-charting-times-for-eMAR/m-p/251741#M9450
Medication scheduled, administration & charting times for eMAR
 */

facility = uar_get_code_display( e.loc_facility_cd )
		, unit = uar_get_code_display( e.loc_nurse_unit_cd )
		, fin = ea.alias
		, patient = p.name_full_formatted
		, o.orig_order_dt_tm "mm/dd/yyyy hh:mm"
		, admin_dt_tm = cem.admin_start_dt_tm "mm/dd/yyyy hh:mm"
		, ta.scheduled_dt_tm "mm/dd/yyyy hh:mm"
		, mins_late = datetimediff( cem.admin_start_dt_tm, ta.scheduled_dt_tm, 4 )
		, status =	if ( datetimediff( cem.admin_start_dt_tm, ta.scheduled_dt_tm, 4 ) > 0 )
						"late"
					elseif ( datetimediff( cem.admin_start_dt_tm, ta.scheduled_dt_tm, 4 ) < 0 )
						"early"
					else
						"on time"
					endif
					
		
		, catalog = trim( uar_get_code_display( ce.catalog_cd ) )
		, cem.admin_dosage
		, dosage_unit = uar_get_code_display( cem.dosage_unit_cd )
		, route = uar_get_code_display( cem.admin_route_cd )
		, frequency = uar_get_code_display( fs.frequency_cd )
		, o.simplified_display_line
		, nurse = pr.name_full_formatted
		
from	clinical_event		ce
		, ce_med_result		cem
		, task_activity		ta
		, encounter			e
		, encntr_alias		ea
		, person			p
		, prsnl				pr
		, orders			o
		, frequency_schedule	fs
		
plan	ce
where	ce.performed_dt_tm	between cnvtdatetime( cnvtdate( 090122 ), 0000 )
        					and		cnvtdatetime( cnvtdate( 090122 ), 2359 )
		and ce.result_status_cd = 601	; auth verified
		and ce.event_class_cd = 529		; med
		and ce.event_reltn_cd = 580		; child

join	cem
where	cem.event_id = ce.event_id	

join	ta
where	ta.order_id = ce.order_id
		and ta.catalog_type_cd = value( uar_get_code_by( "MEANING", 6000, "PHARMACY" ) )
		and ta.task_type_cd = value( uar_get_code_by( "MEANING", 6026, "MED" ) ) 
		and ta.scheduled_dt_tm != null
		and ta.active_ind = 1

join	e
where	e.encntr_id = ce.encntr_id
		and e.loc_facility_cd in ( 6811, 49086, 6810, 49085 )
		and e.active_ind = 1
		
join	ea
where	ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = value( uar_get_code_by( "MEANING", 319, "FIN NBR" ) )
		and ea.active_ind = 1
		
join	p
where	p.person_id = e.person_id
		and p.active_ind = 1
		
join	pr
where	pr.person_id = ce.performed_prsnl_id
		and pr.active_ind = 1
		
join	o
where	o.order_id = ce.order_id
		and o.active_ind = 1
		
join	fs
where	fs.frequency_id = o.frequency_id
		and fs.active_ind = 1

with	maxrec = 99000
		, time = 30
		, format
		, separator = " "