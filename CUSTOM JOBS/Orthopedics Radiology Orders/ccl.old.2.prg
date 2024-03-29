SELECT
	URN = PA.ALIAS
	, P.PERSON_ID
	, PATIENT = P.NAME_FULL_FORMATTED
	, E.ENCNTR_STATUS_CD
	, MED_SERVICE = UAR_GET_CODE_DISPLAY(ELH.MED_SERVICE_CD)
	, ENCNTR_APPT_DATE = ELH.BEG_EFFECTIVE_DT_TM "DD/MM/YYYY HH:MM"
	, E_ID = E.ACTIVE_IND
	, ELH_AI = ELH.ACTIVE_IND
	, ELH.ACTIVE_STATUS_CD
;	, ORDERING_DR = PR.NAME_FULL_FORMATTED
;	, ORDER_DATE = O.ORIG_ORDER_DT_TM
;	, O.ORDER_ID
;	, O_AI = O.ACTIVE_IND
;	, ORDERED_AS = O.ORDERED_AS_MNEMONIC
;	, ORDER_DETAILS = O.ORDER_DETAIL_DISPLAY_LINE
	, ELH_LOC_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(ELH.LOC_NURSE_UNIT_CD)
	, ELH.ACTIVE_STATUS_DT_TM "DD/MM/YYYY HH:MM"
	, ELH.*

FROM
	ENCNTR_LOC_HIST   ELH
	, ENCOUNTER   E
;	, ORDERS   O
	, PERSON   P
	, PERSON_ALIAS   PA

;	, PRSNL   PR

; , SCH_APPT   S
PLAN ELH
	WHERE
		ELH.ACTIVE_IND = 1
		and
		elh.DEPART_DT_TM = NULL ;filters out rows for when the patient left
		and
		elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
		and
		elh.ENCNTR_TYPE_CLASS_CD = 393 ; outpatients only
		AND
		ELH.MED_SERVICE_CD IN (
			87625391.00;Orthopaedic Surgery
  			,86504090.00;Prosthetics & Orthoses
  			,98636040.00;SP Paed Orthopaedics
		)
		AND
		ELH.BEG_EFFECTIVE_DT_TM BETWEEN ; FILTER FOR ORTHO APPOINTMENTS IN THIS TIME RANGE
       		CNVTDATETIME("01-JAN-2022 00:00:00.00")
			AND
			CNVTDATETIME("10-JAN-2022 23:59:59.00")

JOIN E ; ENCOUNTER
	WHERE 
		E.ACTIVE_IND = 1
		and
		E.ENCNTR_ID = ELH.ENCNTR_ID
		AND
		E.ENCNTR_STATUS_CD IN (
			854.00 ;ACTIVE
			,856.00;DISCHARGED
			,666808.00; PENDING ARRIVAL
		)
		AND
		E.ENCNTR_TYPE_CD IN (309309.00); Outpatient Encounters only



JOIN P ; PERSON
	WHERE
		P.PERSON_ID = E.PERSON_ID
		AND
		P.ACTIVE_IND = 1
;		and 
;		p.PERSON_ID IN(   12621550.00,    13952641.00,    13959047.00)

JOIN PA
    WHERE
        P.PERSON_ID = PA.PERSON_ID
        AND
        PA.ALIAS_POOL_CD = 9569589.00 ; this filters for the UR Number
        AND
        PA.ACTIVE_IND = 1
		

;JOIN O ; ORDERS
;	WHERE O.ENCNTR_ID = OUTERJOIN(ELH.ENCNTR_ID) ; OUTERJOIN => KEEP PATIENTS EVEN WITH NO RADIOLOGY ORDERS
;	AND 
;	O.CATALOG_TYPE_CD = OUTERJOIN(2517.00); RADIOLOGY Orders only; OUTERJOIN => KEEP PATIENTS EVEN WITH NO RADIOLOGY ORDERS
;	AND
;	O.ORIG_ORDER_DT_TM >= OUTERJOIN(CNVTDATETIME("01-JAN-2022 00:00:00.00")) ; Start date range of orders
;	AND
;	O.ORIG_ORDER_DT_TM <= OUTERJOIN(CNVTDATETIME("08-JAN-2022 23:59:59.00")) ; end date range of orders
;	AND
;	O.ACTIVE_IND = OUTERJOIN(1)

;JOIN PR ; PRSNL
;	WHERE PR.PERSON_ID = OUTERJOIN(O.STATUS_PRSNL_ID)

ORDER BY
	P.NAME_FULL_FORMATTED
	, ELH.BEG_EFFECTIVE_DT_TM   DESC

WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 60, UAR_CODE(D)