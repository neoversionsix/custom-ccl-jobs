SELECT
	c.result_val
	, FORMAT(C.UPDT_DT_TM, "dd/mm/yyyy HH:MM:SS")
	, *

FROM
	clinical_event   c

;	, (LEFT JOIN PERSON P ON (C.PERSON_ID = P.PERSON_ID))
;PLAN C

WHERE
;	C.UPDT_DT_TM > CNVTLOOKBEHIND("35,D") ; Only get's data from oldest 35 days ago
;	AND
	C.event_cd = 86163053 ; Filters for MST Score
	AND C.valid_until_dt_tm > SYSDATE ; not invalid
	AND C.publish_flag = 1 ; publish
;	AND C.encntr_id = "XXXXXXXXXX" ; For a specific patient encounter
	
	
;JOIN P

ORDER BY
	c.updt_dt_tm    desc

WITH MAXREC = 500, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10