/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "What is the name of the Primary?" = "" 

WITH OUTDEV, PRIMARY_NAME

;VARIABLES FROM PROMPTS
    DECLARE PRIMARY_NAME_VAR = VC with NoConstant($PRIMARY_NAME),Protect

;VARIABLES FROM THE DB
    DECLARE ACTIVE_VAR = I2 with NoConstant(0),Protect
    DECLARE PRIMARY_MNEMONIC_VAR = VC with NoConstant(""),Protect
    DECLARE PRIMARY_DESCRIPTION_VAR = VC with NoConstant(""),Protect
    DECLARE CATALOG_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_TYPE_VAR = VC with NoConstant(""),Protect
    DECLARE ACTIVITY_SUBTYPE_VAR = VC with NoConstant(""),Protect
    DECLARE CATALOG_CD_VAR = F8 with NoConstant(0.00),Protect
    DECLARE CATALOG_CKI_VAR = VC with NoConstant(""),Protect
    DECLARE ORDERS_COUNT_VAR = F8 with NoConstant(0.00),Protect
    ;DECLARE RESULTS_COUNT_VAR = F8 with NoConstant(0.00),Protect

;HTML VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
    DECLARE CSS_VAR = VC with NoConstant(" "),Protect

; Query from Order_Catalog TABLE
    SELECT INTO "NL:"
        ACTIVE                = OC.ACTIVE_IND
        , PRIMARY_MNEMONIC      = OC.PRIMARY_MNEMONIC
        , PRIMARY_DESCRIPTION   = OC.DESCRIPTION
        , CATALOG_TYPE          = UAR_GET_CODE_DISPLAY(OC.CATALOG_TYPE_CD)
        , ACTIVITY_TYPE         = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_TYPE_CD)
        , ACTIVITY_SUBTYPE      = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_SUBTYPE_CD)
        , CATALOG_CD            = OC.CATALOG_CD
        , CATALOG_CKI           = OC.CKI

    FROM
        ORDER_CATALOG   OC

    WHERE
        OC.PRIMARY_MNEMONIC = PRIMARY_NAME_VAR

    HEAD REPORT ; Setting varibles using info retrieved from the Database in SELECT Seciton
        ACTIVE_VAR                  = ACTIVE
        PRIMARY_MNEMONIC_VAR        = PRIMARY_MNEMONIC
        PRIMARY_DESCRIPTION_VAR     = PRIMARY_DESCRIPTION
        CATALOG_TYPE_VAR            = CATALOG_TYPE
        ACTIVITY_TYPE_VAR           = ACTIVITY_TYPE
        ACTIVITY_SUBTYPE_VAR        = ACTIVITY_SUBTYPE
        CATALOG_CD_VAR              = CATALOG_CD
        CATALOG_CKI_VAR             = CATALOG_CKI


;QUERY FROM ORDERS TABLE
    SELECT INTO "NL:"
        ORDERS_COUNT = COUNT(O.CATALOG_CD)
    
    FROM
        ORDERS O
    
    WHERE
        O.CATALOG_CD = CATALOG_CD_VAR
    
    HEAD REPORT
        ORDERS_COUNT_VAR = ORDERS_COUNT

/* 
;QUERY FROM CLINICAL_EVENT TABLE (DEACTIVATING DUE TO TIME)
    SELECT INTO "NL:"
        RESULTS_COUNT = COUNT(CE.CATALOG_CD)
    
    FROM
        CLINICAL_EVENT CE
    
    WHERE
        CE.CATALOG_CD = CATALOG_CD_VAR
        AND
        CE.VIEW_LEVEL = 1

    HEAD REPORT
        RESULTS_COUNT_VAR = RESULTS_COUNT
 */  
 
;HTML OUT
    SET CSS_VAR = BUILD2(
        "table, th, td {"
        , "border: 1px solid black;"
        , "border-collapse: collapse;"
        , "}"
    )

    SET FINALHTML_VAR = BUILD2(
        "<html>"
        , "<head>"
        , "<title>Medication Audit</title>"
        , "<style>"
        , CSS_VAR
        , "</style>"
        , "</head>"
        , "<h1>Medication Audit</h1>"
        , "<h3>Primary Audit For: "
        , $PRIMARY_NAME
        , "</h3>"
        , "<p1>This Report gives you the information related to a specific pharmacy medication (primary)"
        , "</p1><br><br>"
        , "</head>"
        , "<body>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "PRIMARY MNEMONIC"
        , "</td>"
        , "<td>", PRIMARY_MNEMONIC_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "PRIMARY DESCRIPTION"
        , "</td>"
        , "<td>", PRIMARY_DESCRIPTION_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "ACTIVE (ORDER_CATALOG)?"
        , "</td>"
        , "<td>", ACTIVE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "NUMBER OF ORDERS UNDER PRIMARY"
        , "</td>"
        , "<td>", ORDERS_COUNT_VAR, "</td>"
        , "</tr>"

/*
        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "NUMBER OF RESULTS UNDER PRIMARY"
        , "</td>"
        , "<td>", RESULTS_COUNT_VAR, "</td>"
        , "</tr>"
 */

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "CATALOG TYPE"
        , "</td>"
        , "<td>", CATALOG_TYPE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "ACTIVITY TYPE"
        , "</td>"
        , "<td>", ACTIVITY_TYPE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "ACTIVITY SUBTYPE"
        , "</td>"
        , "<td>", ACTIVITY_SUBTYPE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "CATALOG CODE"
        , "</td>"
        , "<td>", CATALOG_CD_VAR, "</td>"
        , "</tr>" 

        , "<tr>"
        , '<td style="font-weight: bold; width:150px">'
        , "CATALOG CKI"
        , "</td>"
        , "<td>", CATALOG_CKI_VAR, "</td>"
        , "</tr>" 

        , "</table>"
        , "</body>"
        , "</html>"
    )

    ;Send the html text to the window
    set _memory_reply_string = FINALHTML_VAR

end
go