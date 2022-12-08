drop program wh_oncology_pharmacy_tasks:dba go
create program wh_oncology_pharmacy_tasks:dba

prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV

SELECT DISTINCT INTO $OUTDEV


/**************************************************************
This report will give you a list of:
	
	- current oncology patients

	- that have pending pharmacy tasks (medication 
	administrations)

	- where the tasks are actually sheduled in the system. There
	seems to be an ops job that creates the tasks 29 hours in
	advance. It will aso give you tasks in the last 24 hours
	that have not been done yet.
**************************************************************/

	P.NAME_FULL_FORMATTED
	, O.ORDER_ID
	, E.PERSON_ID
	, URN = PA.ALIAS
	, T_CATALOG_DISP = UAR_GET_CODE_DISPLAY(T.CATALOG_CD)
	, T.TASK_STATUS_CD
	, T_TASK_STATUS_DISP = UAR_GET_CODE_DISPLAY(T.TASK_STATUS_CD)
	, O.ORDER_MNEMONIC
	, SCHEDULED_DATE = T.SCHEDULED_DT_TM "dd/mm/yy"
	, SCHEDULED_TIME = T.SCHEDULED_DT_TM "hh:mm"
	, E_LOC_FACILITY_DISP = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
	, E_LOC_ROOM_DISP = UAR_GET_CODE_DISPLAY(E.LOC_ROOM_CD)
	, E_LOCATION_DISP = UAR_GET_CODE_DISPLAY(E.LOCATION_CD)
	, E_LOC_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
	, E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)

FROM
	ENCOUNTER   E
	, TASK_ACTIVITY   T
	, ORDERS   O
	, PERSON   P
	, PERSON_ALIAS   PA
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
        ; SELECT ONLY ONE ENCOUNTER ROW PER PERSON_ID

JOIN T;TASK ACTIVITY
	WHERE T.PERSON_ID = E.PERSON_ID
		AND T.ACTIVE_IND = 1
		AND T.CATALOG_TYPE_CD = 2516; Pharmacy
		AND T.SCHEDULED_DT_TM BETWEEN CNVTLOOKBEHIND("24,H") AND CNVTLOOKAHEAD("36,H")
		AND T.TASK_STATUS_CD = 429; PENDING TASKS
			
		
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
        AND
        PA.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)

JOIN O;ORDERS
	WHERE O.ORDER_ID = T.ORDER_ID

ORDER BY
	P.NAME_FULL_FORMATTED
	, E.PERSON_ID
	, T.SCHEDULED_DT_TM
	, O.ORDER_MNEMONIC
	, 0

WITH NOCOUNTER
	,  
	SEPARATOR=" ", 
	FORMAT
	, 
	TIME = 120

end
go
