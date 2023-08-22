drop program wh_sctb_report go
create program wh_sctb_report

/*************************************************************************************************
 * REPORT NAME: Specialist Clinic Tracking Board
 * OBEJCT: wh_sch_med_spec_tracking
 * DESCRIPTION: This report identifies appointments and encounters.
 * VERSION HISTORY:
 * VERSION	AUTHOR			DATE			NOTES
 * 	  n/a	Stephen Mattes	xx/xx/xxxx		Initial version
 ************************************************************************************************/

/*************************************************************************************************
 * Prompt
 ************************************************************************************************/
prompt
	"Report Start Date:" = "SYSDATE"                  ;* Select Report Start Date....
	, "Report End Date:" = "SYSDATE"                  ;* Select Report End Date....
	, "Facility" = ""
	, "Location Group" = VALUE("0")
	, "Episode Program" = VALUE(0.0)
	, "Ext Code Set Med Service" = VALUE("Any (*)")
	, "Speciality" = VALUE(0.0)
	, "Appointment Type" = VALUE(0)
	, "Resource" = VALUE("0          ")
	, "Mode of Contact" = VALUE("0")
	, "Appointment Status" = VALUE("0")
	, "Report Type" = "D"
	, "Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.

with START, STOP, FACILITY_CD, LOCATION_GROUP_CD_LIST,
	EPISODE_PROGRAM_CD_LIST, ECSMS_FIELD_VALUE_LIST, MEDICAL_SERVICE_CD_LIST,
	APPOINTMENT_TYPE_CD_LIST, RESOURCE_CD_LIST, MODE_OF_CONTACT_CD_LIST,
	APPOINTMENT_STATUS_CD_LIST, REPORT_TYPE, OUTDEV
;execute wh_sctb_report "01-JAN-2023 00:00:00", "01-JUL-2023 00:00:00", 85758822, 0, 0, "Any (*)", 0, 0, 0, 0, 0, "D", 0 go
 /* Test prompts
SELECT INTO $OUTDEV
	report_start_date 				= $START
	, report_end_date 				= $STOP
	, facility			 			= uar_get_code_display(cnvtreal($FACILITY_CD))
	, report_type			 		= $REPORT_TYPE
FROM
	(dummyt d1 with seq = 1)
WITH format, separator = " "
go to exit_script
; */
/*************************************************************************************************
 * Declare record structure
 ************************************************************************************************/
free record appt
record appt (
	1 cnt 							= i4
	1 rpt_start_dq8					= dq8
	1 rpt_stop_dq8					= dq8
	1 rpt_person_id					= f8
	1 qual [*]
		2 pt_ur						= c20	; field 1
		2 pt_lastname				= c100	; field 2.last
		2 pt_firstname				= c100	; field 2.first
		2 pt_home					= c20	; field 3
		2 pt_mobile					= c20	; field 4
		2 pt_languatge_cd			= f8	; field 5
		2 pt_interp_required_cd		= f8	; field 6
		2 pt_dob_dq8				= dq8	; field 7
		2 pt_sex_cd					= f8	; field 8
		2 appt_type_cd				= f8	; field 9
		2 appt_facility_cd			= f8	; field 10.fac
		2 appt_location_cd			= f8	; field 10.nu
		2 appt_resource_cd			= f8	; field 11
		2 appt_dt_tm_dq8			= dq8	; field 12, 13
		2 mode_of_contact_cd		= f8	; field 14
		2 appt_status_cd 			= f8	; field 15 when the appointment is cancelled will be code set 14233 o/w codeset 14232
		2 appt_status_codeset		= f8	; field 15 codeset
		2 appt_checkin_dt_tm_dq8	= dq8	; field 16
		2 appt_in_room_dt_tm_dq8	= dq8	; field 17
		2 appt_checkout_dt_tm_dq8	= dq8	; field 18
		2 appt_noshow_dt_tm_dq8		= dq8	; field 19
		2 appt_sch_comment			= c100	; field 20
		2 ref_expiry_dt_tm_dq8		= dq8	; field 21
		2 ecsms						= c100	; field 22
		2 outcome_of_attendance_cd	= f8 	; field 23
		2 appt_mbs_elig				= c255	; field 24
		2 reason_for_visit			= c255	; encounter.reason_for_visit
		2 mbs_consent_cd			= f8	; encntr_info(info_sub_type_cd=MBSCONSENT on 356).value_cd
		2 referral_source_cd		= f8	; pm_wait_list.referral_source_cd
		2 review_order_placed		= c3	; field 25
		2 mbs_order_placed			= c3	; field 26
		2 wait_time_tbs_mins_f8		= f8	; field 27
		2 financial_class_cd		= f8	; new field
		2 person_id					= f8	; meta-data
		2 sch_event_id				= f8	; meta-data
		2 schedule_id				= f8	; meta-data
		2 sch_state_cd				= f8	; meta-data
		2 sch_action_cd_latest		= f8	; meta-data
		2 encntr_id					= f8	; meta-data
		2 order_id_mbs				= f8	; meta-data
		2 order_cd_mbs				= f8	; meta-data
		2 order_id_review			= f8	; meta-data
		2 med_service_cd			= f8	; meta-data
		2 order_cd_review			= f8	; meta-data
		2 episode_program_cd		= f8	; meta-data
		2 include					= i1	; meta-data 1=include, not(1)=exclude
)
free record summary
record summary (
	1 cnt 							= i4
	1 qual [*]
		2 item						= c40
		2 value						= f8
)
/*************************************************************************************************
 * Declare subroutines
 ************************************************************************************************/

/*************************************************************************************************
 * Declare variables
 ************************************************************************************************/
declare rpt_string 									= vc
declare	expand_cntr									= i4 with noconstant(-1)
declare debug 										= c100 with noconstant("")
declare phone_type_cd_home							= f8 with constant(uar_get_code_by("MEANING", 43,"HOME"))
declare phone_type_cd_mobile						= f8 with constant(uar_get_code_by("MEANING", 43,"MOBILE"))
declare activity_type_cd_mbs						= f8 with constant(uar_get_code_by("DISPLAYKEY",106,"MBSCODES"))
declare order_status_cd_deleted						= f8 with constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
declare order_status_cd_discontinued				= f8 with constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
declare order_status_cd_cancelled					= f8 with constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELLED"))
declare info_sub_type_cd_referral_expiry_dt_tm		= f8 with constant(uar_get_code_by("DISPLAYKEY",356,"REFERRALEXPIRYDATETIME"))
declare info_sub_type_cd_mbs_consent				= f8 with constant(uar_get_code_by("DISPLAYKEY",356,"MBSCONSENT"))
/*************************************************************************************************
 * Write out prompt values and define operators
 ************************************************************************************************/
set appt->rpt_start_dq8 	= cnvtdatetime($START)
set appt->rpt_stop_dq8 	= cnvtdatetime($STOP)
set rpt_string = build2("Specialist Clinic Tracking Board Report: ", format(appt->rpt_start_dq8, "dd/mm/yyyy;;d"), " - ", \
	format(appt->rpt_stop_dq8, "dd/mm/yyyy;;d"))
call echo(rpt_string)
;************************************************************************************************
; Parse the prompts.
;************************************************************************************************
execute wh_sctb_list_prompt_proc:group1 "LOCATION_GROUP", "REPORT", $LOCATION_GROUP_CD_LIST, 0, 0, 0, $FACILITY_CD
execute wh_sctb_list_prompt_proc:group1 "APPT_TYPE", "REPORT", $APPOINTMENT_TYPE_CD_LIST, $EPISODE_PROGRAM_CD_LIST, \
	$ECSMS_FIELD_VALUE_LIST, $MEDICAL_SERVICE_CD_LIST
execute wh_sctb_list_prompt_proc:group1 "CONTACT_MODE", "REPORT", $MODE_OF_CONTACT_CD_LIST
execute wh_sctb_list_prompt_proc:group1 "APPT_STATUS", "REPORT", $APPOINTMENT_STATUS_CD_LIST
execute wh_sctb_list_prompt_proc:group1 "RESOURCE", "REPORT", $RESOURCE_CD_LIST
 /* Test generic record: location_groups, episode_programs, extended_code_set_medical_services, medical_services
; appointment_types, modes_of_contact, appointment_statuses, resources
SELECT INTO $OUTDEV
;	code_value											= trim(cnvtstring(appointment_statuses->qual[d1.seq]->code_value))
;	, code_value_disp									= uar_get_code_display(appointment_statuses->qual[d1.seq]->code_value)
	field_value											= trim(extended_code_set_medical_services->qual[d1.seq]->field_value)
FROM
	(dummyt d1 with seq = value(extended_code_set_medical_services->cnt))
PLAN d1
	WHERE extended_code_set_medical_services->cnt										!= 0
;ORDER BY code_value_disp
ORDER BY field_value
WITH format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Find Appointments attached to encounters
;************************************************************************************************
call echo(concat("Starting appointment query at ",format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	sch_appt  										sa
	, sch_event  									se
	, sch_event_detail   							sed
    , code_value									cv1
	, encounter   									e
    , code_value_group								cvg
    , code_value									cv2
    , person										p
    , encntr_alias									ea
	, person_patient 								pp
PLAN sa
	WHERE sa.beg_dt_tm 								BETWEEN cnvtdatetime(appt->rpt_start_dq8) AND cnvtdatetime(appt->rpt_stop_dq8)
	AND sa.sch_state_cd								!= value(uar_get_code_by("MEANING", 14233, "RESCHEDULED"))
JOIN se
	WHERE se.sch_event_id 							= sa.sch_event_id
JOIN sed
	WHERE se.sch_event_id 							= sed.sch_event_id
	AND sed.version_dt_tm							> sysdate
	AND sed.oe_field_id 							= value(uar_get_code_by("DISPLAYKEY",16449,"SCHEDULINGDELIVERYMODE"))
	AND EXPAND(expand_cntr, 1, appointment_types->cnt, se.appt_type_cd, appointment_types->qual[expand_cntr]->code_value)
	AND EXPAND(expand_cntr, 1, modes_of_contact->cnt, sed.oe_field_value, modes_of_contact->qual[expand_cntr]->code_value)
JOIN cv1
	WHERE sed.oe_field_id 							= cv1.code_value
	AND cv1.code_set 								= 16449
JOIN e
	WHERE e.encntr_id 								= sa.encntr_id
	AND EXPAND(expand_cntr, 1, medical_services->cnt, e.med_service_cd, medical_services->qual[expand_cntr]->code_value)
	AND e.loc_nurse_unit_cd IN (
	SELECT sa.child_id
		FROM sch_assoc sa
		WHERE EXPAND(expand_cntr, 1, location_groups->cnt, sa.parent_id, location_groups->qual[expand_cntr]->code_value)
		AND sa.active_ind 							= 1
		AND sa.data_source_meaning					= "LOCATION"
	)
JOIN cvg
	WHERE e.med_service_cd							= cvg.child_code_value
	AND cvg.code_set								= 34
JOIN cv2
	WHERE cvg.parent_code_value						= cv2.code_value
	AND cv2.code_set								= 101556
	AND cv2.active_ind								= 1
	AND EXPAND(expand_cntr, 1, episode_programs->cnt, cv2.code_value, episode_programs->qual[expand_cntr]->code_value)
JOIN ea
	WHERE e.encntr_id 								= ea.encntr_id
	AND ea.alias_pool_cd 							= value(uar_get_code_by("DISPLAYKEY", 263, "WHSURNUMBER"))
	AND ea.encntr_alias_type_cd 					= value(uar_get_code_by("DISPLAYKEY", 319, "URN"))
	AND ea.active_ind 								= 1
	AND ea.end_effective_dt_tm 						> sysdate
JOIN p
	WHERE e.person_id 								= p.person_id
	AND p.active_ind 								= 1
	AND p.end_effective_dt_tm 						> sysdate
JOIN pp
	where p.person_id								= pp.person_id
	and pp.active_ind								= 1
	and pp.end_effective_dt_tm						> sysdate

ORDER BY sa.encntr_id, sa.schedule_seq desc
HEAD sa.encntr_id
	appt->cnt = appt->cnt +1
	if(mod(appt->cnt, 100) = 1)
		stat = alterlist(appt->qual, appt->cnt + 99)
	endif

	appt->qual[appt->cnt]->pt_ur					= ea.alias
	appt->qual[appt->cnt]->pt_lastname				= p.name_last
	appt->qual[appt->cnt]->pt_firstname				= p.name_first
	appt->qual[appt->cnt]->pt_languatge_cd			= p.language_cd
	appt->qual[appt->cnt]->pt_interp_required_cd	= pp.interp_required_cd
	appt->qual[appt->cnt]->pt_dob_dq8				= p.birth_dt_tm
	appt->qual[appt->cnt]->pt_sex_cd				= p.sex_cd
	appt->qual[appt->cnt]->appt_type_cd		 		= se.appt_type_cd
	appt->qual[appt->cnt]->appt_location_cd 		= e.loc_nurse_unit_cd; sa.appt_location_cd
	appt->qual[appt->cnt]->appt_dt_tm_dq8			= sa.beg_dt_tm
	appt->qual[appt->cnt]->mode_of_contact_cd		= sed.oe_field_value
	appt->qual[appt->cnt]->sch_state_cd 			= sa.sch_state_cd
	appt->qual[appt->cnt]->med_service_cd 			= e.med_service_cd
	appt->qual[appt->cnt]->reason_for_visit			= e.reason_for_visit
	appt->qual[appt->cnt]->person_id 				= sa.person_id
	appt->qual[appt->cnt]->sch_event_id 			= sa.sch_event_id
	appt->qual[appt->cnt]->schedule_id	 			= sa.schedule_id
	appt->qual[appt->cnt]->encntr_id	 			= e.encntr_id
	appt->qual[appt->cnt]->episode_program_cd		= cv2.code_value
	appt->qual[appt->cnt]->financial_class_cd		= e.financial_class_cd
	appt->qual[appt->cnt]->include					= 0; The subsequent filters will increment it.
FOOT REPORT
	stat											= alterlist(appt->qual, appt->cnt)
WITH format, expand = 1
call echo(concat("Ending appointment query at ", format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), "."))
call echo(concat("appt->cnt=", trim(cnvtstring(appt->cnt)), "."))
if(curqual <= 0)
 go to send_error
endif
 /* Test appointments
select into $OUTDEV
	ur													= trim(appt->qual[d.seq]->pt_ur)
	, financial_class									= trim(uar_get_code_display(appt->qual[d.seq]->financial_class_cd))
;	, medical_service									= trim(uar_get_code_display(appt->qual[d.seq]->med_service_cd))
;	, episode_program									= trim(uar_get_code_display(appt->qual[d.seq]->episode_program_cd))
;	, last_name											= trim(appt->qual[d.seq]->pt_lastname)
;	, first_name										= trim(appt->qual[d.seq]->pt_firstname)
;	, home_phone										= "TODO"
;	, mobile											= "TODO"
;	, language_spoken									= "TODO"
;	, interpreter_required								= "TODO"
;	, date_of_birth										= format(appt->qual[d.seq]->pt_dob_dq8 ,"dd/mm/yyyy hh:mm;;d")
;	, sex												= trim(uar_get_code_display(appt->qual[d.seq]->pt_sex_cd))
;	, appointment_type									= trim(uar_get_code_display(appt->qual[d.seq]->appt_type_cd))
;	, appointment_location								= trim(uar_get_code_display(appt->qual[d.seq]->appt_location_cd))
;	, appointment_dt_tm									= format(appt->qual[d.seq]->appt_dt_tm_dq8 ,";;Q")
;	, mode_of_contact									= trim(uar_get_code_display(appt->qual[d.seq]->mode_of_contact_cd))
;	, sch_state											= trim(uar_get_code_display(appt->qual[d.seq]->sch_state_cd))
;	, appointment_checkin_dt_tm							= "TODO"
;	, appointment_in_room_dt_tm							= "TODO"
;	, appointment_checkout_dt_tm						= "TODO"
;	, appointment_dna_dt_tm								= "TODO"
;	, scheduling_comments								= "TODO"
;	, referral_expiry									= "TODO"
;	, code_val_extension								= "TODO"
;	, outcome											= "TODO"
;	, mbs_eligible										= "TODO"
;	, review_order_placed								= "TODO"
;	, mbs_order_placed									= "TODO"
;	, wait_time_to_be_seen								= "TODO"
;	, person_id 										= trim(cnvtstring(appt->qual[d.seq]->person_id))
;	, sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
;	, schedule_id										= trim(cnvtstring(appt->qual[d.seq]->schedule_id))
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Resource from sch_appt
;************************************************************************************************
call echo(concat("Starting Resource query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, sch_appt												sa
PLAN d
	WHERE appt->cnt											!= 0
JOIN sa
	WHERE sa.sch_event_id									= appt->qual[d.seq]->sch_event_id
	AND EXPAND(expand_cntr, 1, resources->cnt, sa.resource_cd, resources->qual[expand_cntr]->code_value)
	AND sa.role_meaning										in ("RESOURCE","ATTENDING")
	AND sa.active_ind										= 1
DETAIL
	appt->qual[d.seq]->appt_resource_cd 					= sa.resource_cd
	appt->qual[d.seq]->include								= 1
WITH format, expand = 1

call echo(concat("Ending Resource query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test Resource
select into $OUTDEV
	sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, resource											= uar_get_code_display(appt->qual[d.seq]->appt_resource_cd)
	, include											= trim(cnvtstring(appt->qual[d.seq]->include))
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
	AND appt->qual[d.seq]->include						= 1
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Time of Check In, Time of In Room, Time of Check Out, Time of DNA (No Show) from sch_event_action
; Also get the latest sch_action_cd. Filter in all appointments except those rescheduled to another appointment.
;************************************************************************************************
call echo(concat("Starting sch_event_action query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, sch_event_action										sea
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 1
JOIN sea
	WHERE sea.sch_event_id									= appt->qual[d.seq]->sch_event_id
	AND sea.schedule_id										= appt->qual[d.seq]->schedule_id
	AND sea.sch_action_cd									IN (
																value(uar_get_code_by("MEANING", 14232, "CONFIRM"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATARRVED"))
																, value(uar_get_code_by("MEANING", 14232, "CHECKIN"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATREADY"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATFINISH"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATINROOM"))
																, value(uar_get_code_by("MEANING", 14232, "CHECKOUT"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYPHYSIC"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYNURSE"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYMIDLEV"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYGEN1"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYGEN2"))
																, value(uar_get_code_by("MEANING", 14232, "HOLD"))
																, value(uar_get_code_by("MEANING", 14232, "CANCEL"))
																, value(uar_get_code_by("MEANING", 14232, "NOSHOW"))
																, value(uar_get_code_by("MEANING", 14232, "RESCHEDULE")))
	AND sea.active_ind										= 1
ORDER BY sea.sch_event_id, sea.action_dt_tm asc
; Ordering the results by ascending action_dt_tm ensures the dt_tm saved to the appt record are the most
; recently collected ones.
DETAIL
	CASE (uar_get_code_meaning(sea.sch_action_cd))
	OF "CHECKIN" : appt->qual[d.seq]->appt_checkin_dt_tm_dq8			= sea.action_dt_tm
	OF "PTPATINROOM" : appt->qual[d.seq]->appt_in_room_dt_tm_dq8		= sea.action_dt_tm
	OF "CHECKOUT" : appt->qual[d.seq]->appt_checkout_dt_tm_dq8			= sea.action_dt_tm
	OF "NOSHOW" : appt->qual[d.seq]->appt_noshow_dt_tm_dq8				= sea.action_dt_tm
	ENDCASE
FOOT sea.schedule_id
	IF (null != appt->qual[d.seq]->appt_checkin_dt_tm_dq8)
		IF (null != appt->qual[d.seq]->appt_in_room_dt_tm_dq8)
			appt->qual[d.seq]->wait_time_tbs_mins_f8 = datetimediff(appt->qual[d.seq]->appt_in_room_dt_tm_dq8, \
				appt->qual[d.seq]->appt_checkin_dt_tm_dq8, 4)
		ELSEIF (null != appt->qual[d.seq]->appt_checkout_dt_tm_dq8)
			appt->qual[d.seq]->wait_time_tbs_mins_f8 = datetimediff(appt->qual[d.seq]->appt_checkout_dt_tm_dq8, \
				appt->qual[d.seq]->appt_checkin_dt_tm_dq8, 4)
		ENDIF
	ENDIF
	appt->qual[d.seq]->sch_action_cd_latest					= sea.sch_action_cd
	; Filter-in appointments either not cancelled OR (if cancelled) not rescheduled.
	; Within that cohort filter-in appoitments to match the prompt selection
	IF ((value(uar_get_code_by("MEANING", 14233, "CANCELED")) != appt->qual[d.seq]->sch_state_cd) or \
		(value(uar_get_code_by("MEANING", 14232, "RESCHEDULE")) != appt->qual[d.seq]->sch_action_cd_latest))
		; The Appointment Status to show is cancelled or (if not cancelled) or the latest action
		IF ((value(uar_get_code_by("MEANING", 14233, "CANCELED")) = appt->qual[d.seq]->sch_state_cd))
			appt->qual[d.seq]->appt_status_cd						= appt->qual[d.seq]->sch_state_cd
			appt->qual[d.seq]->appt_status_codeset					= 14233
		ELSE
			appt->qual[d.seq]->appt_status_cd						= appt->qual[d.seq]->sch_action_cd_latest
			appt->qual[d.seq]->appt_status_codeset					= 14232
		ENDIF
		; Filter-in appoitments to match the prompt selection
		FOR (i = 1 to size(appointment_statuses->qual, 5))
			IF ((2 > appt->qual[d.seq]->include) AND (appt->qual[d.seq]->appt_status_cd = \
				appointment_statuses->qual[i]->code_value))
				appt->qual[d.seq]->include							= 2
			ENDIF
		ENDFOR
	ENDIF
WITH format

call echo(concat("Ending sch_event_action query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test sch_event_action
select into $OUTDEV
	sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, person_id											= trim(cnvtstring(appt->qual[d.seq]->person_id))
	, schedule_id										= trim(cnvtstring(appt->qual[d.seq]->schedule_id))
;	, appointment_dt_tm									= format(appt->qual[d.seq]->appt_dt_tm_dq8 ,";;Q")
;	, appt_checkin_dt_tm								= format(appt->qual[d.seq]->appt_checkin_dt_tm_dq8 ,";;Q")
;	, appt_in_room_dt_tm								= format(appt->qual[d.seq]->appt_in_room_dt_tm_dq8 ,";;Q")
;	, appt_checkout_dt_tm								= format(appt->qual[d.seq]->appt_checkout_dt_tm_dq8 ,";;Q")
;	, appt_noshow_dt_tm									= format(appt->qual[d.seq]->appt_noshow_dt_tm_dq8 ,";;Q")
;	, wait_time_tbs_hrs									= trim(cnvtstring(floor(appt->qual[d.seq]->wait_time_tbs_mins_f8 / 60)))
;	, wait_time_tbs_mins								= trim(cnvtstring(mod(appt->qual[d.seq]->wait_time_tbs_mins_f8, 60)))
	, sch_state											= trim(uar_get_code_display(appt->qual[d.seq]->sch_state_cd))
	, sch_action_cd_latest								= trim(uar_get_code_display(appt->qual[d.seq]->sch_action_cd_latest))
	, appt_status_cd									= trim(uar_get_code_display(appt->qual[d.seq]->appt_status_cd))
	, appt_status_codeset								= trim(cnvtstring(appt->qual[d.seq]->appt_status_codeset))
	, include											= trim(cnvtstring(appt->qual[d.seq]->include))
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Extended Codeset Medical Service
;************************************************************************************************
call echo(concat("Starting ecms query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, code_value_extension 									ecsms
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 2
JOIN ecsms
	WHERE appt->qual[d.seq]->med_service_cd					= ecsms.code_value
	AND cnvtupper(ecsms.field_name) 						= "CORRESPONDENCE_AREA"
	AND EXPAND(expand_cntr, 1, extended_code_set_medical_services->cnt, ecsms.field_value, \
		extended_code_set_medical_services->qual[expand_cntr]->field_value)
DETAIL
	appt->qual[d.seq]->ecsms								= trim(ecsms.field_value)
	appt->qual[d.seq]->include								= 3
WITH format, expand = 1

call echo(concat("Ending ecms query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Extended Codeset Medical Service
select into $OUTDEV
	sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, person_id											= trim(cnvtstring(appt->qual[d.seq]->person_id))
	, encntr_id											= trim(cnvtstring(appt->qual[d.seq]->encntr_id))
	, med_service										= trim(uar_get_code_display(appt->qual[d.seq]->med_service_cd))
	, med_service_cd									= trim(cnvtstring(appt->qual[d.seq]->med_service_cd))
	, ecsms												= trim(appt->qual[d.seq]->ecsms)
	, include											= trim(cnvtstring(appt->qual[d.seq]->include))
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect MBS eligibility
;************************************************************************************************
call echo(concat("Starting MBS eligibility at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, sch_event_detail   									sed
	, order_entry_fields   									oef
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN sed
	WHERE sed.sch_event_id									= appt->qual[d.seq]->sch_event_id
	AND sed.oe_field_value 									> 0
JOIN oef
	WHERE sed.oe_field_id									= oef.oe_field_id
	AND oef.description 									= "Sch MBS Eligible"
DETAIL
	appt->qual[d.seq]->appt_mbs_elig						= sed.oe_field_display_value
WITH format

call echo(concat("Ending MBS eligibility query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* MBS eligibility
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, appt_mbs_elig											= trim(appt->qual[d.seq]->appt_mbs_elig)
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect MBS orders
;************************************************************************************************
call echo(concat("Starting MBS orders at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
	sch_event_id											= appt->qual[d.seq]->sch_event_id
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, orders			   									o
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN o
	WHERE o.encntr_id										= appt->qual[d.seq]->encntr_id
	AND o.activity_type_cd 									= activity_type_cd_mbs
	AND o.order_status_cd not in (order_status_cd_deleted, order_status_cd_discontinued, order_status_cd_cancelled)
ORDER BY appt->qual[d.seq]->sch_event_id, o.orig_order_dt_tm desc
HEAD sch_event_id
	appt->qual[d.seq]->mbs_order_placed						= "Yes"
	appt->qual[d.seq]->order_id_mbs							= o.order_id
	appt->qual[d.seq]->order_cd_mbs							= o.catalog_cd
WITH format

call echo(concat("Ending MBS orders query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* MBS orders
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, encntr_id												= trim(cnvtstring(appt->qual[d.seq]->encntr_id))
	, order_id_mbs											= trim(cnvtstring(appt->qual[d.seq]->order_id_mbs))
	, order_cd_mbs											= trim(uar_get_code_display(appt->qual[d.seq]->order_cd_mbs))
	, mbs_order_placed										= trim(appt->qual[d.seq]->mbs_order_placed)
FROM
	(dummyt d with seq = value(appt->cnt))
PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect review orders
;************************************************************************************************
call echo(concat("Starting review orders at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
	sch_event_id											= appt->qual[d.seq]->sch_event_id
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, orders			   									o
	, code_value											cv
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN o
	WHERE o.encntr_id										= appt->qual[d.seq]->encntr_id
;	AND o.order_status_cd not in (order_status_cd_deleted, order_status_cd_discontinued, order_status_cd_cancelled)
JOIN cv
	WHERE o.catalog_cd										= cv.code_value
	AND cv.display 											like "*OP Review"
ORDER BY appt->qual[d.seq]->sch_event_id, o.orig_order_dt_tm desc
HEAD sch_event_id
	appt->qual[d.seq]->review_order_placed					= "Yes"
	appt->qual[d.seq]->order_id_review						= o.order_id
	appt->qual[d.seq]->order_cd_review						= o.catalog_cd
WITH format

call echo(concat("Ending review orders query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test review orders
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, encntr_id												= trim(cnvtstring(appt->qual[d.seq]->encntr_id))
	, order_id_review										= trim(cnvtstring(appt->qual[d.seq]->order_id_review))
	, order_cd_review										= trim(uar_get_code_display(appt->qual[d.seq]->order_cd_review))
	, review_order_placed									= trim(appt->qual[d.seq]->review_order_placed)
FROM
	(dummyt d with seq = value(appt->cnt))
PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Scheduling Comments
;************************************************************************************************
call echo(concat("Starting Scheduling Comments at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, sch_event_comm	   									sec
	, long_text			   									lt
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN sec
	WHERE sec.sch_event_id									= appt->qual[d.seq]->sch_event_id
	AND sec.text_type_meaning								= "COMMENT"
	AND sec.sub_text_meaning								= "COMMENT"
	AND sec.version_dt_tm									> sysdate
	AND sec.text_id											> 0
JOIN lt
	WHERE sec.text_id										= lt.long_text_id
DETAIL
	appt->qual[d.seq]->appt_sch_comment						= check(substring(1, 100, lt.long_text))
WITH format

call echo(concat("Ending Scheduling Comments query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test Scheduling Comments
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, appt_sch_comment										= trim(appt->qual[d.seq]->appt_sch_comment)
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Outcome of Attendance
;************************************************************************************************
call echo(concat("Starting Outcome of Attendance query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, pm_offer 												po
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN po
	WHERE po.schedule_id									= appt->qual[d.seq]->schedule_id
	AND po.active_ind										= 1
DETAIL
	appt->qual[d.seq]->outcome_of_attendance_cd				= po.outcome_of_attendance_cd
WITH format

call echo(concat("Ending Outcome of Attendance query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test Outcome of Attendance
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, outcome_of_attendance_cd								= uar_get_code_display(appt->qual[d.seq]->outcome_of_attendance_cd)
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Referral Source
;************************************************************************************************
call echo(concat("Starting Referral Source query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, pm_wait_list											pmwl
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN pmwl
	WHERE pmwl.encntr_id									= appt->qual[d.seq]->encntr_id
	AND pmwl.active_ind										= 1
	AND pmwl.end_effective_dt_tm							> sysdate
DETAIL
	appt->qual[d.seq]->referral_source_cd					= pmwl.referral_source_cd
WITH format

call echo(concat("Ending Referral Source query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test Referral Source
select into $OUTDEV
	encntr_id												= trim(cnvtstring(appt->qual[d.seq]->encntr_id))
	, referral_source										= uar_get_code_display(appt->qual[d.seq]->referral_source_cd)
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect Referral Expiry D/T and MBS Consent
;************************************************************************************************
call echo(concat("Starting Referral Expiry D/T query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, encntr_info 											ei
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN ei
	WHERE ei.encntr_id										= appt->qual[d.seq]->encntr_id
	AND ei.info_sub_type_cd
		IN (info_sub_type_cd_referral_expiry_dt_tm
			, info_sub_type_cd_mbs_consent)
	AND ei.end_effective_dt_tm								> sysdate
	AND ei.active_ind										= 1
DETAIL
	CASE (ei.info_sub_type_cd)
	OF info_sub_type_cd_referral_expiry_dt_tm:
		appt->qual[d.seq]->ref_expiry_dt_tm_dq8				= ei.value_dt_tm
	OF info_sub_type_cd_mbs_consent:
		appt->qual[d.seq]->mbs_consent_cd					= ei.value_cd
	ENDCASE
WITH format

call echo(concat("Ending Referral Expiry D/T query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test Referral Expiry D/T
select into $OUTDEV
	sch_event_id											= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
	, ref_expiry_dt_tm										= format(appt->qual[d.seq]->ref_expiry_dt_tm_dq8, "dd/mm/yyyy;;d")
FROM
	(dummyt d with seq = value(appt->cnt))

PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Collect home and mobile phone numbers
;************************************************************************************************
call echo(concat("Starting phone number query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt d with seq 										= value(appt->cnt))
	, phone													ph
PLAN d
	WHERE appt->cnt											!= 0
	AND appt->qual[d.seq]->include							= 3
JOIN ph
	WHERE ph.parent_entity_id								= appt->qual[d.seq]->person_id
	AND ph.parent_entity_name								= "PERSON"
	AND ph.phone_type_cd in (phone_type_cd_home, phone_type_cd_mobile)
	AND ph.end_effective_dt_tm 								> sysdate
	AND ph.active_ind 										= 1
DETAIL
	CASE (ph.phone_type_cd)
	OF phone_type_cd_home : appt->qual[d.seq]->pt_home		= ph.phone_num
	OF phone_type_cd_mobile : appt->qual[d.seq]->pt_mobile	= ph.phone_num
	ENDCASE
WITH format

call echo(concat("Ending phone number query at ", \
format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), " curqual=", trim(cnvtstring(curqual)), "."))
 /* Test phones
select into $OUTDEV
	person_id											= trim(cnvtstring(appt->qual[d.seq]->person_id))
	, pt_ur												= trim(appt->qual[d.seq]->pt_ur)
	, pt_lastname										= trim(appt->qual[d.seq]->pt_lastname)
	, pt_firstname										= trim(appt->qual[d.seq]->pt_firstname)
	, sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
;	, pt_home											= trim(appt->qual[d.seq]->pt_home)
;	, pt_mobile											= trim(appt->qual[d.seq]->pt_mobile)
	, include											= trim(cnvtstring(appt->qual[d.seq]->include))
FROM
	(dummyt d with seq = value(appt->cnt))
PLAN d
	WHERE appt->cnt										!= 0
ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
with format, separator = " "
go to exit_script
; */
if ("D" = $REPORT_TYPE)
	;************************************************************************************************
	; Excel output
	;************************************************************************************************
	select into $OUTDEV
		appointment_dt_tm									= format(appt->qual[d.seq]->appt_dt_tm_dq8 ,";;Q")
		, ur												= trim(appt->qual[d.seq]->pt_ur)
		, last_name											= trim(appt->qual[d.seq]->pt_lastname)
		, first_name										= trim(appt->qual[d.seq]->pt_firstname)
		, date_of_birth										= format(appt->qual[d.seq]->pt_dob_dq8 ,"dd/mm/yyyy hh:mm;;d")
		, sex												= uar_get_code_display(appt->qual[d.seq]->pt_sex_cd)
		, mode_of_contact									= uar_get_code_display(appt->qual[d.seq]->mode_of_contact_cd)
		, appointment_type									= uar_get_code_display(appt->qual[d.seq]->appt_type_cd)
		, resource											= uar_get_code_display(appt->qual[d.seq]->appt_resource_cd)
		, scheduling_comments								= trim(appt->qual[d.seq]->appt_sch_comment)
		, appointment_status								= trim(uar_get_code_display(appt->qual[d.seq]->appt_status_cd))
		, appointment_checkin_dt_tm							= format(appt->qual[d.seq]->appt_checkin_dt_tm_dq8 ,";;Q")
		, appointment_in_room_dt_tm							= format(appt->qual[d.seq]->appt_in_room_dt_tm_dq8 ,";;Q")
		, appointment_checkout_dt_tm						= format(appt->qual[d.seq]->appt_checkout_dt_tm_dq8 ,";;Q")
		, appointment_noshow_dt_tm							= format(appt->qual[d.seq]->appt_noshow_dt_tm_dq8 ,";;Q")
		, outcome_of_attendance								= uar_get_code_display(appt->qual[d.seq]->outcome_of_attendance_cd)
		, review_order_placed								= trim(appt->qual[d.seq]->review_order_placed)
		, order_cd_review									= trim(uar_get_code_display(appt->qual[d.seq]->order_cd_review))
		, mbs_order_placed									= trim(appt->qual[d.seq]->mbs_order_placed)
		, order_cd_mbs										= trim(uar_get_code_display(appt->qual[d.seq]->order_cd_mbs))
		, mbs_eligible										= trim(appt->qual[d.seq]->appt_mbs_elig)
		, mbs_consent										= uar_get_code_display(appt->qual[d.seq]->mbs_consent_cd)
		, financial_class									= trim(uar_get_code_display(appt->qual[d.seq]->financial_class_cd))
		, ref_expiry_dt_tm									= format(appt->qual[d.seq]->ref_expiry_dt_tm_dq8, "dd/mm/yyyy;;d")
		, referral_source									= uar_get_code_display(appt->qual[d.seq]->referral_source_cd)
		, reason_for_visit									= trim(appt->qual[d.seq]->reason_for_visit)
		, language_spoken									= uar_get_code_display(appt->qual[d.seq]->pt_languatge_cd)
		, interpreter_required								= uar_get_code_display(appt->qual[d.seq]->pt_interp_required_cd)
		, home_phone										= trim(appt->qual[d.seq]->pt_home)
		, mobile											= trim(appt->qual[d.seq]->pt_mobile)
		, wait_time_tbs_hrs									= trim(cnvtstring(floor(appt->qual[d.seq]->wait_time_tbs_mins_f8 / 60)))
		, wait_time_tbs_mins								= trim(cnvtstring(mod(appt->qual[d.seq]->wait_time_tbs_mins_f8, 60)))
		, person_id 										= trim(cnvtstring(appt->qual[d.seq]->person_id))
		, sch_event_id										= trim(cnvtstring(appt->qual[d.seq]->sch_event_id))
		, schedule_id										= trim(cnvtstring(appt->qual[d.seq]->schedule_id))
		, appointment_location								= uar_get_code_display(appt->qual[d.seq]->appt_location_cd)
		, code_val_extension								= trim(appt->qual[d.seq]->ecsms)
	FROM
		(dummyt d with seq = value(appt->cnt))
	PLAN d
		WHERE appt->cnt										!= 0
		AND appt->qual[d.seq]->include						= 3
	ORDER BY appt->qual[d.seq]->person_id, appt->qual[d.seq]->sch_event_id
	with format, separator = " "
else ; "S" = $REPORT_TYPE
	free record summary
	record summary
	(	1 metadata[11]
		; Report data
		2 label														= c100
		2 value														= c100
		1 row_cnt													= i4
		1 rows[*]
		; Row data
		2 sort_key													= i1
		2 label														= c100
		2 total_wait_time_tbs										= i4
		2 count_wait_time_tbs										= i4
		2 columns[17]; also update the declares below and the initialisation for() loops
		; Column data
		3 value														= f8
	)
	set summary->row_cnt											= 0
	declare idx_report_start_date										= i1 with constant(1)
	declare idx_report_end_date											= i1 with constant(2)
	declare idx_facility												= i1 with constant(3)
	declare idx_location_group											= i1 with constant(4)
	declare idx_episode_program											= i1 with constant(5)
	declare idx_ecsms													= i1 with constant(6)
	declare idx_speciality												= i1 with constant(7)
	declare idx_appointment_type										= i1 with constant(8)
	declare idx_resource												= i1 with constant(9)
	declare idx_contact_mode											= i1 with constant(10)
	declare idx_appointment_status										= i1 with constant(11)
	declare idx_num_scheduled											= i1 with constant(1)
	declare idx_num_booked												= i1 with constant(2)
	declare idx_pt_arrived												= i1 with constant(3)
	declare idx_num_checked_in											= i1 with constant(4)
	declare idx_pt_ready												= i1 with constant(5)
	declare idx_pt_finished												= i1 with constant(6)
	declare idx_num_in_room												= i1 with constant(7)
	declare idx_num_checked_out											= i1 with constant(8)
	declare idx_num_ready_for_doctor									= i1 with constant(9)
	declare idx_num_ready_for_nurse										= i1 with constant(10)
	declare idx_num_ready_for_cnc										= i1 with constant(11)
	declare idx_num_ready_for_allied_health								= i1 with constant(12)
	declare idx_num_additional_review									= i1 with constant(13)
	declare idx_num_hold												= i1 with constant(14)
	declare idx_num_cancelled											= i1 with constant(15)
	declare idx_num_fta													= i1 with constant(16)
	declare idx_avg_wait_time_tbs										= i1 with constant(17)
	set summary->metadata[idx_report_start_date]->label					= "Report Start Date"
	set summary->metadata[idx_report_start_date]->value					= format(appt->rpt_start_dq8, "dd/mm/yyyy hh:mm;;d")
	set summary->metadata[idx_report_end_date]->label					= "Report End Date"
	set summary->metadata[idx_report_end_date]->value					= format(appt->rpt_stop_dq8, "dd/mm/yyyy hh:mm;;d")
	set summary->metadata[idx_facility]->label							= "Facility"
	set summary->metadata[idx_facility]->value							= uar_get_code_display(cnvtreal($FACILITY_CD))
	set summary->metadata[idx_location_group]->label					= "Location Group"
	set summary->metadata[idx_location_group]->value					= trim(location_groups->prompt_str)
	set summary->metadata[idx_episode_program]->label					= "Episode Program"
	set summary->metadata[idx_episode_program]->value					= trim(episode_programs->prompt_str)
	set summary->metadata[idx_ecsms]->label								= "Ext Code Set Med Service"
	set summary->metadata[idx_ecsms]->value								= trim(extended_code_set_medical_services->prompt_str)
	set summary->metadata[idx_speciality]->label						= "Specialty"
	set summary->metadata[idx_speciality]->value						= trim(medical_services->prompt_str)
	set summary->metadata[idx_appointment_type]->label					= "Appointment Type"
	set summary->metadata[idx_appointment_type]->value					= trim(appointment_types->prompt_str)
	set summary->metadata[idx_resource]->label							= "Resource"
	set summary->metadata[idx_resource]->value							= trim(resources->prompt_str)
	set summary->metadata[idx_contact_mode]->label						= "Mode of Contact"
	set summary->metadata[idx_contact_mode]->value						= trim(modes_of_contact->prompt_str)
	set summary->metadata[idx_appointment_status]->label				= "Appointment Status"
	set summary->metadata[idx_appointment_status]->value				= trim(appointment_statuses->prompt_str)

	SELECT INTO "NL:"
		med_service_cd 													= appt->qual[d.seq]->med_service_cd
	FROM
		(dummyt d with seq 												= value(appt->cnt))
		PLAN d
		WHERE appt->cnt													!= 0
		AND appt->qual[d.seq]->include									= 3
	ORDER BY med_service_cd
	HEAD REPORT
		summary->row_cnt = 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = "TOTAL"
		summary->rows[summary->row_cnt]->sort_key = 1
		summary->rows[summary->row_cnt]->total_wait_time_tbs = 0
		summary->rows[summary->row_cnt]->count_wait_time_tbs = 0
		for (i = 1 to 17)
			summary->rows[summary->row_cnt]->columns[i]->value = 0.0
		endfor
	HEAD med_service_cd
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = uar_get_code_display(med_service_cd)
		summary->rows[summary->row_cnt]->sort_key = 0
		summary->rows[summary->row_cnt]->total_wait_time_tbs = 0
		summary->rows[summary->row_cnt]->count_wait_time_tbs = 0
		for (i = 1 to 17)
			summary->rows[summary->row_cnt]->columns[i]->value = 0.0
		endfor
	DETAIL
		summary->rows[summary->row_cnt]->columns[idx_num_scheduled]->value = \
			summary->rows[summary->row_cnt]->columns[idx_num_scheduled]->value + 1
		CASE (appt->qual[d.seq]->appt_status_cd)
		OF value(uar_get_code_by("MEANING", 14232, "CONFIRM")):
			summary->rows[summary->row_cnt]->columns[idx_num_booked]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_booked]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "PTPATARRVED")):
			summary->rows[summary->row_cnt]->columns[idx_pt_arrived]->value = \
				summary->rows[summary->row_cnt]->columns[idx_pt_arrived]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "CHECKIN")):
			summary->rows[summary->row_cnt]->columns[idx_num_checked_in]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_checked_in]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "PTPATREADY")):
			summary->rows[summary->row_cnt]->columns[idx_pt_ready]->value = \
				summary->rows[summary->row_cnt]->columns[idx_pt_ready]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "PTPATFINISH")):
			summary->rows[summary->row_cnt]->columns[idx_pt_finished]->value = \
				summary->rows[summary->row_cnt]->columns[idx_pt_finished]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "PTPATINROOM")):
			summary->rows[summary->row_cnt]->columns[idx_num_in_room]->value =
				summary->rows[summary->row_cnt]->columns[idx_num_in_room]->value + 1
			IF ((0 < appt->qual[d.seq]->appt_in_room_dt_tm_dq8) and (0 < appt->qual[d.seq]->appt_checkin_dt_tm_dq8))
				summary->rows[summary->row_cnt]->total_wait_time_tbs = summary->rows[summary->row_cnt]->total_wait_time_tbs + \
					appt->qual[d.seq]->wait_time_tbs_mins_f8
				summary->rows[summary->row_cnt]->count_wait_time_tbs = summary->rows[summary->row_cnt]->count_wait_time_tbs + 1
			ENDIF
		OF value(uar_get_code_by("MEANING", 14232, "CHECKOUT")):
			summary->rows[summary->row_cnt]->columns[idx_num_checked_out]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_checked_out]->value + 1
			IF ((0 < appt->qual[d.seq]->appt_in_room_dt_tm_dq8) and (0 < appt->qual[d.seq]->appt_checkin_dt_tm_dq8))
				summary->rows[summary->row_cnt]->total_wait_time_tbs = summary->rows[summary->row_cnt]->total_wait_time_tbs + \
					appt->qual[d.seq]->wait_time_tbs_mins_f8
				summary->rows[summary->row_cnt]->count_wait_time_tbs = summary->rows[summary->row_cnt]->count_wait_time_tbs + 1
			ENDIF
		OF value(uar_get_code_by("MEANING", 14232, "SEENBYPHYSIC")):
			summary->rows[summary->row_cnt]->columns[idx_num_ready_for_doctor]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_ready_for_doctor]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "SEENBYNURSE")):
			summary->rows[summary->row_cnt]->columns[idx_num_ready_for_nurse]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_ready_for_nurse]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "SEENBYMIDLEV")):
			summary->rows[summary->row_cnt]->columns[idx_num_ready_for_cnc]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_ready_for_cnc]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "SEENBYGEN1")):
			summary->rows[summary->row_cnt]->columns[idx_num_ready_for_allied_health]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_ready_for_allied_health]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "SEENBYGEN2")):
			summary->rows[summary->row_cnt]->columns[idx_num_additional_review]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_additional_review]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "HOLD")):
			summary->rows[summary->row_cnt]->columns[idx_num_hold]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_hold]->value + 1
		OF value(uar_get_code_by("MEANING", 14233, "CANCELED")):
			summary->rows[summary->row_cnt]->columns[idx_num_cancelled]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_cancelled]->value + 1
		OF value(uar_get_code_by("MEANING", 14232, "NOSHOW")):
			summary->rows[summary->row_cnt]->columns[idx_num_fta]->value = \
				summary->rows[summary->row_cnt]->columns[idx_num_fta]->value + 1
		ENDCASE
	FOOT med_service_cd
		summary->rows[summary->row_cnt]->columns[idx_avg_wait_time_tbs]->value = \
			cnvtreal(summary->rows[summary->row_cnt]->total_wait_time_tbs) / cnvtreal(summary->rows[summary->row_cnt]->count_wait_time_tbs)
		summary->rows[1]->total_wait_time_tbs = summary->rows[1]->total_wait_time_tbs + \
			summary->rows[summary->row_cnt]->total_wait_time_tbs
		summary->rows[1]->count_wait_time_tbs = summary->rows[1]->count_wait_time_tbs + \
			summary->rows[summary->row_cnt]->count_wait_time_tbs
		for (i = 1 to 17)
			summary->rows[1]->columns[i]->value = summary->rows[1]->columns[i]->value + \
				summary->rows[summary->row_cnt]->columns[i]->value
		endfor
	FOOT REPORT
		summary->rows[1]->columns[idx_avg_wait_time_tbs]->value = \
			cnvtreal(summary->rows[1]->total_wait_time_tbs) / cnvtreal(summary->rows[1]->count_wait_time_tbs)
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = "--------------------"
		summary->rows[summary->row_cnt]->sort_key = 2
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Report Start Date: ", format(appt->rpt_start_dq8, "dd/mm/yyyy hh:mm;;d"))
		summary->rows[summary->row_cnt]->sort_key = 3
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Report End Date: ", format(appt->rpt_stop_dq8, "dd/mm/yyyy hh:mm;;d"))
		summary->rows[summary->row_cnt]->sort_key = 4
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Facility: ", uar_get_code_display(cnvtreal($FACILITY_CD)))
		summary->rows[summary->row_cnt]->sort_key = 5
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Location Group: ", trim(location_groups->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 6
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Episode Program: ", trim(episode_programs->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 7
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Ext Code Set Med Service: ", \
			trim(extended_code_set_medical_services->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 8
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Speciality: ", trim(medical_services->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 9
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Appointment Type: ", trim(appointment_types->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 10
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Resource: ", trim(resources->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 11
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Contact Mode: ", trim(modes_of_contact->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 12
		summary->row_cnt = summary->row_cnt + 1
		stat = alterlist(summary->rows, summary->row_cnt)
		summary->rows[summary->row_cnt]->label = concat("Appointment Type: ", trim(appointment_statuses->prompt_str))
		summary->rows[summary->row_cnt]->sort_key = 13


	WITH format
	SELECT INTO $OUTDEV
		Speciality								= trim(summary->rows[d.seq]->label)
		, Scheduled								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_scheduled]->value))
		, Confirmed								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_booked]->value))
		, Arrived								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_pt_arrived]->value))
		, Checked_In							= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_checked_in]->value))
		, Ready									= trim(cnvtstring(summary->rows[d.seq]->columns[idx_pt_ready]->value))
		, Finished								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_pt_finished]->value))
		, In_Room								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_in_room]->value))
		, Checked_Out							= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_checked_out]->value))
		, Ready_for_Doctor						= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_ready_for_doctor]->value))
		, Ready_for_Nurse						= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_ready_for_nurse]->value))
		, Ready_for_Nurse_Practitioner_CNC		= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_ready_for_cnc]->value))
		, Ready_for_Allied_Health				= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_ready_for_allied_health]->value))
		, Additional_Review						= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_additional_review]->value))
		, Hold									= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_hold]->value))
		, Cancelled								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_cancelled]->value))
		, No_Show								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_num_fta]->value))
		, Avg_TBS								= trim(cnvtstring(summary->rows[d.seq]->columns[idx_avg_wait_time_tbs]->value, 11
			, 2))
	FROM
		(dummyt d with seq = size(summary->rows, 5))
	PLAN d
		WHERE summary->row_cnt 					!= 0
	ORDER BY summary->rows[d.seq]->sort_key, Speciality
	WITH format, separator = " "
endif
;-----------------------START Subroutines----------------------------------------------------------

;-----------------------END Subroutines------------------------------------------------------------
;**********************************************************************************************
;END OF DISPLAY
;**********************************************************************************************

#send_error
if(curqual <= 0)
	SELECT INTO value($outdev)
	FROM
		(dummyt d with seq = 1)
	DETAIL
		row + 3
		call print(calcpos(20,3)) "Report produced no data.", row + 1
	WITH
		nocounter
	go to exit_script
endif

#exit_script
end
go
;**********************************************************************************************
;Useful CCL
;**********************************************************************************************
/*
SELECT p.name_full_formatted, e.loc_nurse_unit_cd, sa.sch_event_id, sa.beg_dt_tm, *
FROM
	sch_appt  										sa
	, sch_event  									se
	, sch_event_detail   							sed
    , code_value									cv1
	, encounter   									e
    , code_value_group								cvg
    , code_value									cv2
    , person										p
    , encntr_alias									ea
	, person_patient 								pp
PLAN sa
	WHERE sa.beg_dt_tm 								BETWEEN cnvtdatetime("23-JUL-2023 00:00:00") AND cnvtdatetime("23-JUL-2023 23:59:00")
	AND sa.sch_state_cd								!= value(uar_get_code_by("MEANING", 14233, "RESCHEDULED"))
JOIN se
	WHERE se.sch_event_id 							= sa.sch_event_id
;	AND EXPAND(expand_cntr, 1, appointment_statuses->cnt, se.sch_state_cd, appointment_statuses->qual[expand_cntr]->code_value)
JOIN sed
	WHERE se.sch_event_id 							= sed.sch_event_id
	AND sed.oe_field_id 							= value(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULINGDELIVERYMODE"))
;	AND EXPAND(expand_cntr, 1, appointment_types->cnt, se.appt_type_cd, appointment_types->qual[expand_cntr]->code_value)
;	AND EXPAND(expand_cntr, 1, modes_of_contact->cnt, sed.oe_field_value, modes_of_contact->qual[expand_cntr]->code_value)
JOIN cv1
	WHERE sed.oe_field_id 							= cv1.code_value
	AND cv1.code_set 								= 16449
JOIN e
	WHERE e.encntr_id 								= sa.encntr_id
;	AND EXPAND(expand_cntr, 1, medical_services->cnt, e.med_service_cd, medical_services->qual[expand_cntr]->code_value)
	AND e.loc_facility_cd = value(uar_get_code_by("DESCRIPTION", 220, "WHS Sunshine Hospital"))
	AND e.loc_nurse_unit_cd IN (
	SELECT sa.child_id
		FROM sch_assoc sa
;		WHERE EXPAND(expand_cntr, 1, location_groups->cnt, sa.parent_id, location_groups->qual[expand_cntr]->code_value)
		WHERE sa.active_ind 							= 1
		AND sa.data_source_meaning					= "LOCATION"
	)
JOIN cvg
	WHERE e.med_service_cd							= cvg.child_code_value
	AND cvg.code_set								= 34
JOIN cv2
	WHERE cvg.parent_code_value						= cv2.code_value
	AND cv2.code_set								= 101556
	AND cv2.active_ind								= 1
;	AND EXPAND(expand_cntr, 1, episode_programs->cnt, cv2.code_value, episode_programs->qual[expand_cntr]->code_value)
JOIN ea
	WHERE e.encntr_id 								= ea.encntr_id
	AND ea.alias_pool_cd 							= value(uar_get_code_by("DISPLAYKEY", 263, "WHSURNUMBER"))
	AND ea.encntr_alias_type_cd 					= value(uar_get_code_by("DISPLAYKEY", 319, "URN"))
	AND ea.active_ind 								= 1
	AND ea.end_effective_dt_tm 						> sysdate
JOIN p
	WHERE e.person_id 								= p.person_id
	AND p.active_ind 								= 1
	AND p.end_effective_dt_tm 						> sysdate
JOIN pp
	where p.person_id								= pp.person_id
	and pp.active_ind								= 1
	and pp.end_effective_dt_tm						> sysdate
ORDER BY sa.encntr_id, sa.schedule_seq desc
WITH MAXREC=1000, TIME=30, FORMAT(DATE, ";;Q")
*/