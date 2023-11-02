drop program wh_surgery_form go
create program wh_surgery_form

prompt 
	"Output to File/Printer/MINE" = "MINE"                                           ;* Enter or select the printer or file name t
	, "Ordered After Date..." = "SYSDATE"
	, "Ordered Before Date..." = "SYSDATE"
	, "Choose The Order From Below..." = "Request for Emergency Surgery"
	, ^Only Retrieve orders with this text in the 'Procedure Description"...^ = ^^ 

with OUTDEV, START_DATE_TM, END_DATE_TM, ORDER_NAME, PROCEDURE_SEARCH_TEXT
;, START_DATE_TM, END_DATE_TM ; end date, Control Type= Data Time, Prompt Type: String, Prompt Options: Date and Time

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare PROCEDURE_SEARCH_TEXT_VAR = VC with NoConstant(" "),Protect

SET PROCEDURE_SEARCH_TEXT_VAR = CNVTUPPER($PROCEDURE_SEARCH_TEXT)
SET PROCEDURE_SEARCH_TEXT_VAR = CONCAT("*", PROCEDURE_SEARCH_TEXT_VAR, "*")

SELECT INTO $OUTDEV
    PATIENT = P.NAME_FULL_FORMATTED
	, FIELD = O_E_FI.DESCRIPTION
	, FIELD_ENTRY = O_D.OE_FIELD_DISPLAY_VALUE
	, ORDERED = O.ORIG_ORDER_DT_TM  "DD-MMM-YYYY HH:MM:SS;;D"
    , ORDERED_BY = PR.NAME_FULL_FORMATTED


FROM
    ORDER_DETAIL                O_D
	, ORDERS	                O
    , ORDER_ACTION              O_A
    , PRSNL                     PR
	, ORDER_CATALOG_SYNONYM     O_C_S
    , PERSON                    P
    , ORDER_ENTRY_FIELDS        O_E_FI

PLAN O
	WHERE
    /* Filter update tiome */
    O.ORIG_ORDER_DT_TM BETWEEN
        CNVTDATETIME($START_DATE_TM)
        AND
        CNVTDATETIME($END_DATE_TM)
    AND
    O.ACTIVE_IND = 1;
    AND
    O.ORDER_ID IN
     (
        SELECT O_D_TEMP.ORDER_ID
        FROM ORDER_DETAIL O_D_TEMP
        /* Procedure text input field*/
        WHERE O_D_TEMP.OE_FIELD_ID = 663840.00;SURGPROCTEXT PR
        AND CNVTUPPER(O_D_TEMP.OE_FIELD_DISPLAY_VALUE) = PATSTRING(PROCEDURE_SEARCH_TEXT_VAR)
     )


JOIN O_C_S
    WHERE O_C_S.SYNONYM_ID = O.SYNONYM_ID
    AND
    /* Orderable to Filter for */
    ;"Request for Emergency Surgery"
    ;Request for Anaesthesia Procedure
    O_C_S.MNEMONIC =  $ORDER_NAME

JOIN O_D
    WHERE O_D.ORDER_ID = O.ORDER_ID

/* Order action table to get ordering staff */
JOIN O_A;ORDER_ACTION
    WHERE O_A.ORDER_ID = O.ORDER_ID
    AND
    O_A.ACTION_TYPE_CD = 2534.00;Order
    AND
    O_A.ORDER_DT_TM BETWEEN
        CNVTDATETIME($START_DATE_TM)
        AND
        CNVTDATETIME($END_DATE_TM)

JOIN PR;PRSNL
    WHERE PR.PERSON_ID = O_A.ACTION_PERSONNEL_ID

/* Patients */
JOIN P;PERSON
	WHERE P.PERSON_ID = O.PERSON_ID
    /* Remove Inactive Patients */
    AND P.ACTIVE_IND = 1
    /* Remove Fake 'Test' Patients */
    AND P.NAME_LAST_KEY != "*TESTWHS*"
    /* Remove Ineffective Patients */
    AND P.END_EFFECTIVE_DT_TM > SYSDATE

JOIN O_E_FI; ORDER_ENTRY_FIELDS
    WHERE O_E_FI.OE_FIELD_ID = O_D.OE_FIELD_ID

ORDER BY
	O_D.ORDER_ID
	, O_D.DETAIL_SEQUENCE

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 20

END
GO
