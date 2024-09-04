; This is for finding equivalent pbs items with different mappings
; we want to identify these because pbs items with the same primary/brand/form
; should always have the exact same synonyms mapped to them.

; IN DEVELOPMENT!!!!!!!!!!!!!!

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"

with OUTDEV

;USER INPUT VARIABLES
    DECLARE PRIMARY_NAME_VAR = VC with NoConstant("*ibuprofen*"),Protect ; EDIT THIS!!!!!!!

;VARIABLES FROM THE DB
    DECLARE ACTIVE_VAR = I2 with NoConstant(0),Protect
    DECLARE ORDERS_COUNT_VAR = F8 with NoConstant(0.00),Protect
    DECLARE PRINT_REQ_IND_VAR = I2 with NoConstant(0),Protect
    DECLARE PRIMARY_MNEMONIC_VAR = VC with NoConstant(" "),Protect

;HTML VARIABLES
    DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
    DECLARE CSS_VAR = VC with NoConstant(" "),Protect
    DECLARE ACTIVE_VAR_STYLE = VC with NoConstant(""),Protect

; Query from Order_Catalog TABLE
    SELECT INTO "NL:"
        ACTIVE                  = OC.ACTIVE_IND
        , PRIMARY_MNEMONIC      = OC.PRIMARY_MNEMONIC
    FROM
        ORDER_CATALOG   OC
    WHERE
        OC.PRIMARY_MNEMONIC = PATSTRING(PRIMARY_NAME_VAR)
    HEAD REPORT ; Setting varibles using info retrieved from the Database in SELECT Seciton
        ACTIVE_VAR                  = ACTIVE
        PRIMARY_MNEMONIC_VAR        = PRIMARY_MNEMONIC
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


    SET FINALHTML_VAR = BUILD2(
        "<html>"
        , "<head>"
        , "<title>Pharmacy Medication Audit</title>"
        , "<style>"
        , "table, th, td {"
        , "border: 1px solid black;"
        , "border-collapse: collapse;"
        , "}"
        , "</style>"
        , "</head>"
        , "</tr>"
        , "</table>"
        , "</body>"
        , "</html>"
    )

    ;Send the html text to the window
    set _memory_reply_string = FINALHTML_VAR

end
go