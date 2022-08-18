SELECT
/*
This extract pulls data for Medications administered via the Medications
Administration Wizard (MAW)
*/
	O.UPDT_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
	, O.ORIG_ORDER_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
	, O_CATALOG_TYPE_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_TYPE_CD)
	, O_ORDER_STATUS_DISP = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD)
	, SOURCE_APP = EVALUATE(
		M.SOURCE_APPLICATION_FLAG
		, 0, "Default - no value"
		, 1, "Care Mobil"
		, 2, "Care Admin"
		, 3, "PowerChart"
		)
	, O_MED_ORDER_TYPE_DISP = UAR_GET_CODE_DISPLAY(O.MED_ORDER_TYPE_CD)
	, O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, O.ORDER_MNEMONIC
	, O.ORDERED_AS_MNEMONIC
	, O.ORDER_DETAIL_DISPLAY_LINE
	, STAFF = PR.NAME_FULL_FORMATTED
	, PATIENT = P.NAME_FULL_FORMATTED
;	, AH_ORDER_FLAG = EVALUATE(
;		O.AD_HOC_ORDER_FLAG
;		, 0,"Not ad hoc"
;		, 1,"Ad hoc via Bridge Interface"
;		, 2,"Ad hoc with completed order and task via Cerner Solutions"
;		, 3,"Adhoc Order with pending task and order in ordered status vi"
;		)

FROM
	ORDERS   O
	, PERSON   P
	, PRSNL   PR
	, MED_ADMIN_EVENT   M

PLAN O
	WHERE 
		O.CATALOG_TYPE_CD =2516 ;Pharmacy Orders
		AND 
		O.ORDER_STATUS_CD = 2543 ; Completed Orders
		AND
		O.UPDT_DT_TM > CNVTLOOKBEHIND("30,H")
;		AND
;		O.PERSON_ID = 12921277 ; TESTHTS, Joanne
;		AND
		;O.UPDT_ID IN (); example updaters Ann,Adrain,Rachel,Annie; 11659304,13975953,11658813,12876451

JOIN P WHERE P.PERSON_ID = O.PERSON_ID
JOIN PR WHERE PR.PERSON_ID = O.UPDT_ID
JOIN M WHERE M.ORDER_ID = O.ORDER_ID
	AND
	M.SOURCE_APPLICATION_FLAG = 2 ; Med Admin (which indicates the MAW)

ORDER BY
	O.UPDT_DT_TM   DESC

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 100

; NOTE 
;CARE ADMIN = MAW
; Powerchart = MAR