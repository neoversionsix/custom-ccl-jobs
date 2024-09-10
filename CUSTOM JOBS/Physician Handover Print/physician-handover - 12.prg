/*
CUSTOM PRINT LAYOUT FOR THE Medical Worklist.

Cherwell: 793507
Programmer: Jason Whittle
Date: May 2024

Updating Patient Summary to extract Based on Care Teams Med Service
 */


drop program wh_physician_handover go
create program wh_physician_handover


; The two prompts below are recieved by the program ans stored in the two variables
; in the with section of the program
prompt
	"Output to File/Printer/MINE" = "MINE" ,
	"JSON Request:" = "" ; jsondata is passed to this program from powerchart


with
	  outdev
	, jsondata ; jsondata is passed to this program from powerchart

;Declare Constants
	declare 319_URN_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",319,"URN")),protect
	;319 is the code set for URN on the CODE_VALUE table "URN" is the DISPLAY_KEY for urn
	declare 4003147_ILLNESSSEVERITY_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"ILLNESSSEVERITY")),protect
	declare 200_CODESTATUS_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",200,"CODESTATUS")),protect
	declare 4003147_COMMENT_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"COMMENT")),protect
	declare 4003147_PATIENTSUMMARY_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"PATIENTSUMMARY")),protect
	declare 4003147_ACTION_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"ACTION")),protect
	declare 6027_IPASSACTION_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",6027,"IPASSACTION")),protect
	declare 79_PENDING_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",79,"PENDING")),protect
	declare 12025_CANCELED_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",12025,"CANCELED")),protect
	declare 333_ADMITTINGDOCTOR_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",333,"ADMITTINGDOCTOR")),protect
	declare MPAGE_COMMENT_CD_VAR = f8 with constant(78917771.00),protect
	declare DIAGNOSIS_TYPE_PRINCIPAL_CD_VAR = f8 with constant(3538766.00),protect
	declare DIAGNOSIS_TYPE_ADDITIONAL_CD_VAR = f8 with constant(3538765.00),protect
	declare HAEMOGLOBIN_CD_VAR = f8 with constant(4054760.00),protect
	declare WHITE_CELL_COUNT_CD_VAR = f8 with constant(4054950.00),protect
	declare PLATELET_COUNT_CD_VAR = f8 with constant(4054852.00),protect
	declare C_R_PROTEIN_CD_VAR = f8 with constant(4055520.00),protect
	declare CREATININE_CD_VAR = f8 with constant(2700655.00),protect
	declare ACTIVE_12025_CD_VAR = f8 with constant(3299.00),protect
	declare VERSION_VAR = vc with constant("v12.4"),protect


;Declare Variables
	declare idx = i4 with noconstant(0),protect
	declare patienthtml = vc with noconstant(" "),protect
	declare patienthtmlsimplified = vc with noconstant(""),protect
	declare finalhtml = vc with noconstant(" "),protect
	declare finalhtmlsimplified = vc with noconstant(" "),protect
	declare newsize = i4 with noconstant(0),protect
	declare printuser_name = vc with noconstant(" "),protect
	declare displayed_list_name = vc with noconstant(" "),protect
	declare total_number_of_encounters = i4 with noconstant(0),protect
	declare patient_summary_and_author_var = vc with noconstant(""),protect


;Declare Records
	record data (
	;1 cnt							= i4
	1 list[*]
		2 PERSON_ID					= f8
		2 ENCNTR_ID					= f8
		2 CARE_TEAM_ID				= f8
		2 unit_disp					= vc
		2 room_disp					= vc
		2 bed_disp					= vc
		2 admit_dt_tm_disp			= vc
		2 clinical_unit				= vc
		2 patient_name				= vc
		2 age						= vc
		2 DOB						= vc
		2 gender					= vc
		2 urn						= vc
		2 illness_severity			= vc
		2 admittingdoctor			= vc
		2 haemoglobins_cnt			= i4
		2 haemoglobins[*]
		3 haemoglobin				= vc
		2 haemoglobindatedsps_cnt	= i4
		2 haemoglobindatedsps[*]
		3 haemoglobindatedsp		= vc
		2 whiteccs_cnt				= i4
		2 whiteccs[*]
		3 whitecc					= vc
		2 whiteccdatedsps_cnt		= i4
		2 whiteccdatedsps[*]
		3 whiteccdatedsp			= vc
		2 plates_cnt				= i4
		2 plates[*]
		3 plate						= vc
		2 platedatedsps_cnt			= i4
		2 platedatedsps[*]
		3 platedatedsp				= vc
		2 crproteins_cnt			= i4
		2 crproteins[*]
		3 crprotein					= vc
		2 crproteindatedsps_cnt		= i4
		2 crproteindatedsps[*]
		3 crproteindatedsp			= vc
		2 creatinines_cnt			= i4
		2 creatinines[*]
		3 creatinine				= vc
		2 creatininedatedsps_cnt	= i4
		2 creatininedatedsps[*]
		3 creatininedatedsp			= vc
		2 diagnosisps_cnt			= i4
		2 diagnosisps[*]
		3 diagnosisp				= vc
		2 diagnosisas_cnt			= i4
		2 diagnosisas[*]
		3 diagnosisa				= vc
		2 mcomments_cnt				= i4
		2 mcomments[*]
		3 mcomment					= vc
		2 code_status				= vc
		2 patient_summary			= vc
		; 2 patient_summary_author	= vc
		2 sit_aware_cnt				= i4
		2 sit_aware[*]
		3 comment					= vc
		2 actions_cnt				= i4
		2 actions[*]
		3 action					= vc
		2 allergy_cnt				= i4
		2 allergies[*]
		3 allergy					= vc
		2 pct_ms					= vc
		2 pct_t						= vc

	) with protect


	record html_log (
	1 list[*]
		2 start				= i4
		2 stop				= i4
		2 patient_text		= vc
	) with protect

;Set printuser_name
	select into "nl:"
	from
		prsnl p
	plan p
		where p.PERSON_ID = reqinfo->updt_id

	detail
		printuser_name = trim(p.name_full_formatted, 3)

	with nocounter
	, maxcol=100000

;Add json patients to data record called print_options as inherited by PChart
	set stat = cnvtjsontorec($jsondata,0,0,0,0)
;Set Powerchart list_name based on json data ingested
	SET displayed_list_name = trim(print_options->list_name[1], 3)
;Get the total number of encounters passed over from powerchart
	SET total_number_of_encounters = SIZE(print_options->qual,5)

; Copy Information from JSON Record structure to data record structure
	SET stat = alterlist(data->list,total_number_of_encounters) ; Allocate Memory
	FOR (x=1 to total_number_of_encounters)
		SET data->list[x].ENCNTR_ID = print_options->qual[x].ENCNTR_ID
		SET data->list[x].PERSON_ID = print_options->qual[x].PERSON_ID
		SET data->list[x].age = trim(print_options->qual[x].pat_age,3)
		SET data->list[x].CARE_TEAM_ID = print_options->qual[x].CARE_TEAM_ID
	ENDFOR

;Get patient name gender
	select into "nl:"
	from
		person p
	plan p
		where expand(idx,1,total_number_of_encounters,p.PERSON_ID,data->list[idx].PERSON_ID)


	head p.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,p.PERSON_ID,data->list[idx].PERSON_ID)
		if(pos > 0)
			data->list[pos].patient_name = trim(p.name_full_formatted,3)
			data->list[pos].gender = trim(uar_get_code_display(p.sex_cd),3)
			data->list[pos].DOB = DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY") ; Date of Birth
		endif

	 foot p.PERSON_ID
		 null

	with expand = 2
	, maxcol=100000

;Get encounter data
	select into "nl:"
	from
		encounter e
	plan e
		where expand(idx,1,total_number_of_encounters,e.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and e.active_ind = 1

	head e.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,e.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].unit_disp = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
			data->list[pos].room_disp = trim(uar_get_code_display(e.loc_room_cd),3)
			data->list[pos].bed_disp = trim(uar_get_code_display(e.loc_bed_cd),3)
			data->list[pos].admit_dt_tm_disp = format(e.reg_dt_tm,"dd mmm yyyy;;q")
			data->list[pos].clinical_unit = uar_get_code_display(e.med_service_cd)
		endif

	foot e.ENCNTR_ID
		null

	with expand = 2
	, maxcol=100000

;GET MPAGE COMMENTS
	select into "nl:"
	from
		sticky_note s
	plan s
			where
				expand(idx,1,total_number_of_encounters,s.parent_entity_id,data->list[idx].ENCNTR_ID)
				and
				s.sticky_note_type_cd = MPAGE_COMMENT_CD_VAR ; MPages Comment
	order by
		s.parent_entity_id, s.BEG_EFFECTIVE_DT_TM

	head s.parent_entity_id
		pos = locateval(idx,1,total_number_of_encounters,s.parent_entity_id,data->list[idx].ENCNTR_ID)
		cnt = 0
	detail
		if(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->mcomments, cnt)
			data->list[pos]->mcomments[cnt].mcomment = S.STICKY_NOTE_TEXT
		endif
	foot s.parent_entity_id
		if(pos > 0)
			data->list[pos].mcomments_cnt = cnt
		endif
	with expand = 2
	, maxcol=100000



;Get URN
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where expand(idx,1,total_number_of_encounters,ea.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and ea.active_ind = 1
		and ea.beg_effective_dt_tm <= sysdate
		and ea.end_effective_dt_tm >= sysdate
		and ea.encntr_alias_type_cd = 319_URN_CD
	head ea.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,ea.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].urn = trim(cnvtalias(ea.alias, ea.alias_pool_cd),3)
		endif
	foot ea.ENCNTR_ID
		null
	with expand = 2
	, maxcol=100000


;GET ADMITTING DR
	SELECT INTO "nl:"
	FROM
		ENCNTR_PRSNL_RELTN   EPR
		, PRSNL PR
	PLAN
		EPR
			WHERE
				expand(idx,1,total_number_of_encounters,EPR.ENCNTR_ID,data->list[idx].ENCNTR_ID)
				AND
				EPR.ENCNTR_PRSNL_R_CD = 333_ADMITTINGDOCTOR_CD ; this code filters for addmitting dr
	JOIN
		PR;PRSNL
		 WHERE PR.PERSON_ID = EPR.PRSNL_PERSON_ID
	head EPR.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,EPR.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].admittingdoctor = trim(PR.NAME_FULL_FORMATTED,3)
		endif
	foot EPR.ENCNTR_ID
		null

;Get Principal Diagnosis
	SELECT INTO "nl:"
	FROM
		DIAGNOSIS D
	PLAN
		D
			WHERE
				expand(idx,1,total_number_of_encounters,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
				AND
				D.ACTIVE_IND = 1
				AND
				D.DIAG_TYPE_CD = DIAGNOSIS_TYPE_PRINCIPAL_CD_VAR
				AND
				D.END_EFFECTIVE_DT_TM > SYSDATE
				AND
				D.BEG_EFFECTIVE_DT_TM < SYSDATE
	ORDER BY D.ENCNTR_ID, D.BEG_EFFECTIVE_DT_TM
	head D.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0
	detail
		if(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->diagnosisps, cnt)
			data->list[pos]->diagnosisps[cnt].diagnosisp = D.DIAGNOSIS_DISPLAY
		endif

	foot D.ENCNTR_ID
		if(pos > 0)
			data->list[pos].diagnosisps_cnt = cnt
		endif
	with expand = 2
	, maxcol=100000


;Get Additional Diagnosis'
	SELECT INTO "nl:"
	FROM
		DIAGNOSIS D
	PLAN
		D
			WHERE
				expand(idx,1,total_number_of_encounters,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
				AND
				D.ACTIVE_IND = 1
				AND
				D.DIAG_TYPE_CD = DIAGNOSIS_TYPE_ADDITIONAL_CD_VAR
				AND
				D.END_EFFECTIVE_DT_TM > SYSDATE
				AND
				D.BEG_EFFECTIVE_DT_TM < SYSDATE
	ORDER BY D.ENCNTR_ID, D.BEG_EFFECTIVE_DT_TM
	head D.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0
	detail
		if(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->diagnosisas, cnt)
			data->list[pos]->diagnosisas[cnt].diagnosisa = D.DIAGNOSIS_DISPLAY
		endif
	foot D.ENCNTR_ID
		if(pos > 0)
			data->list[pos].diagnosisas_cnt = cnt
		endif
	with expand = 2
	, maxcol=100000



;Get blood results
	; Haemoglobin Level (Blood) (4054760)
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN
		CE
			WHERE
				expand(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID);AND CE.PERSON_ID = xxxxxx
				AND CE.EVENT_CD = HAEMOGLOBIN_CD_VAR
				AND CE.VALID_UNTIL_DT_TM > SYSDATE
				AND CE.EVENT_END_DT_TM > CNVTLOOKBEHIND("200, D")
				AND CE.VIEW_LEVEL = 1
	ORDER BY CE.PERSON_ID, CE.EVENT_END_DT_TM DESC
	HEAD CE.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0
	DETAIL CE.PERSON_ID
		if(pos > 0 and cnt < 3) ; cnt < 3 only saves the first 3 results
			cnt += 1
			stat = alterlist(data->list[pos]->haemoglobins, cnt)
			data->list[pos]->haemoglobins[cnt].haemoglobin = trim(CE.RESULT_VAL,3)
			stat = alterlist(data->list[pos]->haemoglobindatedsps, cnt)
			data->list[pos]->haemoglobindatedsps[cnt].haemoglobindatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
		endif
	FOOT CE.PERSON_ID
		if(pos > 0)
			data->list[pos].haemoglobins_cnt = cnt
			data->list[pos].haemoglobindatedsps_cnt = cnt
		endif
	WITH
		expand = 2
		, maxcol=100000

	;White Cell Count (Blood) (4054950) (whitecc) (whiteccdatedsp)
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN
		CE
			WHERE
				expand(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID);AND CE.PERSON_ID = xxxxxx
				AND CE.EVENT_CD = WHITE_CELL_COUNT_CD_VAR
				AND CE.VALID_UNTIL_DT_TM > SYSDATE
				AND CE.EVENT_END_DT_TM > CNVTLOOKBEHIND("200, D")
				AND CE.VIEW_LEVEL = 1
	ORDER BY CE.PERSON_ID, CE.EVENT_END_DT_TM DESC
	HEAD CE.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0
	DETAIL CE.PERSON_ID
		if(pos > 0 and cnt < 3) ; cnt < 3 only saves the first 3 results

			cnt += 1
			stat = alterlist(data->list[pos]->whiteccs, cnt)
			data->list[pos]->whiteccs[cnt].whitecc = trim(CE.RESULT_VAL,3)
			stat = alterlist(data->list[pos]->whiteccdatedsps, cnt)
			data->list[pos]->whiteccdatedsps[cnt].whiteccdatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
		endif
	FOOT CE.PERSON_ID
		if(pos > 0)
			data->list[pos].whiteccs_cnt = cnt
			data->list[pos].whiteccdatedsps_cnt = cnt
		endif
	WITH
		expand = 2
		, maxcol=100000


	;Platelet Count (Blood) (4054852)
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN
		CE
			WHERE
				expand(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID);AND CE.PERSON_ID = xxxxxx
				AND CE.EVENT_CD = PLATELET_COUNT_CD_VAR
				AND CE.VALID_UNTIL_DT_TM > SYSDATE
				AND CE.EVENT_END_DT_TM > CNVTLOOKBEHIND("200, D")
				AND CE.VIEW_LEVEL = 1
	ORDER BY		CE.PERSON_ID		, CE.EVENT_END_DT_TM DESC
	HEAD CE.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0

	DETAIL CE.PERSON_ID
		if(pos > 0 and cnt < 3) ; cnt < 3 only saves the first 3 results
			;data->list[pos].plate = trim(CE.RESULT_VAL,3)
			;data->list[pos].platedatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
			cnt += 1
			stat = alterlist(data->list[pos]->plates, cnt)
			data->list[pos]->plates[cnt].plate = trim(CE.RESULT_VAL,3)
			stat = alterlist(data->list[pos]->platedatedsps, cnt)
			data->list[pos]->platedatedsps[cnt].platedatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
		endif
	FOOT CE.PERSON_ID
		if(pos > 0)
			data->list[pos].plates_cnt = cnt
			data->list[pos].platedatedsps_cnt = cnt
		endif

	WITH
		expand = 2
		, maxcol=100000

	;C-Reactive Protein (4055520)
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN
		CE
			WHERE
				expand(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID);AND CE.PERSON_ID = xxxxxx
				AND CE.EVENT_CD = C_R_PROTEIN_CD_VAR
				AND CE.VALID_UNTIL_DT_TM > SYSDATE
				AND CE.EVENT_END_DT_TM > CNVTLOOKBEHIND("200, D")
				AND CE.VIEW_LEVEL = 1
	ORDER BY
		CE.PERSON_ID
		, CE.EVENT_END_DT_TM DESC
	HEAD CE.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0
	DETAIL CE.PERSON_ID
		if(pos > 0 and cnt < 3) ; cnt < 3 only saves the first 3 results
			;data->list[pos].crprotein = trim(CE.RESULT_VAL,3)
			;data->list[pos].crproteindatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
			cnt += 1
			stat = alterlist(data->list[pos]->crproteins, cnt)
			data->list[pos]->crproteins[cnt].crprotein = trim(CE.RESULT_VAL,3)
			stat = alterlist(data->list[pos]->crproteindatedsps, cnt)
			data->list[pos]->crproteindatedsps[cnt].crproteindatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
		endif
	FOOT CE.PERSON_ID
		if(pos > 0)
			data->list[pos].crproteins_cnt = cnt
			data->list[pos].crproteindatedsps_cnt = cnt
		endif
	WITH
		expand = 2
		, maxcol=100000


	;Creatinine Level (Serum/Plasma) (2700655) (creatinine)
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN
		CE
			WHERE
				expand(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID);AND CE.PERSON_ID = xxxxxx
				AND CE.EVENT_CD = CREATININE_CD_VAR
				AND CE.VALID_UNTIL_DT_TM > SYSDATE
				AND CE.EVENT_END_DT_TM > CNVTLOOKBEHIND("200, D")
				AND CE.VIEW_LEVEL = 1
	ORDER BY
		CE.PERSON_ID
		, CE.EVENT_END_DT_TM DESC
	HEAD CE.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,CE.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0
	DETAIL CE.PERSON_ID
		if(pos > 0 and cnt < 3) ; cnt < 3 only saves the first 3 results
			;data->list[pos].creatinine = trim(CE.RESULT_VAL,3)
			;data->list[pos].creatininedatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
			cnt += 1
			stat = alterlist(data->list[pos]->creatinines, cnt)
			data->list[pos]->creatinines[cnt].creatinine = trim(CE.RESULT_VAL,3)
			stat = alterlist(data->list[pos]->creatininedatedsps, cnt)
			data->list[pos]->creatininedatedsps[cnt].creatininedatedsp = FORMAT(CE.EVENT_END_DT_TM, "DD/MM/YY hh:mm;;d")
		endif
	FOOT CE.PERSON_ID
		if(pos > 0)
			data->list[pos].creatinines_cnt = cnt
			data->list[pos].creatininedatedsps_cnt = cnt
		endif
	WITH
		expand = 2
		, maxcol=100000


;Get Illness Severity
	select into "nl:"
	from
		pct_ipass pi
		,code_value cv
	plan pi
		where expand(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and pi.active_ind = 1
		and pi.end_effective_dt_tm >= sysdate
		and pi.ipass_data_type_cd = 4003147_ILLNESSSEVERITY_CD
	join cv
		where cv.code_value = pi.parent_entity_id
		and cv.active_ind = 1
	order by pi.ENCNTR_ID
	head pi.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].illness_severity = trim(cv.display,3)
		endif
	foot pi.ENCNTR_ID
		null
	with expand = 2
	, maxcol=100000


;Get Code Status
	select into "nl:"
	from
		orders o
		,order_detail od
	plan o
		where expand(idx,1,total_number_of_encounters,o.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and o.catalog_cd = 200_CODESTATUS_CD
	join od
		where od.order_id = o.order_id
		and od.oe_field_id = 1040321.00		;Code Status
	order by o.ENCNTR_ID, o.order_id, od.oe_field_id, od.action_sequence desc
	head o.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,o.ENCNTR_ID,data->list[idx].ENCNTR_ID)
	head o.order_id
		null
	head od.oe_field_id
		if(pos > 0)
			data->list[pos].code_status = trim(od.oe_field_display_value,3)
		endif
	foot od.oe_field_id
		null
	foot o.order_id
		null
	foot o.ENCNTR_ID
		null
	with expand = 2
	, maxcol=100000


;Get Patient Summary
	select into "nl:"
		result = evaluate
		(
			 sn.long_text_id
			, 0
			, REPLACE(TRIM(sn.sticky_note_text, 3), char(10), "<BR>", 0)
			, REPLACE(TRIM(lt.long_text, 3), char(10), "<BR>", 0)
		)
	from
		  pct_ipass pi
		, sticky_note sn
		, long_text lt
		, prsnl pr
	plan pi
		where expand(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and pi.active_ind = 1
		and pi.end_effective_dt_tm >= sysdate
		and pi.ipass_data_type_cd =	4003147_PATIENTSUMMARY_CD
	join sn
		where sn.sticky_note_id = pi.parent_entity_id
		and sn.beg_effective_dt_tm <= sysdate
		and sn.end_effective_dt_tm >= sysdate
	join lt
		where lt.long_text_id = outerjoin(sn.long_text_id)
		and lt.active_ind = outerjoin(1)
	join pr
		where pr.person_id = outerjoin(pi.updt_id)
		and pr.active_ind = outerjoin(1)
		and pr.END_EFFECTIVE_DT_TM > outerjoin(sysdate)
		and pr.BEG_EFFECTIVE_DT_TM < outerjoin(sysdate)
	order by pi.ENCNTR_ID, pi.ipass_data_type_cd, pi.begin_effective_dt_tm desc
	head pi.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0
		if(pos > 0)
			patient_summary_and_author_var = result
			;data->list[pos].patient_summary = result
		endif

		if (pos > 0 and pr.person_id > 0)
			patient_summary_and_author_var = build2(patient_summary_and_author_var
				,"<BR>"
				,"["
				, trim(pr.name_full_formatted,3)
				,"]"
			)
			;data->list[pos].patient_summary_author = trim(pr.name_full_formatted,3)
		else
			patient_summary_and_author_var = build2(patient_summary_and_author_var
				,"<BR>[No author for summary found]"
			)
		endif

		if(pos > 0)
			data->list[pos].patient_summary = patient_summary_and_author_var
		endif
	foot pi.ENCNTR_ID
		patient_summary_and_author_var = ""
	with expand = 2, maxcol=100000

;Get Situation Awareness & Planning
	select into "nl:"
		result = evaluate
		(
			 sn.long_text_id
			, 0
			, REPLACE(TRIM(sn.sticky_note_text, 3), char(10), "<BR>", 0)
			, REPLACE(TRIM(lt.long_text, 3), char(10), "<BR>", 0)
		)
	from
		  pct_ipass pi
		, sticky_note sn
		, long_text lt
		, prsnl pr
	plan pi
		where expand(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and pi.active_ind = 1
		and pi.end_effective_dt_tm >= sysdate
		and pi.ipass_data_type_cd = 4003147_COMMENT_CD
	join sn
		where sn.sticky_note_id = pi.parent_entity_id
		and sn.beg_effective_dt_tm <= sysdate
		and sn.end_effective_dt_tm >= sysdate
	join lt
		where lt.long_text_id = outerjoin(sn.long_text_id)
		and lt.active_ind = outerjoin(1)
	join pr
		where pr.person_id = outerjoin(pi.updt_id)
		and pr.active_ind = outerjoin(1)
		and pr.END_EFFECTIVE_DT_TM > outerjoin(sysdate)
		and pr.BEG_EFFECTIVE_DT_TM < outerjoin(sysdate)
	order by pi.ENCNTR_ID, pi.ipass_data_type_cd, pi.begin_effective_dt_tm desc
	head pi.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0
	detail
		if(pos > 0 and pi.ipass_data_type_cd = 4003147_COMMENT_CD)
			cnt += 1
			stat = alterlist(data->list[pos]->sit_aware, cnt)
			data->list[pos]->sit_aware[cnt].comment = result
		endif
	foot pi.ENCNTR_ID
		if(pos > 0)
			data->list[pos].sit_aware_cnt = cnt
		endif
	with expand = 2	, maxcol=100000


;Get Actions
	select into "nl:"
	from
		pct_ipass pi
		,task_activity ta
		,long_text lt
	plan pi
		where expand(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		and pi.active_ind = 1
		and pi.end_effective_dt_tm >= sysdate
		and pi.ipass_data_type_cd = 4003147_ACTION_CD
	join ta
		where ta.task_id = pi.parent_entity_id
		and ta.task_activity_cd = 6027_IPASSACTION_CD
		and ta.task_status_cd = 79_PENDING_CD
	join lt
		where lt.long_text_id = ta.msg_text_id
		and lt.parent_entity_name = "TASK_ACTIVITY"
		and lt.long_text != null
	order by pi.ENCNTR_ID, pi.begin_effective_dt_tm desc

	head pi.ENCNTR_ID
		pos = locateval(idx,1,total_number_of_encounters,pi.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0

	detail
		if(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->actions, cnt)
			data->list[pos]->actions[cnt].action = trim(lt.long_text,3)
		endif

	foot pi.ENCNTR_ID
		if(pos > 0)
			data->list[pos].actions_cnt = cnt
		endif
	with expand = 2
	, maxcol=100000


;Get Allergies
	select into "nl:"
		result = evaluate(a.substance_nom_id,0,trim(a.substance_ftdesc,3),trim(n.source_string,3))
	from
		allergy a
		,nomenclature n
	plan a
		where
		expand(idx,1,total_number_of_encounters,a.PERSON_ID,data->list[idx].PERSON_ID)
		and a.active_ind = 1
		and a.beg_effective_dt_tm <= sysdate
		and (a.end_effective_dt_tm >= sysdate
			or a.end_effective_dt_tm = null)
		and a.reaction_status_cd = ACTIVE_12025_CD_VAR ; 'Active' from code set 12025
	join n
		where n.nomenclature_id = outerjoin(a.substance_nom_id)
		and n.active_ind = outerjoin(1)
	order by a.PERSON_ID, result
	head a.PERSON_ID
		pos = locateval(idx,1,total_number_of_encounters,a.PERSON_ID,data->list[idx].PERSON_ID)
		cnt = 0
	detail
		if(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->allergies, cnt)
			data->list[pos]->allergies[cnt].allergy = result
		endif
	foot a.PERSON_ID
		if(pos > 0)
			data->list[pos].allergy_cnt = cnt
		endif
	with expand = 2
	, maxcol=100000

	call echojson(print_options,trim(concat(trim(logical("ccluserdir"),3),"/ph_print_testing.dat"),3))

;Build HTML for each patient
	call alterlist(html_log->list,total_number_of_encounters)
	for(x = 1 to total_number_of_encounters)
		set html_log->list[x].start = textlen(trim(patienthtml,3)) + 1
		set patienthtml = build2(patienthtml
			,"<p class=patient-info-name>",data->list[x].patient_name," ",data->list[x].age," ",data->list[x].gender
			,"</p>"
			,"<div>"
			,'<table style="width:100%">'
			,"<tr>"
			,"<td style='padding: 2px; border: none; font-weight: bold; white-space: nowrap;'>Clinical Unit: </td>"
			,"<td style='padding: 2px; border: 1px solid #dddddd; width: 100%; white-space: nowrap;'>"
			, data->list[x].clinical_unit
			,"</td>"
			,"</tr>"
			,"</table>"
			,'<table style="width:100%">'
			,"<tr>"
			,"<td class=patient-data-header>Location</td>"
			,"<td class=patient-data-header>URN</td>"
			,"<td class=patient-data-header>D.O.B</td>"
			,"<td class=patient-data-header>Allergies</td>"
			,"<td class=patient-data-header>Admitting Dr</td>"
			,"<td class=patient-data-header>Admit Date</td>"
			,"</tr>"
			,"<tr>"
			,"<td class=patient-info>"
			, data->list[x].unit_disp,",&nbsp;"
			, data->list[x].room_disp,",&nbsp;"
			, data->list[x].bed_disp
			,"</td>"
			,"<td class=patient-info>", data->list[x].urn, "</td>"
			,"<td class=patient-info>", data->list[x].DOB, "</td>"
			,"<td class=patient-info>"
		)
		; Allergies
			for(y = 1 to data->list[x].allergy_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->allergies[y].allergy,",&nbsp;")
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"<td class=patient-info>",data->list[x].admittingdoctor,"</td>"
			,"</td>"
			,"<td class=patient-info>",data->list[x].admit_dt_tm_disp,"</td>"
			, "</tr>"
			,"</table>"
			,"</div>"
		)
		; PATIENT SUMMARY TABLE
		set patienthtml = build2(patienthtml
			,"<div>"
			,'<table style="width:100%">'
			,"<tr>"
				,"<td class=patient-data-header-twofive>","Illness Severity","</td>"
				,"<td class=patient-info-wide>"
					, data->list[x].illness_severity
				,"</td>"
			,"</tr>"
		)
		; Diagnosis
		set patienthtml = build2(patienthtml
			,"<tr>"
			,"<td class=patient-data-header-twofive>","Diagnoses","</td>"
			,"<td class=patient-info-wide> PRINCIPALS:&nbsp"
		)
			for(y = 1 to data->list[x].diagnosisps_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->diagnosisps[y].diagnosisp,",&nbsp"
				)
			endfor
		set patienthtml = build2(patienthtml
			, "<br>ADDITIONALS:&nbsp"
		)
		; additional diagnosis'
			for(y = 1 to data->list[x].diagnosisas_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->diagnosisas[y].diagnosisa,",&nbsp"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"</tr>"
			,"<tr>"
			,"<td class=patient-data-header-twofive>","Patient Summary","</td>"
			,"<td class=patient-info-wide>"
				, data->list[x].patient_summary
			,"</td>"
			,"</tr>"
			,"<tr>"
			,"<td class=patient-data-header-twofive>","Situational Awareness<br>& Planning","</td>"
			,"<td class=patient-info-wide>"
		)
			for(y = 1 to data->list[x].sit_aware_cnt)
				set patienthtml = build2(patienthtml
					,"- &nbsp;",data->list[x]->sit_aware[y].comment,"<br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"</tr>"
			,"<tr>"
			,"<td class=patient-data-header-twofive>","Actions","</td>"
			,"<td class=patient-info-wide>"
		)
			for(y = 1 to data->list[x].actions_cnt)
				set patienthtml = build2(patienthtml
					; Checkbox, splace, followed by action and line break
					,"&#9744;", "&nbsp;", data->list[x]->actions[y].action, "<br>")
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"</tr>"
		)
		set patienthtml = build2(patienthtml
			,"</table>"
			,"</div>"
		)
		; BLOODS
		set patienthtml = build2(patienthtml
			,'<table style="width:100%">'
			,"<tr>"
			,"<td class=patient-data-header>Hb (Blood)</td>"
			,"<td class=patient-data-header>WCC (Blood)</td>"
			,"<td class=patient-data-header>Plts (Blood)</td>"
			,"<td class=patient-data-header>CRP</td>"
			,"<td class=patient-data-header>Cr (Serum/Plasma)</td>"
			,"</tr>"
			,"<tr>"
			,"<td class=patient-info>"
		)
		;Pathology Results haemoglobin
			for(y = 1 to data->list[x].haemoglobins_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->haemoglobindatedsps[y].haemoglobindatedsp
					,"&nbsp; ("
					,data->list[x]->haemoglobins[y].haemoglobin
					,") <br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"<td class=patient-info>"
		)
		;Pathology Results whitecc
			for(y = 1 to data->list[x].whiteccs_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->whiteccdatedsps[y].whiteccdatedsp
					,"&nbsp; ("
					,data->list[x]->whiteccs[y].whitecc
					,") <br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"<td class=patient-info>"
		)
		;Pathology Results plate
			for(y = 1 to data->list[x].plates_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->platedatedsps[y].platedatedsp
					,"&nbsp; ("
					,data->list[x]->plates[y].plate
					,") <br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"<td class=patient-info>"
		)
		;Pathology Results crprotein
			for(y = 1 to data->list[x].crproteins_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->crproteindatedsps[y].crproteindatedsp
					,"&nbsp; ("
					,data->list[x]->crproteins[y].crprotein
					,") <br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			,"<td class=patient-info>"
		)
		;Pathology Results creatinine
			for(y = 1 to data->list[x].creatinines_cnt)
				set patienthtml = build2(patienthtml
					,data->list[x]->creatininedatedsps[y].creatininedatedsp
					,"&nbsp; ("
					,data->list[x]->creatinines[y].creatinine
					,") <br>"
				)
			endfor
		set patienthtml = build2(patienthtml
			,"</td>"
			, "</tr>"
			,"</table>"
		)
		; Comments: Section
		set patienthtml = build2(patienthtml
		,"<p>"
		,"Comments:"
		,"</p>"
		,"<div>"
		)
			for(y = 1 to data->list[x].mcomments_cnt)
				set patienthtml = build2(patienthtml
					,"-&nbsp", data->list[x]->mcomments[y].mcomment, "<br>"
				)
			endfor
		set patienthtml = build2(patienthtml
		,"</div>"
		,"<hr class=thick>"
		,"</hr>")
		set html_log->list[x].stop = textlen(trim(patienthtml,3)) + 1
	endfor


	;Add HTML and CSS shell around patienthtml
	set finalhtml = build2(
		"<!DOCTYPE html><html>"
		,"<head>"
		,"<meta charset='utf-8'>"
		,"<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
		,"<title>Mpage Print</title>"
		,"<style type='text/css'>"
		,"hr.thick {height: 5px; border: none; color: #333; background-color: #333;}"
		,"body {font-family: Arial, sans-serif; font-size: 12px;}"
		,"td {vertical-align: top; padding: 2px; text-align: left;}"
		,".border {border: 1px solid #dddddd;}"
		,".print-header {display: flex;}"
		,".print-header div {display: flex; flex: 1 1;}"
		,".print-title {justify-content: center; font-weight: bold; font-size: 24px; color: DarkBlue;}"
		,".printed-date {justify-content: flex-end;}"
		,".column {font-weight: bold; width: 10%;}"
		,".patient-info {width: 10%; border: 1px solid #dddddd;}"
		,".patient-info-wide {border: 1px solid #dddddd;}"
		,".patient-info-name {font-size: 115%; border: 1px solid #dddddd; font-weight: 500; background-color: lightgrey;}"
		,".bld {font-weight: bold;}"
		,".patient-data-header {font-weight: bold;}"
		,".patient-data-header-twofive {width: auto; font-weight: bold;}"
		,".patient-data {width: 19%; border: 1px solid #dddddd;}"
		,".comment-box {height: 30px;}"
		,"</style>"
		,"</head>"
		,"<body>"
		,"<div id='print-container'>"
		,"<div class='print-header'>"
		,"<div class='printed-by-user'>"
		,"<span>Program: ", VERSION_VAR,", Printed By: </span><span>", printuser_name, "</span>"
		,"</div>"
		,"<div class='print-title'><span>Medical Worklist</span></div>"
		,"<div class='printed-date'><span>PRINTED: ", format(sysdate,"dd/mm/yyyy hh:mm;;d"), "</span></div>"
		,"</div>"
		,"</div>"
		,"<h2>LIST NAME: ", displayed_list_name, "</h2>"
		,"<p>Encounters: ", total_number_of_encounters, "</p>"
		,patienthtml
		,'<footer style="margin-top: 20px; font-weight: bold; text-align: center;">'
    		,'If found, please return to the nearest ward clerk'
		,'</footer>'
		,"</body></html>"
	);


	set finalhtmlsimplified = build2(
	'<!DOCTYPE html>'
	,'<html lang="en">'
	,'<head>'
		,'<meta charset="UTF-8">'
		,'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
		,'<title>Medical Worklist</title>'
		,'<style>'
			,'body {'
				,'font-family: Arial, sans-serif;'
				,'margin: 20px;'
			,'}'
			,'table {'
				,'width: 100%;'
				,'border-collapse: collapse;'
				,'margin-top: 20px;'
				, 'font-size: 55%;'
			,'}'
			,'table, th, td {'
				,'border: 1px solid black;'
				,'border-left: none;' /* Remove left border */
				,'border-right: none;' /* Remove right border */
			,'}'
			,'th, td {'
				,'padding: 10px;'
				,'text-align: left;'
			,'}'
			,'th {'
				,'background-color: #f2f2f2;'
			,'}'
			,'table tr {'
				,'border-top: 1px solid black;' /* Add top border to each row */
				,'border-bottom: 1px solid black;' /* Add bottom border to each row */
			,'}'
			,'th.notes, td.notes {'
			, 'width: 50%;'
			, '}'
		,'</style>'
	,'</head>'
	,'<body>'
		,'<p style = "font-size: 65%;">Printed:&nbsp;', format(sysdate,"dd/mm/yyyy hh:mm;;d"), "&nbsp;", printuser_name,'</p>'
		,'<p style = "font-size: 65%;">List:', displayed_list_name ,'</p>'
	,''
		,'<table>'
			,'<tr>'
				,'<th>Location</th>'
				,'<th>Patient</th>'
				,'<th>MRN</th>'
				,'<th>Principal Diagnosis</th>'
				,'<th>Illness Severity</th>'
				,'<th>Admit Date</th>'
				,'<th>Notes</th>'
			,'</tr>'
	)
	for(x = 1 to total_number_of_encounters)
		set patienthtmlsimplified = build2(patienthtmlsimplified
				,'<tr>'
					,'<td>'
						, data->list[x].unit_disp,",&nbsp;"
						, data->list[x].room_disp,",&nbsp;"
						, data->list[x].bed_disp
					,'</td>'
					,'<td>'
						,data->list[x].patient_name
						," "
						,data->list[x].age
						," ",data->list[x].gender
					,'</td>'
					,'<td>'
						, data->list[x].urn
					, '</td>'
					,'<td>'
		)
		for(y = 1 to data->list[x].diagnosisps_cnt)
			set patienthtmlsimplified = build2(patienthtmlsimplified
				,data->list[x]->diagnosisps[y].diagnosisp,",&nbsp"
			)
		endfor
		set patienthtmlsimplified = build2(patienthtmlsimplified
					, '</td>'
					,'<td>',data->list[x].illness_severity,'</td>'
					,'<td>'
					, data->list[x].admit_dt_tm_disp
					, '</td>'
					,'<td class="notes"></td>'
				,'</tr>'
		)
	endfor

	set finalhtmlsimplified = build2( finalhtmlsimplified, patienthtmlsimplified
		,'</table>'
		,'</body>'
		,'<footer style="margin-top: 20px; font-weight: bold; font-size: 30%; text-align: center;">'
			,'Program:', VERSION_VAR,'     If found, please return to the nearest ward clerk'
		,'</footer>'
		,'</html>'
	)
; Print the detailed list if checked on powerchart otherwise print the simplified
	if (cnvtlower(trim(print_options->print_style)) = "detailed")
		set _memory_reply_string = finalhtml
	else
		set _memory_reply_string = finalhtmlsimplified
	endif

end
go