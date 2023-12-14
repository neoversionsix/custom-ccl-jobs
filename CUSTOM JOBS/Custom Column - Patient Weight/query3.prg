SELECT
	C.UPDT_DT_TM
	, C.RESULT_VAL
	, C.PERSON_ID
	, C.PUBLISH_FLAG
	, C.VIEW_LEVEL
	, C.ENCNTR_ID
	, C.CLINICAL_EVENT_ID
	, C.EVENT_ID

FROM
	CLINICAL_EVENT   C

WHERE 
	C.PERSON_ID = 12345
	AND
	C.event_cd = 7334438 ; Filters Weight Measured
	AND 
	C.valid_until_dt_tm > SYSDATE ; not invalid time
	AND 
	C.publish_flag = 1 ; publish
	AND 
	C.view_level = 1; viewable
	; AND
    /* 
	C.PERFORMED_DT_TM = (
		select MAX(CE.PERFORMED_DT_TM)
		from CLINICAL_EVENT CE
		where
				CE.PERSON_ID = 12345
				AND
				CE.event_cd = 7334438 ; Filters Weight Measured
				AND 
				CE.valid_until_dt_tm > SYSDATE ; not invalid time
				AND 
				CE.publish_flag = 1 ; publish
				AND 
				CE.view_level = 1; viewable
	)
*/
ORDER BY
	C.PERFORMED_DT_TM

WITH NOCOUNTER
	, 
	SEPARATOR=" ", 
	FORMAT