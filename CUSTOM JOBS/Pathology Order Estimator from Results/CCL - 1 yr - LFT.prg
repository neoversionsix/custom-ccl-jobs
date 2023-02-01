SELECT 
/*
NOTES
Count Outpatient results for FBE tests with the given time period (2022)
*/
	PATIENT_ID_AND_DT = CONCAT(TRIM(CNVTSTRING(CE.PERSON_ID)),"-", format(ce.event_end_dt_tm, "dd/mm/yyyy hh:mm:ss"))
	,
	EVENT_CODE = TRIM(CNVTSTRING(CE.EVENT_CD))

FROM
	CLINICAL_EVENT   CE
	,
	ENCOUNTER E
	
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
		AND CE.EVENT_CD IN ; LFT EVENT CODES
            (
		    ; "4052635" ;Bilirubin Total Level (Serum/Plasma)  
			; ,
			4052500 ; ALT Activity (Serum/Plasma)  
			,
			; "4052612" ;AST Activity (Serum/Plasma)  
			; ,
			; "4052496" ;ALP Activity (Serum/Plasma)  
			; ,
			4053255 ;GGT Activity (Serum/Plasma)  
			; ,
			; "4053736" ;Protein Total Level (Serum/Plasma)
			; ,
			; "4052489" ;Albumin Level (Serum/Plasma)
			; ,
			; "4053257" ;Globulin Level (Serum)  
            )
JOIN E
	WHERE
		E.ENCNTR_ID = CE.ENCNTR_ID
		AND
		E.ENCNTR_TYPE_CD = 309309; OUTPATIENT ENCOUNTERS

WITH	TIME = 120

