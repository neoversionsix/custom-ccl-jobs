SELECT 
/*
NOTES
Count Outpatient results for FBE tests with the given time period (2022)
*/
	; PATIENT_ID_AND_DT = CONCAT(TRIM(CNVTSTRING(CE.PERSON_ID)),"-", format(ce.event_end_dt_tm, "dd/mm/yyyy hh:mm:ss"))
	; ,
	; EVENT_CODE = TRIM(CNVTSTRING(CE.EVENT_CD))
	CE.EVENT_CD
	,
	P.NAME_FULL_FORMATTED
	,
	AGE_TODAY = CNVTAGE(P.BIRTH_DT_TM)
	,
	AGE_AT_ORDER_DATE = CNVTAGE(P.BIRTH_DT_TM, CE.EVENT_END_DT_TM,0)

FROM
	CLINICAL_EVENT   CE
	,
	ENCOUNTER E
	,
	PERSON P
	
PLAN	CE	
	WHERE	
		CE.VIEW_LEVEL = 1	; ONLY SHOW EVENTS VISIBLE TO ENDUSERS
		AND	CE.VALID_UNTIL_DT_TM > SYSDATE	; ONLY SHOW EVENTS THAT ARE STILL 'VALID' (MODIFIED RESULTS SHOW ONLY THE LATEST VALUE AS 'VALID')
		AND	CE.CONTRIBUTOR_SYSTEM_CD = 86524974	; WH_LAB (PATHOLOGY RESULTS ONLY)
		AND (CE.EVENT_END_DT_TM BETWEEN
					CNVTDATETIME("01-JAN-2022 00:00:00.00")
					AND
					CNVTDATETIME("01-JAN-2023 00:00:00.00")
		)
		AND CE.EVENT_CD IN ; Rubella IgG Ab
            (
			151218964
            )
JOIN P
	WHERE 
		P.PERSON_ID = CE.PERSON_ID
		AND
		P.ACTIVE_IND = 1
		AND
		P.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, curtime3)
		AND
		P.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(CURDATE, curtime3)
		AND
		; AGE FILTER AT TIME OF ORDER IS BELOW
		DATETIMEDIFF(CE.EVENT_END_DT_TM,P.BIRTH_DT_TM) > 6570 ; 6570 Is 18 years or older in days
		AND
		P.SEX_CD = 362.00; FEMALE'S ONLY

JOIN E
	WHERE
		E.ENCNTR_ID = CE.ENCNTR_ID
		AND
		E.ENCNTR_TYPE_CD = 309309; OUTPATIENT ENCOUNTERS

WITH	TIME = 20
