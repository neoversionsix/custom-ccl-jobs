/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"

with OUTDEV

;USER INPUT VARIABLES
    DECLARE PRIMARY_NAME_VAR = VC with NoConstant("*ibuprofen*"),Protect ; EDIT THIS!!!!!!!

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
    DECLARE DCP_CLIN_CAT_VAR = VC with NoConstant(""),Protect
    DECLARE PRINT_REQ_IND_VAR = I2 with NoConstant(0),Protect
    DECLARE REQUISITION_FORMAT_VAR = VC with NoConstant(""),Protect

;HTML VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
    DECLARE CSS_VAR = VC with NoConstant(" "),Protect
    DECLARE ACTIVE_VAR_STYLE = VC with NoConstant(""),Protect

; Query from Order_Catalog TABLE
    SELECT INTO "NL:"
        ACTIVE                  = OC.ACTIVE_IND
        , PRIMARY_MNEMONIC      = OC.PRIMARY_MNEMONIC
        , PRIMARY_DESCRIPTION   = OC.DESCRIPTION
        , CATALOG_TYPE          = UAR_GET_CODE_DISPLAY(OC.CATALOG_TYPE_CD)
        , ACTIVITY_TYPE         = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_TYPE_CD)
        , ACTIVITY_SUBTYPE      = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_SUBTYPE_CD)
        , CATALOG_CD            = OC.CATALOG_CD
        , CATALOG_CKI           = OC.CKI
        , DCP_CLIN_CAT          = UAR_GET_CODE_DISPLAY(OC.DCP_CLIN_CAT_CD)
        , PRINT_REQ_IND         = OC.PRINT_REQ_IND
        , REQUISITION_FORMAT    = UAR_GET_CODE_DISPLAY(OC.REQUISITION_FORMAT_CD)

    FROM
        ORDER_CATALOG   OC

    WHERE
        OC.PRIMARY_MNEMONIC = PATSTRING(PRIMARY_NAME_VAR)

    HEAD REPORT ; Setting varibles using info retrieved from the Database in SELECT Seciton
        ACTIVE_VAR                  = ACTIVE
        PRIMARY_MNEMONIC_VAR        = PRIMARY_MNEMONIC
        PRIMARY_DESCRIPTION_VAR     = PRIMARY_DESCRIPTION
        CATALOG_TYPE_VAR            = CATALOG_TYPE
        ACTIVITY_TYPE_VAR           = ACTIVITY_TYPE
        ACTIVITY_SUBTYPE_VAR        = ACTIVITY_SUBTYPE
        CATALOG_CD_VAR              = CATALOG_CD
        CATALOG_CKI_VAR             = CATALOG_CKI
        DCP_CLIN_CAT_VAR            = DCP_CLIN_CAT
        PRINT_REQ_IND_VAR           = PRINT_REQ_IND
        REQUISITION_FORMAT_VAR      = REQUISITION_FORMAT
    WITH TIME = 10


;QUERY FROM ORDERS TABLE
    SELECT INTO "NL:"
        ORDERS_COUNT = COUNT(O.CATALOG_CD)

    FROM
        ORDERS O

    WHERE
        O.CATALOG_CD = CATALOG_CD_VAR

    HEAD REPORT
        ORDERS_COUNT_VAR = ORDERS_COUNT

    WITH TIME = 5

;CELL BACKGROUNDS
IF (ACTIVE_VAR = 1)
    SET ACTIVE_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET ACTIVE_VAR_STYLE = ' style="background-color: grey;"'
ENDIF

IF (CATALOG_TYPE_VAR = "Pharmacy")
    SET CATALOG_TYPE_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET CATALOG_TYPE_VAR_STYLE = ' style="background-color: red;"'
ENDIF

IF (ACTIVITY_TYPE_VAR = "Pharmacy")
    SET ACTIVITY_TYPE_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET ACTIVITY_TYPE_VAR_STYLE = ' style="background-color: red;"'
ENDIF

IF (DCP_CLIN_CAT_VAR = "Medications")
    SET DCP_CLIN_CAT_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET DCP_CLIN_CAT_VAR_STYLE = ' style="background-color: red;"'
ENDIF

IF (PRINT_REQ_IND_VAR = 1)
    SET PRINT_REQ_IND_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET PRINT_REQ_IND_VAR_STYLE = ' style="background-color: red;"'
ENDIF

IF (REQUISITION_FORMAT_VAR = "VIC Standard Prescription")
    SET REQUISITION_FORMAT_VAR_STYLE = ' style="background-color: lightgreen;"'
ELSE
    SET REQUISITION_FORMAT_VAR_STYLE = ' style="background-color: red;"'
ENDIF

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
        , "<title>Pharmacy Medication Audit</title>"
        , "<style>"
        , CSS_VAR
        , "</style>"
        , "</head>"
        , "<h1>Medication Audit</h1>"
        , "<h2>Primary Audit For: "
        , PRIMARY_NAME_VAR
        , "</h2>"
        , "<p1>This Report gives you the information related to a specific pharmacy medication (primary)"
        , "</p1><br><br>"
        , "</head>"
        , "<body>"

        , "<h3>Main Tab</h3>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "PRIMARY MNEMONIC"
        , "</td>"
        , "<td>", PRIMARY_MNEMONIC_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "PRIMARY DESCRIPTION"
        , "</td>"
        , "<td>", PRIMARY_DESCRIPTION_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "ACTIVE (ORDER_CATALOG)?"
        , "</td>"
        , "<td", ACTIVE_VAR_STYLE, ">", ACTIVE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "NUMBER OF ORDERS UNDER PRIMARY"
        , "</td>"
        , "<td>", ORDERS_COUNT_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "CATALOG TYPE"
        , "</td>"
        , "<td", CATALOG_TYPE_VAR_STYLE, ">", CATALOG_TYPE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "ACTIVITY TYPE"
        , "</td>"
        , "<td", ACTIVITY_TYPE_VAR_STYLE, ">", ACTIVITY_TYPE_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "ACTIVITY SUBTYPE"
        , "</td>"
        , "<td>", ACTIVITY_SUBTYPE_VAR, "</td>"
        , "</tr>"

        , "</table>"

        , "<h3>Misc Tab</h3>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "DCP CLINICAL CATEGORY"
        , "</td>"
        , "<td", DCP_CLIN_CAT_VAR_STYLE, ">", DCP_CLIN_CAT_VAR, "</td>"
        , "</tr>"

        , "</table>"


        , "<h3>Print/Misc. Tab</h3>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "REQUISITION FORMAT CHECKBOX"
        , "</td>"
        , "<td", PRINT_REQ_IND_VAR_STYLE, ">", PRINT_REQ_IND_VAR, "</td>"
        , "</tr>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "REQUISITION FORMAT?"
        , "</td>"
        , "<td", REQUISITION_FORMAT_VAR_STYLE, ">", REQUISITION_FORMAT_VAR, "</td>"
        , "</tr>"

        , "</table>"


        , "<h3>Multum</h3>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "CATALOG CKI"
        , "</td>"
        , "<td>", CATALOG_CKI_VAR, "</td>"
        , "</tr>"

        , "</table>"


        , "<h3>Other</h3>"
        , "<table width='95%'>"

        , "<tr>"
        , '<td style="font-weight: bold; width: 25%">'
        , "CATALOG CODE"
        , "</td>"
        , "<td>", CATALOG_CD_VAR, "</td>"
        , "</tr>"

        , "</table>"



        , "</body>"
        , "</html>"
    )

    ;Send the html text to the window
    set _memory_reply_string = FINALHTML_VAR

end
go