drop program wh_mdm_portal_report go
create program wh_mdm_portal_report

;NOTES
    /* IN DEVELOPMENT
    Program: wh_mdm_portal_report
    Date Created: Mar 2025
    Description: Report for MDM Care Team Meeting, reporpsing
	the mdm report from powerchart for the reporting portal. Just need
	to feed in patients from a query rather than a json from powerchart
    Programmer: Jason Whittle
    */

prompt
    "Output to File/Printer/MINE" = "MINE"

with OUTDEV

;DECLARE CONSTANTS
	declare 319_URN_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",319,"URN")),protect
	;[1] 319 is the code set for URN on the CODE_VALUE table "URN" is the DISPLAY_KEY for urn

;CALL CONSTANTS
    call echo(build2("319_URN_CD: ",319_URN_CD))

;DECLARE VARIABLES
	declare idx = i4 with noconstant(0),protect
	declare patienthtml = vc with noconstant(" "),protect
	declare finalhtml = vc with noconstant(" "),protect
	declare newsize = i4 with noconstant(0),protect
	declare printuser_name = vc with noconstant(" "),protect

;DECLARE RECORDS
	record data (
    1 cnt							= i4
	1 list[*]
		2 PERSON_ID					= F8
		2 ENCNTR_ID					= F8
		2 PATIENT_NAME				= VC
		2 URN						= VC
		2 DOB						= VC
		2 AGE						= VC
		2 GENDER					= VC
		2 CLINICAL_NOTES			= VC
		2 MEDSERVICES_CNT			= I4
		2 MEDSERVICES[*]
		3 MEDSERVICE				= VC
		2 MEDTEAMS_CNT				= I4
		2 MEDTEAMS[*]
		3 MEDTEAM					= VC
		2 CONSULTANT_NAME			= VC
		2 CLINICAL_NOTES			= VC
		2 IMAGING					= VC
		2 PATHOLOGY					= VC
		2 MDM_QUESTION				= VC
		2 MDM_DATE					= VC
		2 OP_DISCUSSION				= VC
		2 APPOINMENT				= VC
		2 SCOPES					= VC
		2 BLOODS					= VC
		2 MEETING					= VC
    ) with protect

;HTML LOG
    record html_log (
	1 list[*]
		2 start				= i4
		2 stop				= i4
		2 patient_text		= vc
	) with protect

;SET PRINTUSER_NAME
	select into "nl:"
	from
		prsnl p
	plan p
		where p.PERSON_ID = reqinfo->updt_id
	detail
		printuser_name = trim(p.name_full_formatted, 3)
	with nocounter

;ENCOUNTER AND PERSON_IDS ADD MDM PATIENTS TO DATA RECORD
	SELECT INTO "nl:"
	FROM
		DCP_SHIFT_ASSIGNMENT   D
		, PCT_CARE_TEAM   P

	PLAN D
		WHERE
			D.END_EFFECTIVE_DT_TM > SYSDATE
			AND D.BEG_EFFECTIVE_DT_TM < SYSDATE
			AND D.ACTIVE_IND = 1

	JOIN P
		WHERE
			P.PCT_CARE_TEAM_ID = D.PCT_CARE_TEAM_ID
			; mdm care teams to filter
			AND P.PCT_TEAM_CD IN(
				152261055.00
				,152261131.00
				,152261133.00
				,152261135.00
				,152261137.00
				,152261139.00
				,152261141.00
				,152261143.00
				,152261145.00
			)

	head report
		cnt = 0

	head D.ENCNTR_ID
		cnt += 1
		if(mod(cnt, 20) = 1)
			stat = alterlist(data->list,cnt + 19)
		endif
		data->list[cnt].ENCNTR_ID = D.ENCNTR_ID
		data->list[cnt].PERSON_ID = D.PERSON_ID
	foot D.ENCNTR_ID
		null
	foot report
		data->cnt = cnt
		stat = alterlist(data->list,cnt)
	with nocounter


;URN NAME AGE GENDER DOB
	SELECT INTO "nl:"
	FROM
		PERSON   P
		, PERSON_ALIAS PA
		, ENCOUNTER E
		;, (LEFT JOIN PERSON_ALIAS PA ON (P.PERSON_ID = PA.PERSON_ID))
		;, (LEFT JOIN ENCOUNTER E ON (E.PERSON_ID = P.PERSON_ID))
	PLAN P
		WHERE
			EXPAND(idx,1,data->cnt,P.PERSON_ID,data->list[idx].PERSON_ID)
	JOIN PA
		WHERE ;EXPAND(idx,1,data->cnt,P.PERSON_ID,data->list[idx].PERSON_ID)
			PA.PERSON_ID = P.PERSON_ID
			AND
			PA.ALIAS_POOL_CD = 9569589.00 ;319_URN_CD ; 9569589.00 ; this filters for the UR Number
			AND
			PA.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
			AND
			P.ACTIVE_IND = 1 ; DONT PULL IF THE PERSON IS INACTIVE IN THE DB
	JOIN E
		WHERE
			E.PERSON_ID = P.PERSON_ID
			AND
			E.ACTIVE_IND = 1
	HEAD E.ENCNTR_ID
	pos = locateval(idx,1,data->cnt,E.ENCNTR_ID,data->list[idx].ENCNTR_ID)
	if(pos > 0)
		data->list[pos].URN = TRIM(PA.ALIAS, 3)
		data->list[pos].PATIENT_NAME = TRIM(P.NAME_FULL_FORMATTED,3)
		data->list[pos].GENDER = TRIM(UAR_GET_CODE_DISPLAY(P.SEX_CD),3)
		data->list[pos].DOB = DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY")
		data->list[pos].AGE = TRIM(CNVTAGE(P.BIRTH_DT_TM))
		data->list[pos].DOB = DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY")
	endif
	FOOT E.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET TEAM DATA
	SELECT INTO "nl:"
	FROM
	DCP_SHIFT_ASSIGNMENT   D
	, (LEFT JOIN PCT_CARE_TEAM P ON (P.PCT_CARE_TEAM_ID = D.PCT_CARE_TEAM_ID))
	PLAN D
		WHERE
			EXPAND(idx,1,data->cnt,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND
			D.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(CURDATE, CURTIME3)
			AND
			D.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
	JOIN P
	ORDER BY
		D.BEG_EFFECTIVE_DT_TM
	HEAD D.ENCNTR_ID
		pos = LOCATEVAL(idx,1,data->cnt,D.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		cnt = 0
	DETAIL
		IF(pos > 0)
			cnt += 1
			stat = alterlist(data->list[pos]->MEDSERVICES, cnt)
			data->list[pos]->MEDSERVICES[cnt].MEDSERVICE = TRIM(UAR_GET_CODE_DISPLAY(P.PCT_MED_SERVICE_CD),3)
			stat = alterlist(data->list[pos]->MEDTEAMS, cnt)
			data->list[pos]->MEDTEAMS[cnt].MEDTEAM = TRIM(UAR_GET_CODE_DISPLAY(P.PCT_TEAM_CD),3)
		ENDIF
	FOOT D.ENCNTR_ID
		IF(pos > 0)
			data->list[pos].MEDSERVICES_CNT = cnt
			data->list[pos].MEDTEAMS_CNT = cnt
		ENDIF
	WITH
		EXPAND = 2
		, MAXCOL=5000


;GET CONSULTANT NAME
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031543 ; EVENT CODE FOR 'Consultant' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].CONSULTANT_NAME = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET CLINICAL NOTES
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031535 ; EVENT CODE FOR 'Clinical Notes' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].CLINICAL_NOTES = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET IMAGING
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031611 ; EVENT CODE FOR 'IMAGING' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].IMAGING = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET PATHOLOGY
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031413 ; EVENT CODE FOR 'PATHOLOGY' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].PATHOLOGY = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET MDM QUESTION
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152030797 ; EVENT CODE FOR 'MDM QUESTION' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].MDM_QUESTION = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET MDM DATE
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031995 ; EVENT CODE FOR 'MDM DATE' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].MDM_DATE = FORMAT(CNVTDATE2(SUBSTRING(3, 8, CE.RESULT_VAL), "YYYYMMDD"), "DD/MMM/YYYY ;;D")
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET OP DISCUSSION
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031275 ; EVENT CODE FOR 'OP DISCUSSION' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].OP_DISCUSSION = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET APPOINMENT
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031989 ; EVENT CODE FOR Onc_MDM_ClinicAppt/FollowUp 'APPOINTMENT' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].APPOINMENT = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET SCOPES
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152032001 ; EVENT CODE FOR 'Scopes' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].SCOPES = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET BLOODS
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031285 ; EVENT CODE FOR 'BLOODS' in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].BLOODS = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;GET MEETING
	SELECT INTO "nl:"
	FROM
		CLINICAL_EVENT CE
	PLAN CE
		WHERE
			expand(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
			AND CE.EVENT_CD = 152031405 ; EVENT CODE FOR 'MEETING' Onc_MDM_Cancer MDM or Surgical Meeting in the powerform
			AND CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping data in the background
	ORDER BY CE.PERSON_ID, CE.UPDT_DT_TM DESC ; this selects the most recent update from the filtered list
	HEAD CE.ENCNTR_ID
		pos = locateval(idx,1,data->cnt,CE.ENCNTR_ID,data->list[idx].ENCNTR_ID)
		if(pos > 0)
			data->list[pos].MEETING = TRIM(CE.RESULT_VAL,3)
		endif
	FOOT CE.ENCNTR_ID
		NULL
	WITH EXPAND = 2


;ADD TO 'PATIENTHTML' VARIABLE, A HTML TABLE FOR EACH PATIENT
	call alterlist(html_log->list,data->cnt)
	for(x = 1 to data->cnt)
		set html_log->list[x].start = textlen(trim(patienthtml,3)) + 1
		set patienthtml = build2(patienthtml
        ,"<tr>"
			,"<td>"
			,data->list[x].URN
			,"</td>"
            ,"<td>"
            ,data->list[x].PATIENT_NAME
            ,"</td>"
			,"<td>"
            ,data->list[x].DOB
            ,", "
            ,data->list[x].AGE
            ,", "
            ,data->list[x].GENDER
            ,"</td>"
            ,"<td>"
        )
            	for(y = 1 to data->list[x].MEDSERVICES_CNT)
				set patienthtml = build2(patienthtml
					,data->list[x]->MEDSERVICES[y].MEDSERVICE
					,"&nbsp;"
					,data->list[x]->MEDTEAMS[y].MEDTEAM
					,", &nbsp;&nbsp;"
				)
				endfor
        set patienthtml = build2(patienthtml
        ,"</td>"
            ,"<td>"
            ,data->list[x].CONSULTANT_NAME
            ,"</td>"
            ,"<td>"
            ,data->list[x].OP_DISCUSSION
			,"<br>"
            ,data->list[x].MEETING
            ,"</td>"
            ,"<td>"
            ,data->list[x].CLINICAL_NOTES
            ,"</td>"
            ,"<td>"
            ,data->list[x].IMAGING
			,"&nbsp;"
            ,data->list[x].SCOPES
            ,"</td>"
            ,"<td>"
            ,data->list[x].PATHOLOGY
			,"&nbsp;"
            ,data->list[x].BLOODS
            ,"</td>"
            ,"<td>"
            ,data->list[x].APPOINMENT
            ,"</td>"
            ,"<td>"
            ,data->list[x].MDM_QUESTION
            ,"</td>"
        ,"</tr>"
		)
    endfor

;BUILD HTML PAGE AND SUBSTITUTE IN THE PATIENT TABLE
	set finalhtml = build2(
		"<html><head>"
		,"<title>MPage Print</title>"
		; CSS CODE IS BELOW
			,"<style type='text/css'>"
			,"table, th, td {"
			,"  border: 1px solid black;"
			,"  border-collapse: collapse;"
			,"  padding: 5px;"
			,"  text-align: left;"
			,"}"
			,"</style></head>"
		; TABLE OF PATIENT DATA
			,"<table>"
			,"<tr>"
			,"<th>URN</th>"
            ,"<th>Patient</th>"
			,"<th>DOB, Age, Gender</th>"
            ,"<th>Care Team/s</th>"
            ,"<th>Consultant</th>"
			,"<th>Pre-Op/Post-op Discussion</th>"
            ,"<th>Clinical Notes</th>"
            ,"<th>Imaging & Scope</th>"
            ,"<th>Pathology and Relevant Bloods</th>"
            ,"<th>Clinic appt/Follow up</th>"
            ,"<th>MDM Question</th>"
        	,"</tr>"
		; PATIENT DATA IN THE VARIABLE BELOW
		    ,patienthtml
		;AFTER PATIENT DATA IS SUBSTITUTED
			,"</table>"
			,"</body>"
			,"</html>"
	)

;SEND HTML STRING BACK TO POWERCHART FOR PRINTING
	SET _memory_reply_string = finalhtml

end
go