;********************************************************************************************************************************
;					GENERATED MODIFICATION CONTROL LOG
;********************************************************************************************************************************
;
; Mod Date			Engineer			Comment
; --- ----------	-------------------	---------------------------------------------------------
; n/a 21/06/2023	Stephen Mattes		New extract.
; 001 08/08/2023	Stephen Mattes		Changed HFNP calcs per CR001. Replaced echo with decho which can be deactivated.
;
;********************************************************************************************************************************
; Purpose - This program reports ICU Ventilation clinical information such as ventilation hours.
; The information is derived from the encounter transfers to and from ICU and Clinical Events
; recorded in iView.
;********************************************************************************************************************************

drop program wh_icu_ventilation_report go
create program wh_icu_ventilation_report

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "ICU" = VALUE(86164365.00, 86170172.00)
	, "First ICU Admission Date" = "CURDATE"
	, "Last ICU Admission Date" = "CURDATE"

with OUTDEV, ICU_CD_LIST, SDATE, EDATE
; execute wh_icu_ventilation_report 0, -2, "01-MAY-2023", "31-MAY-2023" go
; execute wh_icu_ventilation_report 0, -2, "23-FEB-2023", "23-FEB-2023" go
; execute wh_icu_ventilation_report 0, -2, "01-JAN-2023", "27-MAY-2023" go
; execute wh_icu_ventilation_report 0, -2, "13-FEB-2023", "13-FEB-2023" go

;************************************************************************************************
; Initialisations
;************************************************************************************************
declare ce_date_qual								= c40 with protect, constant("ce.event_end_dt_tm")
; other option is ce.performed_dt_tm
declare decho(msg = vc)								= null
declare debug										= i1 with constant(1) ; 0 = don't write 1 = write
;************************************************************************************************
; Subroutine decleration
;************************************************************************************************
declare process_odnp(m = i4, n = i4)				= null

;************************************************************************************************
;Variable declerations
;************************************************************************************************
declare result_status_cd_auth						= f8 with protect, constant(uar_get_code_by("MEANING", 8, "AUTH"))
declare result_status_cd_modified					= f8 with protect, constant(uar_get_code_by("MEANING", 8, "MODIFIED"))
declare result_status_cd_altered					= f8 with protect, constant(uar_get_code_by("MEANING", 8, "ALTERED"))
declare event_reltn_cd_root							= f8 with protect, constant(uar_get_code_by("MEANING", 24, "ROOT"))
declare event_reltn_cd_child						= f8 with protect, constant(uar_get_code_by("MEANING", 24, "CHILD"))
declare encntr_class_cd_inpatient					= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 321, "INPATIENT"))
declare encntr_alias_type_cd_mrn					= f8 with protect, constant(uar_get_code_by("MEANING", 319, "MRN"))
;declare ventilation_state_invasive					= c10 with protect, constant("INV")
;declare ventilation_state_noninvasive				= c10 with protect, constant("NIV")
;declare ventilation_state_nothing					= c10 with protect, constant("NIL")
;declare ventilation_state_unknown					= c10 with protect, constant("UNK")
declare ventilation_type_invasive					= c40 with protect, constant("Invasive")
declare ventilation_type_noninvasive				= c40 with protect, constant("Non-invasive")
declare ventilation_type_highflow					= c40 with protect, constant("High flow")
declare ventilation_type_unknown					= c40 with protect, constant("Unknown")
declare ventilation_type_empty						= c40 with protect, constant("Empty")
declare oxygen_delivery_t_piece						= c40 with protect, constant("T-Piece")
declare oxygen_delivery_tracheostomy_mask			= c40 with protect, constant("Tracheostomy mask")
declare oxygen_delivery_cpap						= c40 with protect, constant("CPAP")
declare oxygen_delivery_bipap						= c40 with protect, constant("BiPAP")
declare oxygen_delivery_nasal_prongs				= c40 with protect, constant("Nasal prongs")
declare oxygen_delivery_humidified_nasal_prongs		= c40 with protect, constant("Humidified nasal prongs")
declare oxygen_delivery_unknown						= c40 with protect, constant("Unknown")
declare oxygen_delivery_empty						= c40 with protect, constant("Empty")
declare	ventilator_activity_initiate				= c40 with protect, constant("Initiate")
declare	ventilator_activity_ongoing					= c40 with protect, constant("Ongoing")
declare	ventilator_activity_discontinue				= c40 with protect, constant("Discontinue/On stand-by")
declare	ventilator_activity_other_discontinue		= c40 with protect, constant("OTHER: DISCONTINUE")
declare	ventilator_activity_unknown					= c40 with protect, constant("Unknown")
declare	ventilator_activity_empty					= c40 with protect, constant("Empty")
declare oxygen_delivery_high_flow_yes				= c40 with protect, constant("Yes - High Flow")
declare oxygen_delivery_high_flow_no				= c40 with protect, constant("No")
declare oxygen_delivery_high_flow_empty				= c40 with protect, constant("Empty")
declare oxygen_delivery_high_flow_unknown			= c40 with protect, constant("Unknown")
declare tracheostomy_tube_activity_inserted			= c40 with protect, constant("Inserted")
declare trache_yes									= c40 with protect, constant("Yes")
declare trache_no									= c40 with protect, constant("No")
declare trache_unknown								= c40 with protect, constant("Unknown")
declare hours_action_start							= c40 with protect, constant("Start")
declare hours_action_stop							= c40 with protect, constant("Stop")
declare hours_action_continue						= c40 with protect, constant("Continue")
DECLARE icu											= i4 with noconstant(0)

;************************************************************************************************
; iView variables
;************************************************************************************************
declare event_cd_ventilation_type						= f8
	with protect, constant(uar_get_code_by("DISPLAY", 72, "Ventilation Type"))
declare event_cd_oxygen_delivery							= f8
	with protect, constant(uar_get_code_by("DISPLAY", 72, "Oxygen Therapy"))
declare event_cd_ventilator_activity					= f8
	with protect, constant(uar_get_code_by("DISPLAY", 72, "Ventilator Activity"))
declare event_cd_oxygen_delivery_high_flow				= f8
	with protect, constant(uar_get_code_by("DISPLAY", 72, "Oxygen Delivery - High Flow"))
declare event_cd_tracheostomy_tube_activity				= f8
	with protect, constant(uar_get_code_by("DISPLAY", 72, "Tracheostomy Tube Activity:"))

 /* Test prompt values
SELECT INTO $OUTDEV
	SDATE 													= $SDATE
	, EDATE 												= $EDATE
FROM
	(dummyt d1 with seq = 1)

PLAN d1
with format, separator = " "
go to exit_script
; */
 /* Test Declares and PowerForm variables
select into $OUTDEV
from (dummyt d1 with seq = 1)
detail
	row +3
	col 20 "$SDATE=", $SDATE
	row +1
	col 20 "$EDATE=", $EDATE
	row +1
	col 20 "result_status_cd_auth=", result_status_cd_auth
	row +1
	col 20 "result_status_cd_modified=", result_status_cd_modified
	row +1
	col 20 "result_status_cd_altered=", result_status_cd_altered
	row +1
	col 20 "event_reltn_cd_root=", event_reltn_cd_root
	row +1
	col 20 "event_reltn_cd_child=", event_reltn_cd_child
	row +1
	col 20 "event_cd_ventilation_type=", event_cd_ventilation_type
	row +1
	col 20 "event_cd_oxygen_delivery=", event_cd_oxygen_delivery
	row +1
	col 20 "event_cd_ventilator_activity=", event_cd_ventilator_activity
	row +1
	col 20 "event_cd_oxygen_delivery_high_flow=", event_cd_oxygen_delivery_high_flow
with format, separator = " "
go to exit_script
; */
 /* Test ICU Nurse Unit declares
SELECT INTO $OUTDEV
	d1_seq 													= trim(cnvtstring(d1.seq))
	, loc_nurse_unit_cd_icus								= trim(cnvtstring(loc_nurse_unit_cd_icus[d1.seq]))
FROM
	(dummyt d1 with seq = size(loc_nurse_unit_cd_icus, 5))

PLAN d1
with format, separator = " "
go to exit_script
; */
;************************************************************************************************
; ICU Stay Array.
;************************************************************************************************
free record icu_stay
record icu_stay
(	1 cnt											= i4
	1 qual[*]
		2 person_id									= f8
		2 name_last									= c200
		2 name_first								= c200
		2 sex_cd									= f8
		2 birth_dt_tm								= dq8
		2 encntr_id									= f8
		2 alias_urn									= c200
		2 reg_dt_tm									= f8
		2 disch_dt_tm								= f8
		2 los_hours									= f8
		2 los_days									= f8
		2 icu_admission_dt_tm						= dq8
		2 icu_discharge_dt_tm						= dq8
		2 hours_cutoff_dt_tm						= dq8 ; when to stop recording hours
		2 total_inv_hours							= f8
		2 total_niv_hours							= f8
		2 total_cpap_hours							= f8
		2 total_bipap_hours							= f8
		2 niv_ne_cpap_plus_bipap					= c10
		2 total_hfnp_hours							= f8
		2 total_niv_hfnp_hours						= f8
		2 los_lt_venti_hours						= c10
		2 trache									= c10
		2 iview_col_cnt								= i4
		2 iview_col[*]
			3 event_end_dt_tm						= dq8
			3 vt_event_id							= f8
			3 vt_performed_dt_tm					= dq8
			3 vt_type								= c40
			3 va_event_id							= f8
			3 va_performed_dt_tm					= dq8
			3 va_activity							= c40
			3 od_event_id							= f8
			3 od_performed_dt_tm					= dq8
			3 od_type								= c40
			3 odhf_event_id							= f8
			3 odhf_performed_dt_tm					= dq8
			3 odhf_method							= c40
			3 inv_hours_action						= c40
			3 niv_hours_action						= c40
			3 cpap_hours_action						= c40
			3 bipap_hours_action					= c40
			3 hfnp_hours_action						= c40
			3 debug									= c255
		2 debug										= c255
)
set icu_stay->cnt									= 0
;************************************************************************************************
; Encounter Array.
;************************************************************************************************
free record enc
record enc
(	1 cnt											= i4
	1 qual[*]
		2 person_id									= f8
		2 encntr_id									= f8
		2 reg_dt_tm									= f8
		2 disch_dt_tm								= f8
		2 debug										= c255
)
set enc->cnt										= 0
;************************************************************************************************
; Parse the ICU_CD_LIST prompt.
;
; Thanks to Bob Ross and Philip Weilnau of uCern for the insights!
;************************************************************************************************
free record icus
record icus
(	1 cnt											= i4
	1 qual[*]
		2 code_value								= f8
)
set icus->cnt										= 0

declare debug = c100 with noconstant("")
if(substring(1,1,reflect(parameter(parameter2($ICU_CD_LIST),0))) = "L")
	set debug = "Multiple ICUs were selected at ICU prompt"
	set lcheck = substring(1,1,reflect(parameter(parameter2($ICU_CD_LIST),icus->cnt + 1)))
	while (lcheck > " ")
		set icus->cnt = icus->cnt + 1
		set stat = alterlist(icus->qual, icus->cnt)
		set icus->qual[icus->cnt]->code_value = cnvtreal(parameter(parameter2($ICU_CD_LIST), icus->cnt))
		set lcheck = substring(1,1,reflect(parameter(parameter2($ICU_CD_LIST),icus->cnt + 1)))
	endwhile
elseif(parameter(parameter2($ICU_CD_LIST),1)= -2) ;any was selected at $gender prompt
	set debug = "Any ICUs was selected at ICU prompt"

	select into "nl:"
	from
    	code_value cv
	    , code_value_group cvg

	plan cv
    	where cv.code_set = 100067; Parent Location Unit
    	and cv.display = "ICU"
	join cvg
	    where cv.code_value = cvg.parent_code_value
    	and cvg.code_set = 220
    detail
    	icus->cnt = icus->cnt + 1
		stat = alterlist(icus->qual, icus->cnt)
		icus->qual[icus->cnt]->code_value = cvg.child_code_value
	with nocounter, separator=" ", format

else ;a single value was selected at the $gender prompt
	set debug = "A single ICU was selected at ICU prompt"
	set icus->cnt = 1
	set stat = alterlist(icus->qual, icus->cnt)
	set icus->qual[1]->code_value = $ICU_CD_LIST
endif

 /* Test prompt processing
SELECT INTO $OUTDEV
	debug 												= debug
FROM
	(dummyt d1 with seq = 1)
WITH format, separator = " "
go to exit_script
; */
 /* Test icus record
SELECT INTO $OUTDEV
	code_value											= trim(cnvtstring(icus->qual[d1.seq]->code_value))
FROM
	(dummyt d1 with seq = value(icus->cnt))

PLAN d1
	WHERE icus->cnt										!= 0
WITH format, separator = " "
go to exit_script
; */
 /* Test expand on icus record inside the detail clause
SET debug = ""
DECLARE icu	= i4 with noconstant(0)
SELECT INTO "NL:"
FROM encntr_loc_hist elh
	WHERE elh.transaction_dt_tm >= cnvtdate(05152023)
	AND elh.transaction_dt_tm < cnvtdate(06032023)
DETAIL
	IF (expand(icu, 1, icus->cnt, elh.loc_nurse_unit_cd, icus->qual[icu]->code_value))
		debug = build(debug, uar_get_code_display(elh.loc_nurse_unit_cd), ",")
	ENDIF
WITH format, separator = " "
SELECT INTO $OUTDEV
	debug 												= debug
FROM
	(dummyt d1 with seq = 1)
WITH format, separator = " "
go to exit_script
; */

;************************************************************************************************
; Find encounters overlapping the Prompt Date Range and at the Prompt Facility
; and with an ELH record at ICU during the Prompt Date Range.
;************************************************************************************************
SELECT INTO "NL:"
FROM
	encounter										e
	, person 										p
	,encntr_loc_hist elh
PLAN e
	WHERE e.active_ind								= 1
	AND (e.disch_dt_tm								>= cnvtdatetime(cnvtdate2($SDATE, "DD-MMM-YYYY"), 0)
		OR e.disch_dt_tm 							= null)
	AND e.reg_dt_tm									<= cnvtdatetime(cnvtdate2($EDATE, "DD-MMM-YYYY"), 235959)
	AND e.encntr_class_cd							= encntr_class_cd_inpatient

JOIN p
	WHERE e.person_id								= p.person_id
	AND p.active_ind								= 1
JOIN elh
	WHERE e.encntr_id 		 						= elh.encntr_id
	AND elh.transaction_dt_tm 						>= cnvtdatetime(cnvtdate2($SDATE,"dd-mmm-yyyy"),0)
	AND elh.transaction_dt_tm 						<= cnvtdatetime(cnvtdate2($EDATE,"dd-mmm-yyyy"),235959)
	AND elh.active_ind		  						= 1
	AND EXPAND(icu, 1, icus->cnt, elh.loc_nurse_unit_cd, icus->qual[icu]->code_value)
;	AND
;		 ((($ICU_CD_LIST							= -2)
;		 	AND (elh.loc_nurse_unit_cd				in (86164365, 86170172)))
;		 OR (elh.loc_nurse_unit_cd					= $ICU_CD_LIST))
ORDER BY e.encntr_id
HEAD e.encntr_id
	enc->cnt = enc->cnt + 1
	if (mod(enc->cnt,1000) = 1)
		stat = alterlist(enc->qual, enc->cnt + 999)
	endif
	enc->qual[enc->cnt]->person_id 					= e.person_id
	enc->qual[enc->cnt]->encntr_id 					= e.encntr_id
	enc->qual[enc->cnt]->reg_dt_tm 					= e.reg_dt_tm
	enc->qual[enc->cnt]->disch_dt_tm				= e.disch_dt_tm
FOOT report
	stat = alterlist(enc->qual, enc->cnt)
WITH format
 /* Test encounters
SELECT INTO $OUTDEV
	person_id 												= trim(cnvtstring(enc->qual[d1.seq]->person_id))
	, encntr_id 											= trim(cnvtstring(enc->qual[d1.seq]->encntr_id))
FROM
	(dummyt d1 with seq = value(enc->cnt))

PLAN d1
	WHERE enc->cnt										!= 0
WITH format, separator = " "
call echo(build("curqual=", trim(cnvtstring(curqual)), "."))
go to exit_script
; */
;************************************************************************************************
; For each eligible encounter get the encounter location history for the whole encounter.
; Scan the encounter location history looking for transfers into ICU and out of ICU. For transfers into ICU
; during the Prompt Date Range add an ICU Stay Record. For transfers out of ICU where the encounter is in
; ICU add the ICU Discharge D/T.
; A transfer into ICU is a ELH record with location ICU and either its the first record of the encounter
; or the immediately prior ELH record is not ICU. A transfer out of ICU is a ELH record with location not
; ICU and the encounter is in ICU.
; If they're still in ICU at the end of the encounter then set ICU Discharge D/T to the encounter discharge D/T.
;************************************************************************************************
declare loc_nurse_unit_cd_prior_ward				= f8 with protect, noconstant(-1)
declare ward_xfr_cnt								= i4 with protect, noconstant(0)
declare in_icu										= i1 with protect, noconstant(0)
SELECT INTO "NL:"
FROM
	(dummyt d1 with seq = value(enc->cnt))
	,encntr_loc_hist elh
PLAN d1
	WHERE enc->cnt										!= 0
JOIN elh
	WHERE enc->qual[d1.seq]->encntr_id				= elh.encntr_id
	AND elh.active_ind		  						= 1
ORDER BY
	elh.encntr_id
	, elh.transaction_dt_tm asc
	, elh.loc_nurse_unit_cd
HEAD elh.encntr_id
	ward_xfr_cnt = 0
	loc_nurse_unit_cd_prior_ward = -1
	in_icu = 0
	enc->qual[d1.seq]->debug = ""
HEAD elh.loc_nurse_unit_cd
	; skip elh records with empty loc_nurse_unit_cd
	if (0 < elh.loc_nurse_unit_cd)
	ward_xfr_cnt = ward_xfr_cnt + 1

	; is this the first location on the encounter
enc->qual[d1.seq]->debug = build(enc->qual[d1.seq]->debug, "[", trim(cnvtstring(ward_xfr_cnt)), \
", ", trim(cnvtstring(in_icu)),"]:")
		if (-1 = loc_nurse_unit_cd_prior_ward) ; first location of encnounter
;enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd), ",")
			; is this an ICU location
			if (EXPAND(icu, 1, icus->cnt, elh.loc_nurse_unit_cd, icus->qual[icu]->code_value))
				; is the transfer within the date range
				if ((cnvtdatetime(cnvtdate2($SDATE,"dd-mmm-yyyy"),0) <= elh.transaction_dt_tm) and
					(cnvtdatetime(cnvtdate2($EDATE,"dd-mmm-yyyy"),235959) >= elh.transaction_dt_tm))
					icu_stay->cnt = icu_stay->cnt + 1
					if (mod(icu_stay->cnt,1000) = 1)
						stat = alterlist(icu_stay->qual, icu_stay->cnt + 999)
					endif
					icu_stay->qual[icu_stay->cnt]->person_id = enc->qual[d1.seq]->person_id
					icu_stay->qual[icu_stay->cnt]->encntr_id = enc->qual[d1.seq]->encntr_id
					icu_stay->qual[icu_stay->cnt]->reg_dt_tm = enc->qual[d1.seq]->reg_dt_tm
					icu_stay->qual[icu_stay->cnt]->disch_dt_tm = enc->qual[d1.seq]->disch_dt_tm
					icu_stay->qual[icu_stay->cnt]->icu_admission_dt_tm = elh.transaction_dt_tm
					icu_stay->qual[icu_stay->cnt]->trache = trache_no
					in_icu = 1
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=I,")
					loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
				else
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=X,")
					loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
				endif
			else
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=X,")
				loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
			endif
		else ; not first location of encounter
;enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd), ",")
			; is this an ICU location
			if (EXPAND(icu, 1, icus->cnt, elh.loc_nurse_unit_cd, icus->qual[icu]->code_value))
				; is the transfer within the date range
				if ((cnvtdatetime(cnvtdate2($SDATE,"dd-mmm-yyyy"),0) <= elh.transaction_dt_tm) and
					(cnvtdatetime(cnvtdate2($EDATE,"dd-mmm-yyyy"),235959) >= elh.transaction_dt_tm))
					; is the prior location not ICU
					if (NOT EXPAND(icu, 1, icus->cnt, loc_nurse_unit_cd_prior_ward, icus->qual[icu]->code_value)) ; prior location is not ICU
						icu_stay->cnt = icu_stay->cnt + 1
						if (mod(icu_stay->cnt,1000) = 1)
							stat = alterlist(icu_stay->qual, icu_stay->cnt + 999)
						endif
						icu_stay->qual[icu_stay->cnt]->person_id = enc->qual[d1.seq]->person_id
						icu_stay->qual[icu_stay->cnt]->encntr_id = enc->qual[d1.seq]->encntr_id
						icu_stay->qual[icu_stay->cnt]->reg_dt_tm = enc->qual[d1.seq]->reg_dt_tm
						icu_stay->qual[icu_stay->cnt]->disch_dt_tm = enc->qual[d1.seq]->disch_dt_tm
						icu_stay->qual[icu_stay->cnt]->icu_admission_dt_tm = elh.transaction_dt_tm
						icu_stay->qual[icu_stay->cnt]->trache = trache_no
						in_icu = 1
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=I,")
						loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
					else ; prior location is ICU
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=X,")
						loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
					endif
				else ; ICU location but not within date range
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=X,")
					loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
				endif
			else ; Not ICU location
				if (1 = in_icu)
					icu_stay->qual[icu_stay->cnt]->icu_discharge_dt_tm = elh.transaction_dt_tm
					icu_stay->qual[icu_stay->cnt]->hours_cutoff_dt_tm = elh.transaction_dt_tm
					in_icu = 0
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=L,")
					loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
				else
enc->qual[d1.seq]->debug				= build(enc->qual[d1.seq]->debug, uar_get_code_display(elh.loc_nurse_unit_cd),
"@(", format(elh.transaction_dt_tm, ";;Q"),")=N,")
					loc_nurse_unit_cd_prior_ward = elh.loc_nurse_unit_cd
				endif
			endif
		endif
	endif
FOOT elh.encntr_id
	if (1 = in_icu)
		icu_stay->qual[icu_stay->cnt]->icu_discharge_dt_tm = enc->qual[d1.seq]->disch_dt_tm
		if (0 = enc->qual[d1.seq]->disch_dt_tm)
			icu_stay->qual[icu_stay->cnt]->hours_cutoff_dt_tm = SYSDATE
		else
			icu_stay->qual[icu_stay->cnt]->hours_cutoff_dt_tm = enc->qual[d1.seq]->disch_dt_tm
		endif
	endif
FOOT report
	stat = alterlist(icu_stay->qual, icu_stay->cnt)

WITH format, time=30
 /* Test encounters
SELECT INTO $OUTDEV
	person_id 												= trim(cnvtstring(enc->qual[d1.seq]->person_id))
	, encntr_id 											= trim(cnvtstring(enc->qual[d1.seq]->encntr_id))
	, reg_dt_tm												= format(enc->qual[d1.seq]->reg_dt_tm, ";;Q")
	, debug		 											= enc->qual[d1.seq]->debug
FROM
	(dummyt d1 with seq = value(enc->cnt))
PLAN d1
	WHERE enc->cnt										!= 0
ORDER BY
	person_id, encntr_id
WITH format, separator = " "
go to exit_script
; */
 /* ICU Stays
SELECT INTO $OUTDEV
	person_id 												= trim(cnvtstring(icu_stay->qual[d1.seq]->person_id))
	, encntr_id 											= trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id))
	, reg_dt_tm												= format(icu_stay->qual[d1.seq]->reg_dt_tm, ";;Q")
	, disch_dt_tm											= format(icu_stay->qual[d1.seq]->disch_dt_tm, ";;Q")
	, icu_admission_dt_tm									= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, icu_discharge_dt_tm									= format(icu_stay->qual[d1.seq]->icu_discharge_dt_tm, ";;Q")
	, hours_cutoff_dt_tm									= format(icu_stay->qual[d1.seq]->hours_cutoff_dt_tm, ";;Q")
	, debug		 											= icu_stay->qual[d1.seq]->debug
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
PLAN d1
	WHERE icu_stay->cnt										!= 0
ORDER BY
	person_id, encntr_id
WITH format, separator = " "
go to exit_script
; */
;************************************************************************************************
; Find qualifying iView recordings for each ICU Stay. Scope is recordings that contribute to hours calcs.
; These have performed_dt_tm between icu_admission_dt_tm and icu_disch_dt_tm / SYSDATE depending on whether the encounter
; is discharged when the report is run.
;************************************************************************************************
call decho(concat("Starting iView query at ",format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt 															d1 with seq = value(icu_stay->cnt))
	, clinical_event													ce

PLAN d1
	WHERE icu_stay->cnt													> 0

JOIN ce
	WHERE ce.person_id													= icu_stay->qual[d1.seq]->person_id
	AND ce.valid_until_dt_tm 											> SYSDATE
	AND ce.result_status_cd												IN
		(result_status_cd_auth
		, result_status_cd_altered
		, result_status_cd_modified)
	AND ce.view_level													= 1
	AND ce.event_cd														IN
		(event_cd_ventilation_type
		, event_cd_oxygen_delivery
		, event_cd_ventilator_activity
		, event_cd_oxygen_delivery_high_flow)
	AND parser(ce_date_qual)												>= cnvtdatetime(icu_stay->qual[d1.seq]->icu_admission_dt_tm)
	AND parser(ce_date_qual)												<= cnvtdatetime(icu_stay->qual[d1.seq]->hours_cutoff_dt_tm)
ORDER BY
	d1.seq, ce.event_end_dt_tm asc
HEAD d1.seq
	iview_col_cnt														= 0

HEAD ce.event_end_dt_tm
	iview_col_cnt = iview_col_cnt + 1
	if (mod(iview_col_cnt, 100) = 1)
		stat = alterlist(icu_stay->qual[d1.seq]->iview_col, iview_col_cnt + 99)
	endif
	icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->event_end_dt_tm 			= ce.event_end_dt_tm
	icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_type 					= ventilation_type_unknown
	icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_type 					= oxygen_delivery_unknown
	icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_activity 				= ventilator_activity_unknown
	icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_method 				= oxygen_delivery_high_flow_unknown
DETAIL
	if (event_cd_ventilation_type = ce.event_cd)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_event_id			= ce.event_id
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_performed_dt_tm	= ce.performed_dt_tm
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_type				= ce.result_val
	elseif (event_cd_oxygen_delivery = ce.event_cd)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_event_id			= ce.event_id
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_performed_dt_tm	= ce.performed_dt_tm
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_type				= ce.result_val
	elseif (event_cd_ventilator_activity = ce.event_cd)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_event_id			= ce.event_id
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_performed_dt_tm	= ce.performed_dt_tm
icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->debug = ce.result_val
		; if result_val starts with "Other: Discontinue" then set va_activity to ventilator_activity_discontinue
		if (ventilator_activity_other_discontinue = cnvtupper(substring(1, textlen(trim(ventilator_activity_other_discontinue)),
			ce.result_val)))
			icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_activity 		= ventilator_activity_discontinue
		else
			icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_activity		= ce.result_val
		endif
	elseif (event_cd_oxygen_delivery_high_flow = ce.event_cd)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_event_id			= ce.event_id
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_performed_dt_tm	= ce.performed_dt_tm
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_method			= ce.result_val
	endif
FOOT ce.event_end_dt_tm
	; Any metrics still at unknown set to empty since all CEs with this event_end_dt_tm are traversed
	if (oxygen_delivery_unknown = icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_type)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->od_type = oxygen_delivery_empty
	endif
	if (oxygen_delivery_high_flow_unknown = icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_method)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->odhf_method = oxygen_delivery_high_flow_empty
	endif
	if (ventilation_type_unknown = icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_type)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->vt_type = ventilation_type_empty
	endif
	if (ventilator_activity_unknown = icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_activity)
		icu_stay->qual[d1.seq]->iview_col[iview_col_cnt]->va_activity = ventilator_activity_empty
	endif

FOOT d1.seq
	icu_stay->qual[d1.seq]->iview_col_cnt									= iview_col_cnt
	stat																	= alterlist(icu_stay->qual[d1.seq]->iview_col, iview_col_cnt)
WITH format;, maxrec=100, time=60
call decho(concat("Ending iView query at ", format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), "."))
 /* Test icu_stay array of records data items
SELECT INTO $OUTDEV
	debug								= trim(icu_stay->qual[d1.seq]->debug)
	, person_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->person_id)) else "" endif
	, encntr_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id)) else "" endif
	, icu_admission_dt_tm				= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, icu_discharge_dt_tm				= format(icu_stay->qual[d1.seq]->icu_discharge_dt_tm, ";;Q")
	, event_end_dt_tm					= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->event_end_dt_tm, ";;Q")
	, vt_event_id						= trim(cnvtstring(icu_stay->qual[d1.seq]->iview_col[d3.seq]->vt_event_id))
	, vt_performed_dt_tm				= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->vt_performed_dt_tm, ";;Q")
	, vt_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->vt_type
	, od_event_id						= trim(cnvtstring(icu_stay->qual[d1.seq]->iview_col[d3.seq]->od_event_id))
	, od_performed_dt_tm				= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->od_performed_dt_tm, ";;Q")
	, od_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->od_type
	, va_event_id						= trim(cnvtstring(icu_stay->qual[d1.seq]->iview_col[d3.seq]->va_event_id))
	, va_performed_dt_tm				= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->va_performed_dt_tm, ";;Q")
	, va_activity						= trim(icu_stay->qual[d1.seq]->iview_col[d3.seq]->va_activity)
	, debug_col							= trim(icu_stay->qual[d1.seq]->iview_col[d3.seq]->debug)
	, odhf_event_id						= trim(cnvtstring(icu_stay->qual[d1.seq]->iview_col[d3.seq]->odhf_event_id))
	, odhf_performed_dt_tm				= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->odhf_performed_dt_tm, ";;Q")
	, odhf_method						= icu_stay->qual[d1.seq]->iview_col[d3.seq]->odhf_method
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
PLAN d1
	WHERE icu_stay->cnt != 0
	AND maxrec(d3, size(icu_stay->qual[d1.seq]->iview_col, 5))
JOIN d2
JOIN d3
ORDER BY d1.seq asc, d3.seq asc
WITH format, separator = " ", outerjoin=d2
go to exit_script
; */
;**********************************************************************************************
; Traverse each iView column subarray and derive the Action Code of each Ventilation Metric using the Business Rules documented
; in the Detailed Requirements. For coding simplicity do so in two groups: 1. INV and NIV 2. CPAP, BiPAP and HFNP.
;**********************************************************************************************
for (i = 1 to size(icu_stay->qual, 5))
	call decho(concat("Calculating action codes for encntr_id ", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
	" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	for (j = 1 to size(icu_stay->qual[i]->iview_col, 5))
		call decho(concat("Calculating action codes for event_end_dt_tm ", \
		format(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, ";;Q"), " OD=", icu_stay->qual[i]->iview_col[j]->od_type, "."))
		case (icu_stay->qual[i]->iview_col[j]->va_activity)
		of value(ventilator_activity_initiate, ventilator_activity_ongoing, ventilator_activity_empty):
			case (icu_stay->qual[i]->iview_col[j]->vt_type)
			of value(ventilation_type_invasive):
				call decho(concat("I,N Calc: starting inv."))
				set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_start
				set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_stop
			of value(ventilation_type_noninvasive):
				call decho(concat("I,N Calc: starting niv."))
				set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_stop
				set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_start
			of value(ventilation_type_highflow):
				if ((0 < findstring(trim(oxygen_delivery_t_piece), icu_stay->qual[i]->iview_col[j]->od_type))
					or (0 < findstring(trim(oxygen_delivery_tracheostomy_mask), icu_stay->qual[i]->iview_col[j]->od_type)))
					call decho(concat("I,N Calc: starting inv."))
					set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_start
					set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_stop
				else
					call decho(concat("I,N Calc: stopping all."))
					set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_stop
					set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_stop
				endif
			of value(ventilation_type_empty):
				if (ventilator_activity_empty = icu_stay->qual[i]->iview_col[j]->va_activity)
					if (oxygen_delivery_empty = icu_stay->qual[i]->iview_col[j]->od_type)
						call decho(concat("I,N Calc: continuing all."))
						set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_continue
						set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_continue
					else
						call decho(concat("I,N Calc: stopping all."))
						set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_stop
						set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_stop
					endif
				else
					call decho(concat("I,N Calc: continuing all."))
					set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_continue
					set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_continue
				endif
			of value(ventilation_type_unknown):
				call echo(concat("I,N Calc: ERROR: ventilation type is unknown!"))
			else
				call echo(concat("I,N Calc ERROR: ventilation type of ", trim(icu_stay->qual[i]->iview_col[j]->vt_type) ," is invalid."))
			endcase
			if ((0 < findstring(trim(oxygen_delivery_cpap), icu_stay->qual[i]->iview_col[j]->od_type))
				and (0 < findstring(trim(oxygen_delivery_bipap), icu_stay->qual[i]->iview_col[j]->od_type)))
				call decho(concat("C,B,N Calc: starting cpap and starting bipap."))
				set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_start
				set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_start
			endif
			if ((0 < findstring(trim(oxygen_delivery_cpap), icu_stay->qual[i]->iview_col[j]->od_type))
				and (0 = findstring(trim(oxygen_delivery_bipap), icu_stay->qual[i]->iview_col[j]->od_type)))
				call decho(concat("C,B,N Calc: starting cpap and stopping bipap."))
				set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_start
				set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_stop
			endif
			if ((0 = findstring(trim(oxygen_delivery_cpap), icu_stay->qual[i]->iview_col[j]->od_type))
				and (0 < findstring(trim(oxygen_delivery_bipap), icu_stay->qual[i]->iview_col[j]->od_type)))
				call decho(concat("C,B,N Calc: stopping cpap and starting bipap."))
				set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_stop
				set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_start
			endif
			if ((0 = findstring(trim(oxygen_delivery_cpap), icu_stay->qual[i]->iview_col[j]->od_type))
				and (0 = findstring(trim(oxygen_delivery_bipap), icu_stay->qual[i]->iview_col[j]->od_type)))
				if (0 = findstring(trim(oxygen_delivery_empty), icu_stay->qual[i]->iview_col[j]->od_type))
					call decho(concat("C,B,N Calc: stopping cpap and stopping bipap."))
					set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_stop
					set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_stop
				else
					call decho(concat("C,B,N Calc: continuing cpap and continuing bipap."))
					set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_continue
					set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_continue
				endif
			endif
			call  process_odnp(i, j)
		of value(ventilator_activity_discontinue):
			call decho(concat("I,N,C,B,N Calc: stopping all."))
			set icu_stay->qual[i]->iview_col[j]->inv_hours_action = hours_action_stop
			set icu_stay->qual[i]->iview_col[j]->niv_hours_action = hours_action_stop
			set icu_stay->qual[i]->iview_col[j]->cpap_hours_action = hours_action_stop
			set icu_stay->qual[i]->iview_col[j]->bipap_hours_action = hours_action_stop
			set icu_stay->qual[i]->iview_col[j]->hfnp_hours_action = hours_action_stop
		of value(ventilator_activity_unknown):
			call echo(concat("ERROR: ventilator activity is unknown!"))
		else
			call echo(concat("ERROR: ventilator activity of ", trim(icu_stay->qual[i]->iview_col[j]->va_activity) ," is invalid."))
		endcase
	endfor
endfor
 /* Test icu_stay array of records data items
SELECT INTO $OUTDEV
	icu_admission_dt_tm					= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, event_end_dt_tm					= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->event_end_dt_tm, ";;Q")
	, va_activity						= trim(icu_stay->qual[d1.seq]->iview_col[d3.seq]->va_activity)
	, od_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->od_type
	, odhf_method						= icu_stay->qual[d1.seq]->iview_col[d3.seq]->odhf_method
	, vt_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->vt_type
	, cpap_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->cpap_hours_action
	, bipap_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->bipap_hours_action
	, hfnp_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->hfnp_hours_action
;	, inv_hours_action					= icu_stay->qual[d1.seq]->iview_col[d3.seq]->inv_hours_action
;	, niv_hours_action					= icu_stay->qual[d1.seq]->iview_col[d3.seq]->niv_hours_action
	, debug								= trim(icu_stay->qual[d1.seq]->debug)
	, person_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->person_id)) else "" endif
	, encntr_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id)) else "" endif
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
PLAN d1
	WHERE icu_stay->cnt != 0
	AND maxrec(d3, size(icu_stay->qual[d1.seq]->iview_col, 5))
JOIN d2
JOIN d3
ORDER BY d1.seq asc, d3.seq asc
WITH format, separator = " ", outerjoin=d2
go to exit_script
; */
;**********************************************************************************************
; Traverse each iView column subarray and calclate total hours.
;**********************************************************************************************
declare inv_hours_start_rec = i4 with protect, noconstant(-1)
declare niv_hours_start_rec = i4 with protect, noconstant(-1)
declare cpap_hours_start_rec = i4 with protect, noconstant(-1)
declare bipap_hours_start_rec = i4 with protect, noconstant(-1)
declare hfnp_hours_start_rec = i4 with protect, noconstant(-1)
for (i = 1 to size(icu_stay->qual, 5))
	call decho(concat("Calculating ventilation metrics for encntr_id ", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
	" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	set icu_stay->qual[i]->total_inv_hours = 0
	set icu_stay->qual[i]->total_niv_hours = 0
	set icu_stay->qual[i]->total_cpap_hours = 0
	set icu_stay->qual[i]->total_bipap_hours = 0
	set icu_stay->qual[i]->total_hfnp_hours = 0
	set inv_hours_start_rec = -1
	set niv_hours_start_rec = -1
	set cpap_hours_start_rec = -1
	set bipap_hours_start_rec = -1
	set hfnp_hours_start_rec = -1
	for (j = 1 to size(icu_stay->qual[i]->iview_col, 5))
		call decho(concat("Calculating ventilation metric for event_end_dt_tm ", \
		format(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, ";;Q"), "."))
		case (icu_stay->qual[i]->iview_col[j]->inv_hours_action)
		of hours_action_start:
			if (0 >= inv_hours_start_rec)
				set inv_hours_start_rec = j
				call decho(concat("inv start at record ", trim(cnvtstring(j)), "."))
			else
				call echo(concat("Ignoring inv already underway. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_stop:
			if (0 < inv_hours_start_rec)
				call decho(concat("inv stop at record ", trim(cnvtstring(j)), \
				" after starting at record ", trim(cnvtstring(inv_hours_start_rec)) , "."))
				set icu_stay->qual[i]->total_inv_hours = icu_stay->qual[i]->total_inv_hours +
					datetimediff(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, \
						icu_stay->qual[i]->iview_col[inv_hours_start_rec]->event_end_dt_tm, 3)
				call decho(concat("total_inv_hours=", trim(cnvtstring(icu_stay->qual[i]->total_inv_hours, 11, 2)), "."))
				set inv_hours_start_rec = -1
			else
				call echo(concat("Ignoring unmatched inv stop action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_continue:
			call echo(concat("Ignoring continue action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
				" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		else
			call echo(concat("ERROR: invalid inv_hours_action of ", trim(icu_stay->qual[i]->iview_col[j]->inv_hours_action), "."))
		endcase
		case (icu_stay->qual[i]->iview_col[j]->niv_hours_action)
		of hours_action_start:
			if (0 >= niv_hours_start_rec)
				set niv_hours_start_rec = j
				call decho(concat("niv start at record ", trim(cnvtstring(j)), "."))
			else
				call echo(concat("Ignoring niv already underway. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_stop:
			if (0 < niv_hours_start_rec)
				call decho(concat("niv stop at record ", trim(cnvtstring(j)), \
				" after starting at record ", trim(cnvtstring(niv_hours_start_rec)) , "."))
				set icu_stay->qual[i]->total_niv_hours = icu_stay->qual[i]->total_niv_hours + \
					datetimediff(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, \
					icu_stay->qual[i]->iview_col[niv_hours_start_rec]->event_end_dt_tm, 3)
				call decho(concat("total_niv_hours=", trim(cnvtstring(icu_stay->qual[i]->total_niv_hours, 11, 2)), "."))
				set niv_hours_start_rec = -1
			else
				call echo(concat("Ignoring unmatched niv stop action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_continue:
			call echo(concat("Ignoring continue action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
				" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		else
			call echo(concat("ERROR: niv_hours_action of ", trim(icu_stay->qual[i]->iview_col[j]->niv_hours_action), " is unknown."))
		endcase
		case (icu_stay->qual[i]->iview_col[j]->cpap_hours_action)
		of hours_action_start:
			if (0 >= cpap_hours_start_rec)
				set cpap_hours_start_rec = j
				call decho(concat("cpap start at record ", trim(cnvtstring(j)), "."))
			else
				call echo(concat("Ignoring cpap already underway. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_stop:
			if (0 < cpap_hours_start_rec)
				call decho(concat("cpap stop at record ", trim(cnvtstring(j)), \
				" after starting at record ", trim(cnvtstring(cpap_hours_start_rec)) , "."))
				set icu_stay->qual[i]->total_cpap_hours = icu_stay->qual[i]->total_cpap_hours +
					datetimediff(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, \
						icu_stay->qual[i]->iview_col[cpap_hours_start_rec]->event_end_dt_tm, 3)
				call decho(concat("total_cpap_hours=", trim(cnvtstring(icu_stay->qual[i]->total_cpap_hours, 11, 2)), "."))
				set cpap_hours_start_rec = -1
			else
				call echo(concat("Ignoring unmatched cpap stop action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_continue:
			call echo(concat("Ignoring continue action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
				" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		else
			call echo(concat("ERROR: cpap_hours_action of ", trim(icu_stay->qual[i]->iview_col[j]->cpap_hours_action), " is unknown."))
		endcase
		case (icu_stay->qual[i]->iview_col[j]->bipap_hours_action)
		of hours_action_start:
			if (0 >= bipap_hours_start_rec)
				set bipap_hours_start_rec = j
				call decho(concat("bipap start at record ", trim(cnvtstring(j)), "."))
			else
				call echo(concat("Ignoring bipap already underway. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_stop:
			if (0 < bipap_hours_start_rec)
				call decho(concat("bipap stop at record ", trim(cnvtstring(j)), \
				" after starting at record ", trim(cnvtstring(bipap_hours_start_rec)) , "."))
				set icu_stay->qual[i]->total_bipap_hours = icu_stay->qual[i]->total_bipap_hours + \
					datetimediff(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, \
					icu_stay->qual[i]->iview_col[bipap_hours_start_rec]->event_end_dt_tm, 3)
					call decho(concat("total_bipap_hours=", trim(cnvtstring(icu_stay->qual[i]->total_bipap_hours, 11, 2)), "."))
				set bipap_hours_start_rec = -1
			else
				call echo(concat("Ignoring unmatched bipap stop action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_continue:
			call echo(concat("Ignoring continue action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
				" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		else
			call echo(concat("ERROR: bipap_hours_action of ", trim(icu_stay->qual[i]->iview_col[j]->bipap_hours_action), " is unknown."))
		endcase
		case (icu_stay->qual[i]->iview_col[j]->hfnp_hours_action)
		of hours_action_start:
			if (0 >= hfnp_hours_start_rec)
				set hfnp_hours_start_rec = j
				call decho(concat("hfnp start at record ", trim(cnvtstring(j)), "."))
			else
				call echo(concat("Ignoring hfnp already underway. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_stop:
			if (0 < hfnp_hours_start_rec)
				call decho(concat("hfnp stop at record ", trim(cnvtstring(j)), \
				" after starting at record ", trim(cnvtstring(hfnp_hours_start_rec)) , "."))
				set icu_stay->qual[i]->total_hfnp_hours = icu_stay->qual[i]->total_hfnp_hours + \
					datetimediff(icu_stay->qual[i]->iview_col[j]->event_end_dt_tm, \
					icu_stay->qual[i]->iview_col[hfnp_hours_start_rec]->event_end_dt_tm, 3)
				call decho(concat("total_hfnp_hours=", trim(cnvtstring(icu_stay->qual[i]->total_hfnp_hours, 11, 2)), "."))
				set hfnp_hours_start_rec = -1
			else
				call echo(concat("Ignoring unmatched hfnp stop action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
					" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
			endif
		of hours_action_continue:
			call echo(concat("Ignoring continue action. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
				" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		else
			call echo(concat("ERROR: hfnp_hours_action of ", trim(icu_stay->qual[i]->iview_col[j]->hfnp_hours_action), " is unknown."))
		endcase
	endfor
	; If hours are still running after the last qualifying iView recording then end the hours at cutoff_hours_dt_tm
	if (0 < inv_hours_start_rec)
		call decho(concat("INV hours ended by cutoff. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
		" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		set icu_stay->qual[i]->total_inv_hours = icu_stay->qual[i]->total_inv_hours + \
			datetimediff(icu_stay->qual[i]->hours_cutoff_dt_tm, \
			icu_stay->qual[i]->iview_col[inv_hours_start_rec]->event_end_dt_tm, 3)
			call decho(concat("total_inv_hours=", trim(cnvtstring(icu_stay->qual[i]->total_inv_hours, 11, 2)), "."))
		set inv_hours_start_rec = -1
	else
		call echo(concat("INV hours ended by iView recording. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
			" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	endif
	if (0 < niv_hours_start_rec)
		call decho(concat("niv hours ended by cutoff. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
		" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		set icu_stay->qual[i]->total_niv_hours = icu_stay->qual[i]->total_niv_hours + \
			datetimediff(icu_stay->qual[i]->hours_cutoff_dt_tm, \
			icu_stay->qual[i]->iview_col[niv_hours_start_rec]->event_end_dt_tm, 3)
			call decho(concat("total_niv_hours=", trim(cnvtstring(icu_stay->qual[i]->total_niv_hours, 11, 2)), "."))
		set niv_hours_start_rec = -1
	else
		call echo(concat("NIV hours ended by iView recording. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
			" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	endif
	if (0 < cpap_hours_start_rec)
		call decho(concat("cpap hours ended by cutoff. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
		" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		set icu_stay->qual[i]->total_cpap_hours = icu_stay->qual[i]->total_cpap_hours + \
			datetimediff(icu_stay->qual[i]->hours_cutoff_dt_tm, \
			icu_stay->qual[i]->iview_col[cpap_hours_start_rec]->event_end_dt_tm, 3)
		call decho(concat("total_cpap_hours=", trim(cnvtstring(icu_stay->qual[i]->total_cpap_hours, 11, 2)), "."))
		set cpap_hours_start_rec = -1
	else
		call echo(concat("cpap hours ended by iView recording. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
			" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	endif
	if (0 < bipap_hours_start_rec)
		call decho(concat("bipap hours ended by cutoff. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
		" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		set icu_stay->qual[i]->total_bipap_hours = icu_stay->qual[i]->total_bipap_hours + \
			datetimediff(icu_stay->qual[i]->hours_cutoff_dt_tm, \
			icu_stay->qual[i]->iview_col[bipap_hours_start_rec]->event_end_dt_tm, 3)
			call decho(concat("total_bipap_hours=", trim(cnvtstring(icu_stay->qual[i]->total_bipap_hours, 11, 2)), "."))
		set bipap_hours_start_rec = -1
	else
		call echo(concat("bipap hours ended by iView recording. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
			" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	endif
	if (0 < hfnp_hours_start_rec)
		call decho(concat("hfnp hours ended by cutoff. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
		" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
		set icu_stay->qual[i]->total_hfnp_hours = icu_stay->qual[i]->total_hfnp_hours + \
			datetimediff(icu_stay->qual[i]->hours_cutoff_dt_tm, \
			icu_stay->qual[i]->iview_col[hfnp_hours_start_rec]->event_end_dt_tm, 3)
			call decho(concat("total_hfnp_hours=", trim(cnvtstring(icu_stay->qual[i]->total_hfnp_hours, 11, 2)), "."))
		set hfnp_hours_start_rec = -1
	else
		call echo(concat("hfnp hours ended by iView recording. encntr_id=", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
			" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	endif
endfor
 /* Test icu_stay array of records data items
SELECT INTO $OUTDEV
	hours_cutoff_dt_tm					= format(icu_stay->qual[d1.seq]->hours_cutoff_dt_tm, ";;Q")
	, icu_admission_dt_tm					= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, event_end_dt_tm					= format(icu_stay->qual[d1.seq]->iview_col[d3.seq]->event_end_dt_tm, ";;Q")
	, va_activity						= trim(icu_stay->qual[d1.seq]->iview_col[d3.seq]->va_activity)
	, od_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->od_type
	, odhf_method						= icu_stay->qual[d1.seq]->iview_col[d3.seq]->odhf_method
	, vt_type							= icu_stay->qual[d1.seq]->iview_col[d3.seq]->vt_type
	, total_cpap_hours					= trim(cnvtstring(icu_stay->qual[d1.seq]->total_cpap_hours, 11, 2))
	, total_bipap_hours					= trim(cnvtstring(icu_stay->qual[d1.seq]->total_bipap_hours, 11, 2))
	, total_hfnp_hours					= trim(cnvtstring(icu_stay->qual[d1.seq]->total_hfnp_hours, 11, 2))
	, cpap_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->cpap_hours_action
	, bipap_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->bipap_hours_action
	, hfnp_hours_action 				= icu_stay->qual[d1.seq]->iview_col[d3.seq]->hfnp_hours_action
;	, inv_hours_action					= icu_stay->qual[d1.seq]->iview_col[d3.seq]->inv_hours_action
;	, niv_hours_action					= icu_stay->qual[d1.seq]->iview_col[d3.seq]->niv_hours_action
	, debug								= trim(icu_stay->qual[d1.seq]->debug)
	, person_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->person_id)) else "" endif
	, encntr_id 						= if (1 = d2.seq) trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id)) else "" endif
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
PLAN d1
	WHERE icu_stay->cnt != 0
	AND maxrec(d3, size(icu_stay->qual[d1.seq]->iview_col, 5))
JOIN d2
JOIN d3
ORDER BY d1.seq asc, d3.seq asc
WITH format, separator = " ", outerjoin=d2
go to exit_script
; */
;**********************************************************************************************
; Find trache iView information
; icu_stay[]->trache was defaulted to no when the icu_stay was created. Here, if the person
; has any trache clinical_events overlapping the icu_stay then default it back to unknown and
; set it depending on the query result.
;**********************************************************************************************
call decho(concat("Starting trache iView query at ",format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d")))
SELECT INTO "NL:"
FROM
	(dummyt 															d1 with seq = value(icu_stay->cnt))
	, clinical_event													ce
PLAN d1
	WHERE icu_stay->cnt													> 0
JOIN ce
	WHERE ce.person_id													= icu_stay->qual[d1.seq]->person_id
	AND ce.valid_until_dt_tm 											> SYSDATE
	AND ce.result_status_cd												IN
		(result_status_cd_auth
		, result_status_cd_altered
		, result_status_cd_modified)
	AND ce.view_level													= 1
	AND ce.event_cd														= event_cd_tracheostomy_tube_activity
	AND parser(ce_date_qual)											>= cnvtdatetime(icu_stay->qual[d1.seq]->icu_admission_dt_tm)
	AND parser(ce_date_qual)											<= cnvtdatetime(icu_stay->qual[d1.seq]->hours_cutoff_dt_tm)
ORDER BY
	d1.seq, ce.event_end_dt_tm asc
HEAD d1.seq
	icu_stay->qual[d1.seq]->trache								 		= trache_unknown
DETAIL
	if ((event_cd_tracheostomy_tube_activity = ce.event_cd) and
		(tracheostomy_tube_activity_inserted = ce.result_val))
		icu_stay->qual[d1.seq]->trache									= trache_yes
	endif
FOOT d1.seq
	; Any metrics still at unknown set to empty since all CEs with this event_end_dt_tm are traversed
	if (trache_unknown = icu_stay->qual[d1.seq]->trache)
		icu_stay->qual[d1.seq]->trache 									= trache_no
	endif
WITH format;, maxrec=100, time=60
call decho(concat("Ending trache iView query at ", format(cnvtdatetime(curdate,curtime3),"dd/mm/yyyy hh:mm;;d"), \
" curqual=", trim(cnvtstring(curqual)), "."))
 /* Test trache
SELECT INTO $OUTDEV
	person_id 												= trim(cnvtstring(icu_stay->qual[d1.seq]->person_id))
	, encntr_id 											= trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id))
	, reg_dt_tm												= format(icu_stay->qual[d1.seq]->reg_dt_tm, ";;Q")
	, disch_dt_tm											= format(icu_stay->qual[d1.seq]->disch_dt_tm, ";;Q")
	, icu_admission_dt_tm									= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, icu_discharge_dt_tm									= format(icu_stay->qual[d1.seq]->icu_discharge_dt_tm, ";;Q")
	, trache												= icu_stay->qual[d1.seq]->trache
;	, debug		 											= icu_stay->qual[d1.seq]->debug
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
PLAN d1
	WHERE icu_stay->cnt										!= 0
ORDER BY
	person_id, encntr_id
WITH format, separator = " "
go to exit_script
; */
;**********************************************************************************************
; Traverse the report and calculate derived fields
;**********************************************************************************************
declare max_venti_hours					= f8 with noconstant(0)
for (i = 1 to size(icu_stay->qual, 5))
	call decho(concat("Calculating derived fields for encntr_id ", trim(cnvtstring(icu_stay->qual[i]->encntr_id)), \
	" and icu_stay beginning ", format(icu_stay->qual[i]->icu_admission_dt_tm, ";;Q"), "."))
	if (icu_stay->qual[i]->total_niv_hours != (icu_stay->qual[i]->total_bipap_hours + icu_stay->qual[i]->total_cpap_hours))
		set icu_stay->qual[i]->niv_ne_cpap_plus_bipap = "Yes"
	else
		set icu_stay->qual[i]->niv_ne_cpap_plus_bipap = ""
	endif
	set icu_stay->qual[i]->total_niv_hfnp_hours = icu_stay->qual[i]->total_niv_hours + icu_stay->qual[i]->total_hfnp_hours
	set icu_stay->qual[i]->los_hours = datetimediff(icu_stay->qual[i]->icu_discharge_dt_tm, \
		icu_stay->qual[i]->icu_admission_dt_tm, 3)
	set icu_stay->qual[i]->los_days = datetimediff(icu_stay->qual[i]->icu_discharge_dt_tm, \
		icu_stay->qual[i]->icu_admission_dt_tm, 1)
	set max_venti_hours = 0
	if (max_venti_hours > icu_stay->qual[i]->total_inv_hours)
		set max_venti_hours = icu_stay->qual[i]->total_inv_hours
	endif
	if (max_venti_hours > icu_stay->qual[i]->total_niv_hours)
		set max_venti_hours = icu_stay->qual[i]->total_niv_hours
	endif
	if (max_venti_hours > icu_stay->qual[i]->total_bipap_hours)
		set max_venti_hours = icu_stay->qual[i]->total_bipap_hours
	endif
	if (max_venti_hours > icu_stay->qual[i]->total_cpap_hours)
		set max_venti_hours = icu_stay->qual[i]->total_cpap_hours
	endif
	if (max_venti_hours > icu_stay->qual[i]->total_hfnp_hours)
		set max_venti_hours = icu_stay->qual[i]->total_hfnp_hours
	endif
	if (icu_stay->qual[i]->los_hours < max_venti_hours)
		set icu_stay->qual[i]->los_lt_venti_hours = "Yes"
	else
		set icu_stay->qual[i]->los_lt_venti_hours = ""
	endif
endfor
 /* Test derived fields
SELECT INTO $OUTDEV
	person_id 												= trim(cnvtstring(icu_stay->qual[d1.seq]->person_id))
	, encntr_id 											= trim(cnvtstring(icu_stay->qual[d1.seq]->encntr_id))
	, reg_dt_tm												= format(icu_stay->qual[d1.seq]->reg_dt_tm, ";;Q")
	, disch_dt_tm											= format(icu_stay->qual[d1.seq]->disch_dt_tm, ";;Q")
	, icu_admission_dt_tm									= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, icu_discharge_dt_tm									= format(icu_stay->qual[d1.seq]->icu_discharge_dt_tm, ";;Q")
	, niv_ne_cpap_plus_bipap								= icu_stay->qual[d1.seq]->niv_ne_cpap_plus_bipap
	, total_niv_hfnp_hours									= trim(cnvtstring(icu_stay->qual[d1.seq]->total_niv_hfnp_hours))
	, los_hours												= trim(cnvtstring(icu_stay->qual[d1.seq]->los_hours, 11, 1))
	, los_days												= trim(cnvtstring(icu_stay->qual[d1.seq]->los_days, 11, 1))
	, los_lt_venti_hours									= icu_stay->qual[d1.seq]->los_lt_venti_hours
;	, debug		 											= icu_stay->qual[d1.seq]->debug
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
PLAN d1
	WHERE icu_stay->cnt										!= 0
ORDER BY
	person_id, encntr_id
WITH format, separator = " "
go to exit_script
; */
;**********************************************************************************************
; Get person and encntr_alias information
;**********************************************************************************************
SELECT INTO "NL:"
FROM
	(dummyt 												d1 with seq = value(icu_stay->cnt))
	, person												p
	, encntr_alias											ea
PLAN d1
	WHERE icu_stay->cnt										!= 0
JOIN p
	WHERE icu_stay->qual[d1.seq]->person_id					= p.person_id
	AND p.active_ind										= 1
JOIN ea
	WHERE icu_stay->qual[d1.seq]->encntr_id					= ea.encntr_id
	AND ea.encntr_alias_type_cd								= encntr_alias_type_cd_mrn
	AND ea.active_ind										= 1
DETAIL
	icu_stay->qual[d1.seq]->name_last						= p.name_last
	icu_stay->qual[d1.seq]->name_first						= p.name_first
	icu_stay->qual[d1.seq]->alias_urn						= ea.alias
	icu_stay->qual[d1.seq]->sex_cd							= p.sex_cd
	icu_stay->qual[d1.seq]->birth_dt_tm						= p.birth_dt_tm

WITH format, separator = " "
;**********************************************************************************************
; Write final output.
;**********************************************************************************************
SELECT INTO $OUTDEV
	name_last												= icu_stay->qual[d1.seq]->name_last
	, name_first											= icu_stay->qual[d1.seq]->name_first
	, urn													= icu_stay->qual[d1.seq]->alias_urn
	, sex													= uar_get_code_display(icu_stay->qual[d1.seq]->sex_cd)
	, dob													= format(icu_stay->qual[d1.seq]->birth_dt_tm, "dd/mm/yyyy;;d")
	, hosp_admit_dt_tm										= format(icu_stay->qual[d1.seq]->reg_dt_tm, ";;Q")
	, hosp_disch_dt_tm										= format(icu_stay->qual[d1.seq]->disch_dt_tm, ";;Q")
	, icu_admit_dt_tm										= format(icu_stay->qual[d1.seq]->icu_admission_dt_tm, ";;Q")
	, icu_disch_dt_tm										= format(icu_stay->qual[d1.seq]->icu_discharge_dt_tm, ";;Q")
	, los_hrs												= if (0 < icu_stay->qual[d1.seq]->icu_discharge_dt_tm)
																	trim(cnvtstring(icu_stay->qual[d1.seq]->los_hours, 11, 1))
																else
																	""
																endif
	, los_days												= if (0 < icu_stay->qual[d1.seq]->icu_discharge_dt_tm)
																	trim(cnvtstring(icu_stay->qual[d1.seq]->los_days, 11, 1))
																else
																	""
																endif
	, total_inv_hours										= trim(cnvtstring(icu_stay->qual[d1.seq]->total_inv_hours, 11, 2))
	, total_niv_hours										= trim(cnvtstring(icu_stay->qual[d1.seq]->total_niv_hours, 11, 2))
	, total_cpap_hours										= trim(cnvtstring(icu_stay->qual[d1.seq]->total_cpap_hours, 11, 2))
	, total_bipap_hours										= trim(cnvtstring(icu_stay->qual[d1.seq]->total_bipap_hours, 11, 2))
	, niv_ne_cpap_plus_bipap								= icu_stay->qual[d1.seq]->niv_ne_cpap_plus_bipap
	, total_hfnp_hours										= trim(cnvtstring(icu_stay->qual[d1.seq]->total_hfnp_hours, 11, 2))
	, total_niv_hfnp_hours									= trim(cnvtstring(icu_stay->qual[d1.seq]->total_niv_hfnp_hours, 11, 2))
	, los_lt_venti_hours									= icu_stay->qual[d1.seq]->los_lt_venti_hours
	, trache												= if ((0 < icu_stay->qual[d1.seq]->icu_discharge_dt_tm)
																	and (0 < icu_stay->qual[d1.seq]->icu_discharge_dt_tm))
																	icu_stay->qual[d1.seq]->trache
																else
																	""
																endif
;	, debug		 											= icu_stay->qual[d1.seq]->debug
FROM
	(dummyt d1 with seq = value(icu_stay->cnt))
PLAN d1
	WHERE icu_stay->cnt										!= 0
ORDER BY icu_stay->qual[d1.seq]->icu_admission_dt_tm asc, urn

WITH format, separator = " "
;**********************************************************************************************
; Subroutine - process oxygen delivery of nasal prongs
;**********************************************************************************************
subroutine process_odnp(m, n)
	call decho(concat("Starting process_odnp(", trim(cnvtstring(m)), ",", trim(cnvtstring(n)), ")."))
;	if (0 = findstring(trim(oxygen_delivery_nasal_prongs), icu_stay->qual[i]->iview_col[j]->od_type))
	if ((0 = findstring(trim(oxygen_delivery_nasal_prongs), icu_stay->qual[i]->iview_col[j]->od_type)) and
		(0 = findstring(trim(oxygen_delivery_humidified_nasal_prongs), icu_stay->qual[i]->iview_col[j]->od_type)))
		if (0 = findstring(trim(oxygen_delivery_empty), icu_stay->qual[i]->iview_col[j]->od_type))
			call decho(concat("HFNP Calc: stopping hfnp."))
			set icu_stay->qual[m]->iview_col[n]->hfnp_hours_action = hours_action_stop
		else
			call decho(concat("HFNP Calc: continuing hfnp."))
			set icu_stay->qual[m]->iview_col[n]->hfnp_hours_action = hours_action_continue
		endif
	else
		case (icu_stay->qual[m]->iview_col[n]->odhf_method)
		of value(oxygen_delivery_high_flow_yes):
			call decho(concat("HFNP Calc: starting hfnp."))
			set icu_stay->qual[m]->iview_col[n]->hfnp_hours_action = hours_action_start
		of value(oxygen_delivery_high_flow_no, oxygen_delivery_high_flow_empty):
			case (icu_stay->qual[m]->iview_col[n]->vt_type)
			of value(ventilation_type_highflow):
				call decho(concat("HFNP Calc: starting hfnp."))
				set icu_stay->qual[m]->iview_col[n]->hfnp_hours_action = hours_action_start
			of value(ventilation_type_invasive, ventilation_type_noninvasive, ventilation_type_empty):
				call decho(concat("HFNP Calc: stopping hfnp."))
				set icu_stay->qual[m]->iview_col[n]->hfnp_hours_action = hours_action_stop
			of value(ventilation_type_unknown):
				call echo(concat("HFNP Calc: ERROR: ventilation type is unknown!"))
			else
				call echo(concat("HFNP Calc: ERROR: invalide ventilation type of ", \
					trim(icu_stay->qual[m]->iview_col[n]->vt_type) ,"."))
				endcase
		of value(oxygen_delivery_high_flow_unknown):
			call echo(concat("HFNP Calc: ERROR: oxygen delivery high flow is unknown!"))
		else
			call echo(concat("HFNP Calc: ERROR: invalid oxygen delivery high flow of ", \
				trim(icu_stay->qual[m]->iview_col[n]->odhf_method) ,"."))
		endcase
	endif
	call decho(concat("Finishing process_odnp(", trim(cnvtstring(m)), ",", trim(cnvtstring(n)), ")."))
   return(null)
end; process_odnp
;**********************************************************************************************
; Subroutine - selectively write debug messages to msglog
;**********************************************************************************************
subroutine decho(m)
   if (1 = debug)
      execute oencpm_msglog(m)
   endif
   return(null)
end; decho
#exit_script
free record enc
free record icu_stay
end
go
;**********************************************************************************************
;END OF CCL PROGRAM FILE
;**********************************************************************************************
/*
select p.person_id, e.encntr_id, e.reg_dt_tm
from encounter e, person p, encntr_loc_hist elh
plan e
where e.active_ind = 1
and (e.disch_dt_tm > cnvtdatetime(cnvtdate2("01-May-2023", "DD-MMM-YYYY"), 0) or e.disch_dt_tm = null)
and e.reg_dt_tm < cnvtdatetime(cnvtdate2("31-May-2023", "DD-MMM-YYYY"), 235959)
and e.encntr_class_cd = 319456;319456=Inpatient
join p
where e.person_id = p.person_id
and p.active_ind = 1
join elh
where elh.encntr_id 		 					 = e.encntr_id
and elh.transaction_dt_tm 						>= cnvtdatetime(cnvtdate2("01-May-2023","dd-mmm-yyyy"),0)
and elh.transaction_dt_tm 						<= cnvtdatetime(cnvtdate2("31-May-2023","dd-mmm-yyyy"),235959)
and elh.active_ind		  						= 1
and elh.loc_nurse_unit_cd						in (86164365, 151468447, 86170172, 116659567)
order by e.encntr_id
with time=30, format(date, ";;Q")
select ce.event_end_dt_tm, ce.performed_dt_tm, ce.result_val, *
from clinical_event ce
where ce.person_id = 14199950
and ce.event_cd in (151978783, 703960, 86176074, 91045271)
order by ce.event_end_dt_tm
with maxrec=100, time=10, format(date, ";;Q")
*/