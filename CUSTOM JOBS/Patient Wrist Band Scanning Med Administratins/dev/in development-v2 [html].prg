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
    DECLARE TITLE_VAR = VC with Constant("Medication Administration Scanner Override Reason"),Protect
    DECLARE REPORT_DESC_VAR = VC with NoConstant(""),Protect
    DECLARE ACCURACY_NOTES_VAR = VC with NoConstant(""),Protect
    SET REPORT_DESC_VAR = BUILD2(
        "This Report gives you the counts of:"
        ,"<br>&nbsp;&nbsp;&nbsp;&nbsp;"
        ,"1) Medication Administration errors for a chosen time range."
        ,"<br>&nbsp;&nbsp;&nbsp;&nbsp;"
        ,"2) Counts for patient wristband scanning by ward when administering medications"
        ,"<br>"
        ,"It is useful for estimating how many"
        ," times the wristbands were scanned/not-scanned when administering medications."
    )
    SET ACCURACY_NOTES_VAR = BUILD2(
         "These values will not be 100% Accurate."
        , " Some reasonable assumptions needed to be made when developing this report."
        ," Testing was conducted but can't be 100% conclusive"
        ,"<br>Known Limitations:<br>&nbsp;&nbsp;&nbsp;&nbsp;" 
        ,"- Totals for the first table (WH Medication Administration Error Totals) include fake 'test' patient totals."
        ,"<br>&nbsp;&nbsp;&nbsp;&nbsp;"
        ,"- Not all data is recorded. This can depend on clinical workflow."
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
    , "<h3>Time Range:</h3>"
    , $STA_DATE_TM
    , "<br>TO<br>"
    , $END_DATE_TM
    , "<br><br><p1>"
    , REPORT_DESC_VAR
    , "</p1><br><br>"
	, "</head>"
	, "<body>"
    )

; Medication Administration Errors Totals
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
            , "<h3>WH Medication Administration Error Totals</h3>"
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

; Footscray Location Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
    , WARD_SCAN_TOTAL = CNVTSTRING(COUNT(*))
    FROM
        ORDERS   O
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
                CNVTDATETIME($STA_DATE_TM)
                AND
                CNVTDATETIME($END_DATE_TM)
            AND
            O.ACTIVE_IND = 1
            AND
            O.ACTIVE_STATUS_CD = 188; "active"
    JOIN MAE WHERE MAE.ORDER_ID = O.ORDER_ID
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = 85758822.00 ; Footscray

    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Footscray Wristband Scan Totals</h3>"
            , "<table width='40%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", WARD_SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

; Sunshine Location Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
    , WARD_SCAN_TOTAL = CNVTSTRING(COUNT(*))
    FROM
        ORDERS   O
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
                CNVTDATETIME($STA_DATE_TM)
                AND
                CNVTDATETIME($END_DATE_TM)
            AND
            O.ACTIVE_IND = 1
            AND
            O.ACTIVE_STATUS_CD = 188; "active"
    JOIN MAE WHERE MAE.ORDER_ID = O.ORDER_ID
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = 86163400.00; Sunshine

    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Sunshine Wristband Scan Totals</h3>"
            , "<table width='40%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", WARD_SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

; Williamstown Location Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
    , WARD_SCAN_TOTAL = CNVTSTRING(COUNT(*))
    FROM
        ORDERS   O
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
                CNVTDATETIME($STA_DATE_TM)
                AND
                CNVTDATETIME($END_DATE_TM)
            AND
            O.ACTIVE_IND = 1
            AND
            O.ACTIVE_STATUS_CD = 188; "active"
    JOIN MAE WHERE MAE.ORDER_ID = O.ORDER_ID
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = 86163477.00; Williamstown

    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Williamstown Wristband Scan Totals</h3>"
            , "<table width='40%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", WARD_SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

SET FINALHTML_VAR = BUILD2(
    FINALHTML_VAR
    , "<br>"
    , "<p>",ACCURACY_NOTES_VAR,"</p>"
    , "</body>"
    , "</html>"
)

;Send the html text to the window
    SET _memory_reply_string = FINALHTML_VAR

end
go