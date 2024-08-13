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
    DECLARE CATALOG_TYPE_VAR = VC with NoConstant(" "),Protect
    DECLARE ACTIVITY_TYPE_VAR = VC with NoConstant(" "),Protect
    DECLARE ACTIVITY_SUB_TYPE_VAR = VC with NoConstant(" "),Protect
    DECLARE DESCRIPTION_VAR = VC with NoConstant(" "),Protect
    DECLARE DEPT_DISPLAY_NAME_VAR = VC with NoConstant(" "),Protect
    DECLARE SYNONYM_TYPE_VAR = VC with NoConstant(" "),Protect
    DECLARE SYNONYM_NAME_VAR = VC with NoConstant(" "),Protect
    DECLARE ACTIVE_CHECKBOX_VAR = I2 with NoConstant(0),Protect
    DECLARE HIDE_CHECKBOX_VAR = VC with NoConstant(" "),Protect

    ; FOR EXISTING SYNONYM COMPARING TO
    DECLARE CATALOG_TYPE_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE ACTIVITY_TYPE_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE ACTIVITY_SUB_TYPE_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE DESCRIPTION_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE DEPT_DISPLAY_NAME_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE SYNONYM_TYPE_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE SYNONYM_NAME_VAR_2 = VC with NoConstant(" "),Protect
    DECLARE ACTIVE_CHECKBOX_VAR_2 = I2 with NoConstant(0),Protect
    DECLARE HIDE_CHECKBOX_VAR_2 = VC with NoConstant(" "),Protect

;HTML VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect

; Query for New Synonym
    SELECT INTO "NL:"
        CATALOG_TYPE = UAR_GET_CODE_DISPLAY(O_C.CATALOG_TYPE_CD)
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
    ,''
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
                    ,'<td>CATALOG TYPE</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ACTIVITY_TYPE</td>'
                    ,'<td>', ACTIVITY_TYPE_VAR, '</td>'
                    ,'<td>', ACTIVITY_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>THYROID_FUNC</td>'
                    ,'<td>', ACTIVITY_SUB_TYPE_VAR, '</td>'
                    ,'<td>', ACTIVITY_SUB_TYPE_VAR_2, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>LIVER_ENZYMES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
                ,'<tr>'
                    ,'<td>ELECTROLYTES</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                    ,'<td>', CATALOG_TYPE_VAR, '</td>'
                ,'</tr>'
            ,'</tbody>'
        ,'</table>'
    ,''
        ,'<div class="end-report">END REPORT</div>'
    ,'</body>'
    ,'</html>'
    )

;Send the html text to the window
    set _memory_reply_string = FINALHTML_VAR

end
go