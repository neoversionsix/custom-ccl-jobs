SELECT
	DT_COMPLETED = O.UPDT_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
	, DT_ORDERED = O.ORIG_ORDER_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
;	, CATALOG_TYPE = UAR_GET_CODE_DISPLAY(O.CATALOG_TYPE_CD) ; Eg "Pharmacy Orders"
;	, ORDER_STATUS = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD) ; Eg "Completed"
	, SOURCE_APP = EVALUATE(
		M.SOURCE_APPLICATION_FLAG
		, 0, "Default - no value"
		, 1, "Care Mobil"
		, 2, "MAW (Care Admin)"
		, 3, "PowerChart"
		)
	, MED_TYPE = UAR_GET_CODE_DISPLAY(O.MED_ORDER_TYPE_CD)
	, ORDERD = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
;	, O.ORDER_MNEMONIC
;	, O.ORDERED_AS_MNEMONIC
;	, ORDER_DETAIL = O.ORDER_DETAIL_DISPLAY_LINE
	, STAFF = PR.NAME_FULL_FORMATTED
;	, PATIENT = P.NAME_FULL_FORMATTED
;	, URN = PA.ALIAS
;	, AH_ORDER_FLAG = EVALUATE(
;		O.AD_HOC_ORDER_FLAG
;		, 0,"Not ad hoc"
;		, 1,"Ad hoc via Bridge Interface"
;		, 2,"Ad hoc with completed order and task via Cerner Solutions"
;		, 3,"Adhoc Order with pending task and order in ordered status vi"
;		)
	, E_LOC_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
	, E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)

FROM
	ORDERS   O
;	, PERSON   P
	, PRSNL   PR
	, MED_ADMIN_EVENT   M
	, ENCOUNTER   E

;	, PERSON_ALIAS	PA
PLAN O
	WHERE 
		O.CATALOG_TYPE_CD =2516 ;Pharmacy Orders
		AND 
		O.ORDER_STATUS_CD = 2543 ; Completed Orders
		AND
		O.UPDT_DT_TM  ; Time Restriction
		BETWEEN
        	CNVTDATETIME("01-JUL-2022 00:00:00.00")
        	AND
        	CNVTDATETIME("01-AUG-2022 00:00:00.00")	 
;		AND
;		O.PERSON_ID = 12921277 ; limit by patient 12921277 is "TESTHTS, Joanne"


;JOIN P WHERE P.PERSON_ID = O.PERSON_ID ; this does not seem to get the person completing the order 
JOIN M WHERE M.ORDER_ID = O.ORDER_ID
;	; Med Admin (MAW) Only (which indicates the MAW)
;	AND
;	M.SOURCE_APPLICATION_FLAG = 2 

JOIN PR WHERE PR.PERSON_ID = M.PRSNL_ID ; To get completing staff member
; 	example updaters Ann,Adrain,Rachel,Annie; 11659304,13975953,11658813,12876451
;	AND
;	M.PRSNL_ID = 
;JOIN PA WHERE PA.PERSON_ID = O.PERSON_ID ; To get patients URN
; 	AND
; 	PA.ALIAS_POOL_CD = 9569589 ;UR Numbers Only

JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
	AND O.ACTIVE_IND = 1

ORDER BY
	O.UPDT_DT_TM   DESC

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 500
; NOTE 
;CARE ADMIN = MAW
; Powerchart = MAR