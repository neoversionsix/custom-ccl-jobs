drop program wh_med_admin_paed:group1 go
create program wh_med_admin_paed:group1

/* NOTES
Programmer: Jason Whittle jason.whittle@wh.org.au
Data Requestor: Example User example.user@wh.org.au
Date: 17-OCT-2022
Purpose:
Used as a template for creating promt programs. This code 
will return all the usernames for accounts that were updated
from the date chosen to the current date.
*/

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Starting Date" = "CURDATE" 

with OUTDEV, FROMDT

SELECT
	O.ORDER_ID
	, DT_COMPLETED = O.UPDT_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
	, DT_COMPLETED_YEAR = O.UPDT_DT_TM "YYYY;;D"
	, DT_COMPLETED_MONTH = O.UPDT_DT_TM "MM;;D"
	, DT_COMPLETED_DAY = O.UPDT_DT_TM "DD;;D"
	, DT_COMPLETED_TIME = O.UPDT_DT_TM "HH:MM:SS;;D"
	, DT_ORDERED = O.ORIG_ORDER_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
;	, CATALOG_TYPE = UAR_GET_CODE_DISPLAY(O.CATALOG_TYPE_CD) ; Eg "Pharmacy Orders"
;	, ORDER_STATUS = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD) ; Eg "Completed"
	, SOURCE_APP = EVALUATE(
		MAE.SOURCE_APPLICATION_FLAG
		, 0, "Default - no value"
		, 1, "Care Mobil"
		, 2, "MAW (Care Admin in DB)"
		, 3, "MAR (PowerChart in DB)"
		)
;	, MED_TYPE = UAR_GET_CODE_DISPLAY(O.MED_ORDER_TYPE_CD)
	, ORDERED = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
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
	, SCANNED = MAE.POSITIVE_PATIENT_IDENT_IND
;    , MAE_ORDER_ID = MAE.ORDER_ID
;    , O_ORDER_ID = O.ORDER_ID
FROM
	ORDERS   O
;	, PERSON   P
;	, PERSON_ALIAS	PA
	, PRSNL   PR
	, MED_ADMIN_EVENT   MAE
	, ENCOUNTER   E

PLAN O
	WHERE 
		O.CATALOG_TYPE_CD =2516 ;Pharmacy Orders
		AND 
		O.ORDER_STATUS_CD = 2543 ; Completed Orders
		AND
		O.UPDT_DT_TM  ; Time Restriction
		BETWEEN
		    CNVTDATETIME($FROMDT)
		    AND
		    CNVTDATETIME(CURDATE,CURTIME)
        	;CNVTDATETIME("01-APR-2022 00:00:00.00")
        	;AND
			;CNVTDATETIME("01-AUG-2022 00:00:00.00")
		AND
		O.ACTIVE_IND = 1
		AND
		O.ACTIVE_STATUS_CD = 188; "active"
;		AND
;		O.PERSON_ID = 12921277 ; limit by patient 12921277 is "TESTHTS, Joanne"

;JOIN PA WHERE PA.PERSON_ID = O.PERSON_ID ; To get patients URN
; 	AND
; 	PA.ALIAS_POOL_CD = 9569589 ;UR Numbers Only

JOIN MAE WHERE MAE.ORDER_ID = O.ORDER_ID
;   AND
;	; Med Admin (MAW) Only (which indicates the MAW)
;	AND
;	MAE.SOURCE_APPLICATION_FLAG = 2
;	AND
;	MAE.PRSNL_ID = 12876451


JOIN E WHERE E.ENCNTR_ID = OUTERJOIN(O.ENCNTR_ID)
	AND E.LOC_NURSE_UNIT_CD =   103390687.00 ; "S CHILDREN'S W", filtering for paediatric ward

JOIN PR WHERE PR.PERSON_ID = OUTERJOIN(MAE.PRSNL_ID) ; To get completing staff member


ORDER BY	
	O.UPDT_DT_TM   DESC
	, O.ORDER_ID   DESC
	, MAE.EVENT_ID   DESC
;	, 0

/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

with time = 1200, SEPARATOR=" ", format

end
go


/*
FOOT NOTES

ORDER COMPLETE CONVERSIONS
CARE ADMIN = MAW
Powerchart = MAR

NO SCAN REASONS
Emergency
Malfunctioning Scann
No Scanner Available
Other
Patient Could nNot Be Identified
Patient Refused Scanning
Patient Under Contant Precautions
Unable to Scan Barcode
Unsafe to Scan

CODE SET FOR SCAN REASONS
4003287 STORED IN TABLE MED_ADMIN_PT_ERROR

July 2019 MAW went active

example updaters Ann,Adrain,Rachel,Annie; 11659304,13975953,11658813,12876451

 */ 
