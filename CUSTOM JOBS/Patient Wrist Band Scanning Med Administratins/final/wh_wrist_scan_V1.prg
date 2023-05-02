drop program wh_wrist_scan go
create program wh_wrist_scan

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE"

WITH OUTDEV, STA_DATE_TM, END_DATE_TM

;INITIAL VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
    DECLARE CSS_VAR = VC with NoConstant(" "),Protect
    DECLARE TITLE_VAR = VC with Constant("Medication Administration Scanner Override Reason - IN TESTING/DEVELOPMENT"),Protect
    DECLARE REPORT_DESC_VAR = VC with NoConstant(""),Protect
    DECLARE ACCURACY_NOTES_VAR = VC with NoConstant(""),Protect
    DECLARE FH_LOCATION_CD_VAR = F8 with constant(85758822.00),protect
    DECLARE SH_LOCATION_CD_VAR = F8 with constant(86163400.00),protect
    DECLARE WH_LOCATION_CD_VAR = F8 with constant(86163477.00),protect
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
        ,"<br>&nbsp;&nbsp;&nbsp;&nbsp;"
        ,"- Patient location data is not 100% accurate (related to Encounter Location History table data recording) "
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
;Organisation WH Heading
    SET FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h2>WESTERN HEALTH TOTALS</h2>"
    )
;Organisation Medication Administration Errors Totals
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
            , "<h3>Organisation (WH) Medication Administration Error Totals</h3>"
            , "<table width='50%'>"
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
;Organisation Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
    GROUP BY MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Organisation (WH) Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Organisation MAW VS MAR USE
    SELECT INTO "NL:"
        SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
    GROUP BY MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Organisation (WH) MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Footscray Heading
    SET FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<BR><BR>"
            , "<h2>FOOTSCRAY HOSPITAL</h2>"
    )
;Footscray Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = FH_LOCATION_CD_VAR ; Footscray Hospital Only
    GROUP BY MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Footscray Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Footscray MAW VS MAR USE
    SELECT INTO "NL:"
        SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = FH_LOCATION_CD_VAR ; Footscray Hospital Only
    GROUP BY MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Footscray MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

;Footscray Ward Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	    SCANNED = EVALUATE(
            MAE.POSITIVE_PATIENT_IDENT_IND
            ,1, "Scanned"
            ,0, "NOT Scanned"
        )
        , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = FH_LOCATION_CD_VAR ; Footscray Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Footscray Ward Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Footscray Ward MAW VS MAR USE
    SELECT INTO "NL:"
        NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = FH_LOCATION_CD_VAR ; Footscray Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Footscray Ward MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Sunshine Heading
    SET FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<BR><BR>"
            , "<h2>SUNSHINE HOSPITAL</h2>"
    )
;Sunshine Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = SH_LOCATION_CD_VAR ; Sunshine Hospital Only
    GROUP BY MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Sunshine Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Sunshine MAW VS MAR USE
    SELECT INTO "NL:"
        SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = SH_LOCATION_CD_VAR ; Sunshine Hospital Only
    GROUP BY MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Sunshine MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

;Sunshine Ward Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	    SCANNED = EVALUATE(
            MAE.POSITIVE_PATIENT_IDENT_IND
            ,1, "Scanned"
            ,0, "NOT Scanned"
        )
        , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = SH_LOCATION_CD_VAR ; Sunshine Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Sunshine Ward Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Sunshine Ward MAW VS MAR USE
    SELECT INTO "NL:"
        NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = SH_LOCATION_CD_VAR ; Sunshine Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Sunshine Ward MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Williamstown Heading
    SET FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<BR><BR>"
            , "<h2>WILLIAMSTOWN HOSPITAL</h2>"
    )
;Williamstown Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	SCANNED = EVALUATE(
        MAE.POSITIVE_PATIENT_IDENT_IND
        ,1, "Scanned"
        ,0, "NOT Scanned"
    )
    , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = WH_LOCATION_CD_VAR ; Williamstown Hospital Only
    GROUP BY MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Williamstown Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Williamstown MAW VS MAR USE
    SELECT INTO "NL:"
        SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = WH_LOCATION_CD_VAR ; Williamstown Hospital Only
    GROUP BY MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Williamstown MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60

;Williamstown Ward Scan Totals
    SELECT INTO "NL:"
    ; Wristband Scanned?
	    SCANNED = EVALUATE(
            MAE.POSITIVE_PATIENT_IDENT_IND
            ,1, "Scanned"
            ,0, "NOT Scanned"
        )
        , NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SCAN_TOTAL = CNVTSTRING(COUNT(*))
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
        AND E.LOC_FACILITY_CD = WH_LOCATION_CD_VAR ; Williamstown Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    ORDER BY MAE.NURSE_UNIT_CD, MAE.POSITIVE_PATIENT_IDENT_IND
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<h3>Williamstown Ward Wristband Scan Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SCANNED, "</td>"
            , "<td>", SCAN_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Williamstown Ward MAW VS MAR USE
    SELECT INTO "NL:"
        NURSE_WARD = UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD) ; Nurse 'Ward'
        , SOURCE_APP = EVALUATE(
            MAE.SOURCE_APPLICATION_FLAG
            , 2, "MAW (Care Admin)"
            , 3, "MAR (PowerChart)"
            )
        , SOURCE_APP_TOTAL = CNVTSTRING(COUNT(*))
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
        AND
        MAE.SOURCE_APPLICATION_FLAG IN (2,3); Only MAW and MAR Meds
    JOIN E WHERE E.ENCNTR_ID = O.ENCNTR_ID
        AND E.LOC_FACILITY_CD = WH_LOCATION_CD_VAR ; Williamstown Hospital Only
    GROUP BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    ORDER BY MAE.NURSE_UNIT_CD, MAE.SOURCE_APPLICATION_FLAG
    HEAD REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<br>"
            , "<h3>Williamstown Ward MAW and MAR Use Totals</h3>"
            , "<table width='50%'>"
        )
    DETAIL
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "<tr>"
            , '<td style="font-weight: bold">', NURSE_WARD, "</td>"
            , '<td style="font-weight: bold">', SOURCE_APP, "</td>"
            , "<td>", SOURCE_APP_TOTAL, "</td>"
            , "</tr>"
        )
    FOOT REPORT
        FINALHTML_VAR = BUILD2(
            FINALHTML_VAR
            , "</table>"
        )
    WITH TIME = 60
;Finalise HTML Code
    SET FINALHTML_VAR = BUILD2(
        FINALHTML_VAR
        , "<br>"
        , "<p>",ACCURACY_NOTES_VAR,"</p>"
        , "</body>"
        , "</html>"
    )

;Send the html text to the window
    SET _memory_reply_string = FINALHTML_VAR
;END CCL PRG
    end
    go