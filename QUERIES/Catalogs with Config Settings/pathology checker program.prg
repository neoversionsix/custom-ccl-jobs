/*
Programmer: Jason Whittle
This is to check if you have built a pathology orderable correctly
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"

with OUTDEV

;USER INPUT VARIABLES
    DECLARE SYNONYM_NAME_SEARCH_VAR = VC with NoConstant("*MPOX*"),Protect ; EDIT THIS!!!!!!!
    ; EDIT THE BELOW IF YOU WISH TO COMPARE WITH A DIFFERENT SYNONYM
    DECLARE SYNONYM_NAME_SEARCH_COMPARE_VAR = VC with NoConstant("*ADENOVIRUS NAD/PCR SWAB*"),Protect ; EDIT THIS!!!

;VARIABLES SAVED IN PROGRAM
    DECLARE SYNONYM_ID_VAR = F8 with NoConstant(0.00),Protect
    DECLARE SYNONYM_ID_VAR_2 = F8 with NoConstant(0.00),Protect
    DECLARE CATALOG_CD_VAR = F8 with NoConstant(0.00),Protect
    DECLARE CATALOG_CD_VAR_2 = F8 with NoConstant(0.00),Protect
    DECLARE CATALOG_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE CATALOG_TYPE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_TYPE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_SUB_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_SUB_TYPE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DESCRIPTION_VAR = VC with NoConstant(""),Protect
    DECLARE DESCRIPTION_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DEPT_DISPLAY_NAME_VAR = VC with NoConstant(""),Protect
    DECLARE DEPT_DISPLAY_NAME_VAR_2 = VC with NoConstant(""),Protect
    DECLARE SYNONYM_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE SYNONYM_TYPE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE SYNONYM_NAME_VAR = VC with NoConstant(""),Protect
    DECLARE SYNONYM_NAME_VAR_2 = VC with NoConstant(""),Protect
    DECLARE ACTIVE_CHECKBOX_VAR = I2 with NoConstant(0),Protect
    DECLARE ACTIVE_CHECKBOX_VAR_2 = I2 with NoConstant(0),Protect
    DECLARE HIDE_CHECKBOX_VAR = VC with NoConstant(""),Protect
    DECLARE HIDE_CHECKBOX_VAR_2 = VC with NoConstant(""),Protect
    DECLARE VIRTUAL_VIEWS_VAR = VC with NoConstant(""),Protect
    DECLARE VIRTUAL_VIEWS_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DUP_ACTIVE_IND_VAR = I2 with NoConstant(0),Protect
    DECLARE DUP_ACTIVE_IND_VAR_2 = I2 with NoConstant(0),Protect
    DECLARE DUP_HIT_ACTION_VAR = VC with NoConstant(""),Protect
    DECLARE DUP_HIT_ACTION_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DUP_MIN_AHEAD_VAR = I4 with NoConstant(0),Protect
    DECLARE DUP_MIN_AHEAD_VAR_2 = I4 with NoConstant(0),Protect
    DECLARE DUP_MIN_AHEAD_ACTION_VAR = VC with NoConstant(""),Protect
    DECLARE DUP_MIN_AHEAD_ACTION_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DUP_MIN_BEHIND_VAR = I4 with NoConstant(0),Protect
    DECLARE DUP_MIN_BEHIND_VAR_2 = I4 with NoConstant(0),Protect
    DECLARE DUP_MIN_BEHIND_ACTION_VAR = VC with NoConstant(""),Protect
    DECLARE DUP_MIN_BEHIND_ACTION_VAR_2 = VC with NoConstant(""),Protect
    DECLARE ACCESSION_CLASS_VAR = VC with NoConstant(""),Protect
    DECLARE ACCESSION_CLASS_VAR_2 = VC with NoConstant(""),Protect
    DECLARE DEFAULT_COLLECTION_METHOD_VAR = VC with NoConstant(""),Protect
    DECLARE DEFAULT_COLLECTION_METHOD_VAR_2 = VC with NoConstant(""),Protect
    DECLARE SPECIMEN_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE SPECIMEN_TYPE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE SERVICE_RESOURCE_VAR = VC with NoConstant(""),Protect
    DECLARE SERVICE_RESOURCE_VAR_2 = VC with NoConstant(""),Protect
    DECLARE AGE_FROM_VAR = I4 with NoConstant(0),Protect
    DECLARE AGE_FROM_VAR_2 = I4 with NoConstant(0),Protect
    DECLARE AGE_TO_VAR = I4 with NoConstant(0),Protect
    DECLARE AGE_TO_VAR_2 = I4 with NoConstant(0),Protect
    DECLARE COLL_PRIORITY_VAR = VC with NoConstant(""),Protect
    DECLARE COLL_PRIORITY_VAR_2 = VC with NoConstant(""),Protect
    DECLARE MIN_VOL_VAR = F8 with NoConstant(0.00),Protect
    DECLARE MIN_VOL_VAR_2 = F8 with NoConstant(0.00),Protect
    DECLARE CONTAINER_VAR = VC with NoConstant(""),Protect
    DECLARE CONTAINER_VAR_2 = VC with NoConstant(""),Protect
    DECLARE COLLECTION_CLASS_VAR = VC with NoConstant(""),Protect
    DECLARE COLLECTION_CLASS_VAR_2 = VC with NoConstant(""),Protect
    DECLARE SPECIAL_HANDLING_VAR = VC with NoConstant(""),Protect
    DECLARE SPECIAL_HANDLING_VAR_2 = VC with NoConstant(""),Protect

;HTML VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(""),Protect

; Query for New Synonym
    SELECT INTO "NL:"
        SYNONYM_ID = O_C_S.SYNONYM_ID
        , CATALOG_CD = O_C_S.CATALOG_CD
        , CATALOG_TYPE = UAR_GET_CODE_DISPLAY(O_C.CATALOG_TYPE_CD)
        , ACTIVITY_TYPE = UAR_GET_CODE_DISPLAY(O_C.ACTIVITY_TYPE_CD)
        , ACTIVITY_SUB_TYPE = UAR_GET_CODE_DISPLAY(O_C.ACTIVITY_SUBTYPE_CD)
        , DESCRIPTION = O_C.DESCRIPTION
        , DEPT_DISPLAY_NAME = O_C.DEPT_DISPLAY_NAME
        , SYNONYM_TYPE = UAR_GET_CODE_DISPLAY(O_C_S.MNEMONIC_TYPE_CD)
        , SYNONYM_NAME = O_C_S.MNEMONIC
        , ACTIVE_CHECKBOX = O_C_S.ACTIVE_IND
        , HIDE_CHECKBOX = EVALUATE(O_C_S.HIDE_FLAG, 1, "HIDDEN", 0, "NOT HIDDED")
    FROM
        ORDER_CATALOG   O_C
        , ORDER_CATALOG_SYNONYM   O_C_S

    PLAN O_C_S ; ORDER_CATALOG_SYNONYM
        WHERE CNVTUPPER(O_C_S.MNEMONIC_KEY_CAP) = PATSTRING(SYNONYM_NAME_SEARCH_VAR)

    JOIN O_C ; ORDER_CATALOG
        WHERE O_C.CATALOG_CD = O_C_S.CATALOG_CD
            AND O_C.CATALOG_TYPE_CD = 2513 ; Laboratory

    HEAD REPORT ; Setting varibles using info retrieved from the Database in SELECT Seciton
        SYNONYM_ID_VAR = SYNONYM_ID
        CATALOG_CD_VAR = CATALOG_CD
        CATALOG_TYPE_VAR = CATALOG_TYPE
        ACTIVITY_TYPE_VAR = ACTIVITY_TYPE
        ACTIVITY_SUB_TYPE_VAR = ACTIVITY_SUB_TYPE
        DESCRIPTION_VAR = DESCRIPTION
        DEPT_DISPLAY_NAME_VAR = DEPT_DISPLAY_NAME
        SYNONYM_TYPE_VAR = SYNONYM_TYPE
        SYNONYM_NAME_VAR = SYNONYM_NAME
        ACTIVE_CHECKBOX_VAR = ACTIVE_CHECKBOX
        HIDE_CHECKBOX_VAR = HIDE_CHECKBOX
    WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10

; Query for Existing Synonym
    SELECT INTO "NL:"
        SYNONYM_ID = O_C_S.SYNONYM_ID
        , CATALOG_CD = O_C_S.CATALOG_CD
        , CATALOG_TYPE = UAR_GET_CODE_DISPLAY(O_C.CATALOG_TYPE_CD)
        , ACTIVITY_TYPE = UAR_GET_CODE_DISPLAY(O_C.ACTIVITY_TYPE_CD)
        , ACTIVITY_SUB_TYPE = UAR_GET_CODE_DISPLAY(O_C.ACTIVITY_SUBTYPE_CD)
        , DESCRIPTION = O_C.DESCRIPTION
        , DEPT_DISPLAY_NAME = O_C.DEPT_DISPLAY_NAME
        , SYNONYM_TYPE = UAR_GET_CODE_DISPLAY(O_C_S.MNEMONIC_TYPE_CD)
        , SYNONYM_NAME = O_C_S.MNEMONIC
        , ACTIVE_CHECKBOX = O_C_S.ACTIVE_IND
        , HIDE_CHECKBOX = EVALUATE(O_C_S.HIDE_FLAG, 1, "HIDDEN", 0, "NOT HIDDED")
    FROM
        ORDER_CATALOG   O_C
        , ORDER_CATALOG_SYNONYM   O_C_S

    PLAN O_C_S ; ORDER_CATALOG_SYNONYM
        WHERE CNVTUPPER(O_C_S.MNEMONIC_KEY_CAP) = PATSTRING(SYNONYM_NAME_SEARCH_COMPARE_VAR)

    JOIN O_C ; ORDER_CATALOG
        WHERE O_C.CATALOG_CD = O_C_S.CATALOG_CD
            AND O_C.CATALOG_TYPE_CD = 2513 ; Laboratory

    HEAD REPORT ; Setting varibles using info retrieved from the Database in SELECT Seciton
        SYNONYM_ID_VAR_2 = SYNONYM_ID
        CATALOG_CD_VAR_2 = CATALOG_CD
        CATALOG_TYPE_VAR_2 = CATALOG_TYPE
        ACTIVITY_TYPE_VAR_2 = ACTIVITY_TYPE
        ACTIVITY_SUB_TYPE_VAR_2 = ACTIVITY_SUB_TYPE
        DESCRIPTION_VAR_2 = DESCRIPTION
        DEPT_DISPLAY_NAME_VAR_2 = DEPT_DISPLAY_NAME
        SYNONYM_TYPE_VAR_2 = SYNONYM_TYPE
        SYNONYM_NAME_VAR_2 = SYNONYM_NAME
        ACTIVE_CHECKBOX_VAR_2 = ACTIVE_CHECKBOX
        HIDE_CHECKBOX_VAR_2 = HIDE_CHECKBOX

    WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10

;VIRTUAL VIEWS FOR NEW SYNONYM
    SELECT INTO "NL:"
        VIRTUAL_VIEW = UAR_GET_CODE_DISPLAY(O_F_R.FACILITY_CD)
    FROM
        OCS_FACILITY_R  O_F_R
    WHERE
        O_F_R.SYNONYM_ID = SYNONYM_ID_VAR
    ORDER BY
        O_F_R.FACILITY_CD DESC
    HEAD REPORT O_F_R.SYNONYM_ID
    DETAIL
        VIRTUAL_VIEWS_VAR = BUILD2(VIRTUAL_VIEWS_VAR, VIRTUAL_VIEW, "<BR>")
    WITH TIME = 10

;VIRTUAL VIEWS FOR EXISTING SYNONYM
    SELECT INTO "NL:"
        VIRTUAL_VIEW = UAR_GET_CODE_DISPLAY(O_F_R.FACILITY_CD)
    FROM
        OCS_FACILITY_R  O_F_R
    WHERE
        O_F_R.SYNONYM_ID = SYNONYM_ID_VAR_2
    ORDER BY
        O_F_R.FACILITY_CD DESC
    HEAD REPORT O_F_R.SYNONYM_ID
    DETAIL
        VIRTUAL_VIEWS_VAR_2 = BUILD2(VIRTUAL_VIEWS_VAR_2, VIRTUAL_VIEW, "<BR>")
    WITH TIME = 10

; Duplicate Checking for New synonym
    SELECT INTO "NL:"
        DUP_ACTIVE_IND = D_C.ACTIVE_IND
        , DUP_HIT_ACTION = UAR_GET_CODE_DISPLAY(D_C.EXACT_HIT_ACTION_CD)
        , DUP_MIN_AHEAD = D_C.MIN_AHEAD
        , DUP_MIN_AHEAD_ACTION =  UAR_GET_CODE_DISPLAY(D_C.MIN_AHEAD_ACTION_CD)
        , DUP_MIN_BEHIND = D_C.MIN_BEHIND
        , DUP_MIN_BEHIND_ACTION = UAR_GET_CODE_DISPLAY(D_C.MIN_BEHIND_ACTION_CD)
    FROM
        DUP_CHECKING D_C
    WHERE
        D_C.CATALOG_CD = CATALOG_CD_VAR
        AND D_C.ACTIVE_IND = 1
    HEAD REPORT
        DUP_ACTIVE_IND_VAR = DUP_ACTIVE_IND
        DUP_HIT_ACTION_VAR = DUP_HIT_ACTION
        DUP_MIN_AHEAD_VAR = DUP_MIN_AHEAD
        DUP_MIN_AHEAD_ACTION_VAR = DUP_MIN_AHEAD_ACTION
        DUP_MIN_BEHIND_VAR = DUP_MIN_BEHIND
        DUP_MIN_BEHIND_ACTION_VAR = DUP_MIN_BEHIND_ACTION
    WITH TIME = 10

; Duplicate Checking for existing synonym
    SELECT INTO "NL:"
        DUP_ACTIVE_IND = D_C.ACTIVE_IND
        , DUP_HIT_ACTION = UAR_GET_CODE_DISPLAY(D_C.EXACT_HIT_ACTION_CD)
        , DUP_MIN_AHEAD = D_C.MIN_AHEAD
        , DUP_MIN_AHEAD_ACTION =  UAR_GET_CODE_DISPLAY(D_C.MIN_AHEAD_ACTION_CD)
        , DUP_MIN_BEHIND = D_C.MIN_BEHIND
        , DUP_MIN_BEHIND_ACTION = UAR_GET_CODE_DISPLAY(D_C.MIN_BEHIND_ACTION_CD)
    FROM
        DUP_CHECKING D_C
    WHERE
        D_C.CATALOG_CD = CATALOG_CD_VAR_2
        AND D_C.ACTIVE_IND = 1
    HEAD REPORT
        DUP_ACTIVE_IND_VAR_2 = DUP_ACTIVE_IND
        DUP_HIT_ACTION_VAR_2 = DUP_HIT_ACTION
        DUP_MIN_AHEAD_VAR_2 = DUP_MIN_AHEAD
        DUP_MIN_AHEAD_ACTION_VAR_2 = DUP_MIN_AHEAD_ACTION
        DUP_MIN_BEHIND_VAR_2 = DUP_MIN_BEHIND
        DUP_MIN_BEHIND_ACTION_VAR_2 = DUP_MIN_BEHIND_ACTION
    WITH TIME = 10

; Collection Requirements For New Synonym
    SELECT INTO "NL:"
        ACCESSION_CLASS = UAR_GET_CODE_DISPLAY(P.ACCESSION_CLASS_CD)
        , DEFAULT_COLLECTION_METHOD = UAR_GET_CODE_DISPLAY(P.DEFAULT_COLLECTION_METHOD_CD)
        , SPECIMEN_TYPE = UAR_GET_CODE_DISPLAY(P.SPECIMEN_TYPE_CD)
    FROM
        PROCEDURE_SPECIMEN_TYPE   P
    WHERE P.CATALOG_CD = CATALOG_CD_VAR
    HEAD REPORT
        ACCESSION_CLASS_VAR = ACCESSION_CLASS
        DEFAULT_COLLECTION_METHOD_VAR = DEFAULT_COLLECTION_METHOD
        SPECIMEN_TYPE_VAR = SPECIMEN_TYPE
    WITH TIME = 10

    SELECT INTO "NL:"
        SERVICE_RESOURCE = UAR_GET_CODE_DISPLAY(C.SERVICE_RESOURCE_CD)
        , AGE_FROM = C.AGE_FROM_MINUTES
        , AGE_TO = C.AGE_TO_MINUTES
        , COLL_PRIORITY = IF (C.COLLECTION_PRIORITY_CD = 0) "(All)"
            ELSE UAR_GET_CODE_DISPLAY(C.COLLECTION_PRIORITY_CD)
            ENDIF
        , MIN_VOL = C.MIN_VOL
        , CONTAINER = UAR_GET_CODE_DISPLAY(C.SPEC_CNTNR_CD)
        , COLLECTION_CLASS = UAR_GET_CODE_DISPLAY(C.COLL_CLASS_CD)
        , SPECIAL_HANDLING = UAR_GET_CODE_DISPLAY(C.SPEC_HNDL_CD)
    FROM
        COLLECTION_INFO_QUALIFIERS   C
    WHERE C.CATALOG_CD = CATALOG_CD_VAR
    HEAD REPORT
        SERVICE_RESOURCE_VAR = SERVICE_RESOURCE
        AGE_FROM_VAR = AGE_FROM
        AGE_TO_VAR = AGE_TO
        COLL_PRIORITY_VAR = COLL_PRIORITY
        MIN_VOL_VAR = MIN_VOL
        CONTAINER_VAR = CONTAINER
        COLLECTION_CLASS_VAR = COLLECTION_CLASS
        SPECIAL_HANDLING_VAR = SPECIAL_HANDLING
    WITH TIME = 10


; Collection Requirements For Existing Synonym
    SELECT INTO "NL:"
        ACCESSION_CLASS = UAR_GET_CODE_DISPLAY(P.ACCESSION_CLASS_CD)
        , DEFAULT_COLLECTION_METHOD = UAR_GET_CODE_DISPLAY(P.DEFAULT_COLLECTION_METHOD_CD)
        , SPECIMEN_TYPE = UAR_GET_CODE_DISPLAY(P.SPECIMEN_TYPE_CD)
    FROM
        PROCEDURE_SPECIMEN_TYPE   P
    WHERE P.CATALOG_CD = CATALOG_CD_VAR_2
    HEAD REPORT
        ACCESSION_CLASS_VAR_2 = ACCESSION_CLASS
        DEFAULT_COLLECTION_METHOD_VAR_2 = DEFAULT_COLLECTION_METHOD
        SPECIMEN_TYPE_VAR_2 = SPECIMEN_TYPE
    WITH TIME = 10

    SELECT INTO "NL:"
        SERVICE_RESOURCE = UAR_GET_CODE_DISPLAY(C.SERVICE_RESOURCE_CD)
        , AGE_FROM = C.AGE_FROM_MINUTES
        , AGE_TO = C.AGE_TO_MINUTES
        , COLL_PRIORITY = IF (C.COLLECTION_PRIORITY_CD = 0) "(All)"
            ELSE UAR_GET_CODE_DISPLAY(C.COLLECTION_PRIORITY_CD)
            ENDIF
        , MIN_VOL = C.MIN_VOL
        , CONTAINER = UAR_GET_CODE_DISPLAY(C.SPEC_CNTNR_CD)
        , COLLECTION_CLASS = UAR_GET_CODE_DISPLAY(C.COLL_CLASS_CD)
        , SPECIAL_HANDLING = UAR_GET_CODE_DISPLAY(C.SPEC_HNDL_CD)
    FROM
        COLLECTION_INFO_QUALIFIERS   C
    WHERE C.CATALOG_CD = CATALOG_CD_VAR_2
    HEAD REPORT
        SERVICE_RESOURCE_VAR_2 = SERVICE_RESOURCE
        AGE_FROM_VAR_2 = AGE_FROM
        AGE_TO_VAR_2 = AGE_TO
        COLL_PRIORITY_VAR_2 = COLL_PRIORITY
        MIN_VOL_VAR_2 = MIN_VOL
        CONTAINER_VAR_2 = CONTAINER
        COLLECTION_CLASS_VAR_2 = COLLECTION_CLASS
        SPECIAL_HANDLING_VAR_2 = SPECIAL_HANDLING
    WITH TIME = 10

;HTML
    SET FINALHTML_VAR = BUILD2(
    "<!DOCTYPE html>"
    ,'<html lang="en">'
    ,'<head>'
        ,'<meta charset="UTF-8">'
        ,'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
        ,'<title>Pathology Orderable Synonym Build Checker</title>'
        ,'<style>'
            ,'body {'
                ,'font-family: Arial, sans-serif;'
                ,'line-height: 1.6;'
                ,'padding: 20px;'
                ,'max-width: 800px;'
                ,'margin: 0 auto;'
            ,'}'
            ,'h1 {'
                ,'color: #333;'
                ,'text-align: center;'
            ,'}'
            ,'table {'
                ,'width: 100%;'
                ,'border-collapse: collapse;'
                ,'margin-bottom: 20px;'
            ,'}'
            ,'th, td {'
                ,'border: 1px solid #ddd;'
                ,'padding: 8px;'
                ,'text-align: left;'
            ,'}'
            ,'th {'
                ,'background-color: #f2f2f2;'
                ,'font-weight: bold;'
            ,'}'
            ,'tr:nth-child(even) {'
                ,'background-color: #f9f9f9;'
            ,'}'
            ,'.end-report {'
                ,'text-align: center;'
                ,'font-weight: bold;'
                ,'margin-top: 20px;'
            ,'}'
        ,'</style>'
    ,'</head>'
    ,'<body>'
        ,'<h1>Pathology Orderable Synonym Build Checker</h1>'
    ,'<h2>DCP Tools - Synonym Tab</h2>'
        ,'<table>'
            ,'<thead>'
                ,'<tr>'
                    ,'<th>Config Item</th>'
                    ,'<th>Built Synonym</th>'
                    ,'<th>Existing Synonym</th>'
                ,'</tr>'
            ,'</thead>'
            ,'<tbody>'
                ,'<tr>'
                    ,'<td>OCS Synonym id</td>'
                    ,'<td>', SYNONYM_ID_VAR, '</td>'
                    ,'<td>', SYNONYM_ID_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Catalog Type</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Activity Type</td>'
                    ,'<td>', ACTIVITY_TYPE_VAR, '</td>'
                    ,'<td>', ACTIVITY_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Activity Sub Type</td>'
                    ,'<td>', ACTIVITY_SUB_TYPE_VAR, '</td>'
                    ,'<td>', ACTIVITY_SUB_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Description</td>'
                    ,'<td>', DESCRIPTION_VAR, '</td>'
                    ,'<td>', DESCRIPTION_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Department Display Name </td>'
                    ,'<td>', DEPT_DISPLAY_NAME_VAR, '</td>'
                    ,'<td>', DEPT_DISPLAY_NAME_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Synonym Type</td>'
                    ,'<td>', SYNONYM_TYPE_VAR, '</td>'
                    ,'<td>', SYNONYM_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Synonym Name</td>'
                    ,'<td>', SYNONYM_NAME_VAR, '</td>'
                    ,'<td>', SYNONYM_NAME_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Active Checkbox (DCP)</td>'
                    ,'<td>', ACTIVE_CHECKBOX_VAR, '</td>'
                    ,'<td>', ACTIVE_CHECKBOX_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Hidden Checkbox (DCP)</td>'
                    ,'<td>', HIDE_CHECKBOX_VAR, '</td>'
                    ,'<td>', HIDE_CHECKBOX_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Virtual Views (DCP)</td>'
                    ,'<td>', VIRTUAL_VIEWS_VAR, '</td>'
                    ,'<td>', VIRTUAL_VIEWS_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Orderable Status Checkbox</td>'
                    ,'<td>', DUP_ACTIVE_IND_VAR, '</td>'
                    ,'<td>', DUP_ACTIVE_IND_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Behind Action</td>'
                    ,'<td>', DUP_MIN_BEHIND_ACTION_VAR, '</td>'
                    ,'<td>', DUP_MIN_BEHIND_ACTION_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Behind Min</td>'
                    ,'<td>', DUP_MIN_BEHIND_VAR, '</td>'
                    ,'<td>', DUP_MIN_BEHIND_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Ahead Action</td>'
                    ,'<td>', DUP_MIN_AHEAD_ACTION_VAR, '</td>'
                    ,'<td>', DUP_MIN_AHEAD_ACTION_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Ahead Min</td>'
                    ,'<td>', DUP_MIN_AHEAD_VAR, '</td>'
                    ,'<td>', DUP_MIN_AHEAD_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Exact Action</td>'
                    ,'<td>', DUP_HIT_ACTION_VAR, '</td>'
                    ,'<td>', DUP_HIT_ACTION_VAR_2, '</td>'
                ,'</tr>'
            ,'</tbody>'
        ,'</table>'
    ,'<h2>Collection Requirements (collreqmaint)</h2>'
        ,'<table>'
            ,'<thead>'
                ,'<tr>'
                    ,'<th>Config Item</th>'
                    ,'<th>Built Synonym</th>'
                    ,'<th>Existing Synonym</th>'
                ,'</tr>'
            ,'</thead>'
            ,'<tbody>'
                ,'<tr>'
                    ,'<td>Specimen Type</td>'
                    ,'<td>', SPECIMEN_TYPE_VAR, '</td>'
                    ,'<td>', SPECIMEN_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Accession_Class</td>'
                    ,'<td>', ACCESSION_CLASS_VAR, '</td>'
                    ,'<td>', ACCESSION_CLASS_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Default Collection Method</td>'
                    ,'<td>', DEFAULT_COLLECTION_METHOD_VAR, '</td>'
                    ,'<td>', DEFAULT_COLLECTION_METHOD_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Age From</td>'
                    ,'<td>', AGE_FROM_VAR, '</td>'
                    ,'<td>', AGE_FROM_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Age To</td>'
                    ,'<td>', AGE_TO_VAR, '</td>'
                    ,'<td>', AGE_TO_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Coll Priority</td>'
                    ,'<td>', COLL_PRIORITY_VAR, '</td>'
                    ,'<td>', COLL_PRIORITY_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Min Vol</td>'
                    ,'<td>', MIN_VOL_VAR, '</td>'
                    ,'<td>', MIN_VOL_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Container</td>'
                    ,'<td>', CONTAINER_VAR, '</td>'
                    ,'<td>', CONTAINER_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Collection Class</td>'
                    ,'<td>', COLLECTION_CLASS_VAR, '</td>'
                    ,'<td>', COLLECTION_CLASS_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>Special Handling</td>'
                    ,'<td>', SPECIAL_HANDLING_VAR, '</td>'
                    ,'<td>', SPECIAL_HANDLING_VAR_2, '</td>'
                ,'</tr>'
            ,'</tbody>'
        ,'</table>'
        ,'<BR><BR><BR>'
        ,'<div class="end-report">END REPORT</div>'
    ,'</body>'
    ,'</html>'
    )

;Send the html text to the window
    set _memory_reply_string = FINALHTML_VAR

end
go