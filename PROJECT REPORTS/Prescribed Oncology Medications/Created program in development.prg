drop program wh_testing_query_88 go
create program wh_testing_query_88

prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV

SELECT INTO $OUTDEV


/**************************************************************
This query is used for testing CCL queries. Can give
better feedback for de bugging

Paste code between the comments below
**************************************************************/

	E.PERSON_ID
	,P.NAME_FULL_FORMATTED
	, URN = PA.ALIAS
	, T_CATALOG_DISP = UAR_GET_CODE_DISPLAY(T.CATALOG_CD)
	, SCHEDULED_DATE = T.SCHEDULED_DT_TM "dd/mm/yy"
	, SCHEDULED_TIME = T.SCHEDULED_DT_TM "hh:mm"

FROM
	ENCOUNTER   E
	, TASK_ACTIVITY   T
;	, CLINICAL_EVENT   CE
;	, TASK_ACTIVITY   TA
;	, ORDERS   O
;	, ENCNTR_ALIAS   EA
	, PERSON   P
	, PERSON_ALIAS   PA

;	, PRSNL   PR
;	, ORDERS   O
;	, FREQUENCY_SCHEDULE   FS
PLAN E;ENCOUNTER
    WHERE
        E.MED_SERVICE_CD = 313015 ; 'ONCOLOGY' MED SERVICE PATIENTS
        AND (;DEPARTED DATE IS IN THE FUTURE OR NEVER AT ALL
            E.DEPART_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
            OR
            E.DISCH_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
            OR 
            (E.DEPART_DT_TM IS NULL AND E.DISCH_DT_TM IS NULL)
        )
        AND (; RECORDED DATE IS TURNED UP IN THE PAST
            E.ARRIVE_DT_TM < CNVTDATETIME(CURDATE, CURTIME3)
            OR
            E.REG_DT_TM < CNVTDATETIME(CURDATE, CURTIME3)
        )
        AND E.ACTIVE_IND = 1 ; ENCOUNTER IS ACTIVE

JOIN T
	WHERE T.PERSON_ID = E.PERSON_ID
		AND T.ACTIVE_IND = 1
		AND T.CATALOG_TYPE_CD = 2516; Pharmacy
		AND T.SCHEDULED_DT_TM BETWEEN CNVTLOOKBEHIND("1,H") AND CNVTLOOKAHEAD("36,H")
			
		
JOIN P;PERSON
    WHERE P.PERSON_ID = E.PERSON_ID
		AND
        P.ACTIVE_IND = 1
        
JOIN PA;PERSON_ALIAS
	WHERE PA.PERSON_ID = E.PERSON_ID
		AND
   		PA.ALIAS_POOL_CD = 9569589.00 ; this filters for the UR Number
   		AND
   		PA.ACTIVE_IND = 1
;		T.PERSON_ID =    13312354.00 ; URN for test patient 9999999

ORDER BY
	E.PERSON_ID
	, T.SCHEDULED_DT_TM
	

/**************************************************************
Leave code beyond this point here
**************************************************************/

WITH MAXREC = 1000, NOCOUNTER,  SEPARATOR=" ", FORMAT, TIME = 120

end
go
