SELECT
	C_CATALOG_DISP = UAR_GET_CODE_DISPLAY(C.CATALOG_CD)
	, C.PERSON_ID
	, C.RESULT_VAL
	, C.UPDT_DT_TM
	; P.NAME_FULL_FORMATTED
	, C.encntr_id
	, C.authentic_flag
	, *

FROM
	CLINICAL_EVENT   C

;	, (LEFT JOIN PERSON P ON (C.PERSON_ID = P.PERSON_ID))
PLAN C

WHERE
;	C.UPDT_DT_TM > CNVTLOOKBEHIND("35,D") ; Only get's data from oldest 35 days ago
;	AND
	C.event_cd = 86163053 ; Filters for MST Score
;	AND C.encntr_id = "XXXXXXXXXX" ; For a specific patient encounter
	AND C.valid_until_dt_tm > SYSDATE
	AND C.publish_flag = 1
	
	
;JOIN P

ORDER BY
	C.UPDT_DT_TM   DESC

WITH MAXREC = 500, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10