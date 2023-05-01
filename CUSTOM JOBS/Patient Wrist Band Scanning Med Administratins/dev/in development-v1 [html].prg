drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE"

WITH OUTDEV, STA_DATE_TM, END_DATE_TM

;INITIAL VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
    DECLARE CSS_VAR = VC with NoConstant(" "),Protect
    DECLARE TITLE_VAR = VC with Constant("Medication Administration Patient Errors"),Protect
    DECLARE REPORT_DESC_VAR = VC with NoConstant(""),Protect
    SET REPORT_DESC_VAR = BUILD2(
        "This Report gives you the counts of the Medication Administration"
        , " errors for a chosen time range. It is useful for seeing how many"
        , " times the wristbands were not scanned when administering medications."
    )
    SET CSS_VAR = BUILD2(
        "table, th, td {"
        , "border: 1px solid black;"
        , "border-collapse: collapse;"
        , "}"
    )
    SET FINALHTML_VAR = BUILD2(
      "<html>"
	, "<head>"
	, "<title>"
    , TITLE_VAR
    , "</title>"
    , "<style>"
    , CSS_VAR
    , "</style>"
    , "</head>"
    , "<h1>"
    , TITLE_VAR
    , "</h1>"
    , "<h3>Time Range:"
    , $STA_DATE_TM
    , $END_DATE_TM
    , "</h3>"
    , "<p1>"
    , REPORT_DESC_VAR
    , "</p1><br><br>"
	, "</head>"
	, "<body>"
    )

SELECT INTO "NL:"
    M_A_P_E.REASON_CD
    , REASON_DISP = UAR_GET_CODE_DISPLAY(M_A_P_E.REASON_CD)
    , ERROR_COUNT = CNVTSTRING(count(M_A_P_E.MED_ADMIN_PT_ERROR_ID))
FROM
	MED_ADMIN_PT_ERROR   M_A_P_E
WHERE
        M_A_P_E.UPDT_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
        AND
        M_A_P_E.REASON_CD != 0.0
GROUP BY M_A_P_E.REASON_CD
ORDER BY M_A_P_E.REASON_CD
HEAD REPORT
    FINALHTML_VAR = BUILD2(
        FINALHTML_VAR
        , "<table width='40%'>"
    )
DETAIL
	FINALHTML_VAR = BUILD2(
        FINALHTML_VAR
        , "<tr>"
        , '<td style="font-weight: bold">', REASON_DISP, "</td>"
        , "<td>", ERROR_COUNT, "</td>"
        , "</tr>"
    )
FOOT REPORT
    FINALHTML_VAR = BUILD2(
        FINALHTML_VAR
        , "</table>"
    )
WITH TIME = 60


SELECT INTO "NL:"
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
		    CNVTDATETIME($ENDDT)
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



SET FINALHTML_VAR = BUILD2(
    FINALHTML_VAR
    , "</body>"
    , "</html>"
)

;Send the html text to the window
    SET _memory_reply_string = FINALHTML_VAR



end
go