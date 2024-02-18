drop program wh_iron_infusions go
create program wh_iron_infusions

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Filter start date time" = "SYSDATE"
	, "Filter end date time" = "SYSDATE"

with OUTDEV, STA_DATE_TM, END_DATE_TM


SELECT INTO $OUTDEV
	O_I.ORDER_ID
	, O.ORIG_ORDER_DT_TM "dd/mmm/yyyy hh:mm"
	, M_A_E.BEG_DT_TM "dd/mmm/yyyy hh:mm"
	, M_A_E.END_DT_TM "dd/mmm/yyyy hh:mm"
	, M_EVENT_TYPE_DISP = UAR_GET_CODE_DISPLAY(M_A_E.EVENT_TYPE_CD)
	, O.ORDER_MNEMONIC
	, O_I.ORDER_MNEMONIC
	, E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
	, M_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(M_A_E.NURSE_UNIT_CD)
    , E_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
    , ENCOUNTER_NO = E_A.ALIAS
    , PATIENT_URN = P_A.ALIAS
    , ORDERER = PR.NAME_FULL_FORMATTED
	;, FIELD = O_E_FI.DESCRIPTION ; details filled out in the Order Entry Form
	, FIELD_ENTRY = O_D.OE_FIELD_DISPLAY_VALUE

FROM
	ORDER_DETAIL            O_D
	, ORDER_INGREDIENT      O_I
	, ORDERS                O
	, ENCOUNTER             E
	, MED_ADMIN_EVENT       M_A_E
    , PRSNL                 PR
    , PERSON_ALIAS          P_A
    , ENCNTR_ALIAS          E_A
	;, ORDER_ENTRY_FIELDS    O_E_FI

PLAN O_D ; ORDER_DETAIL
	 WHERE
        O_D.ORDER_ID IN; Infusion orders only
        (
            SELECT ORDER_ID
            FROM ORDER_DETAIL
            WHERE
                O_D.OE_FIELD_VALUE = 318173.00 ;"IV Infusion"
                AND
                O_D.UPDT_DT_TM >= CNVTDATETIME($STA_DATE_TM)
        )

JOIN O_I ; ORDER_INGREDIENT
	WHERE O_I.ORDER_ID = O_D.ORDER_ID
        AND O_I.CATALOG_CD IN
            /* Filter for orders with the below in the display key */
            (SELECT CODE_VALUE FROM CODE_VALUE WHERE CODE_SET=200 AND DISPLAY_KEY = "*IRON*" )
        AND O_I.ACTION_SEQUENCE = 1; filter out duplicate rows in this table
        AND O_I.UPDT_DT_TM >= CNVTDATETIME($STA_DATE_TM)


JOIN O ; ORDERS
	WHERE O.ORDER_ID = O_I.ORDER_ID
    AND O.ORIG_ORDER_DT_TM >= CNVTDATETIME($STA_DATE_TM)
    AND O.ORIG_ORDER_DT_TM <= CNVTDATETIME($END_DATE_TM)

JOIN E ; ENCOUNTER
	WHERE E.ENCNTR_ID = O.ENCNTR_ID
    AND E.ACTIVE_IND = 1

JOIN M_A_E ; MED_ADMIN_EVENT
	WHERE M_A_E.ORDER_ID =O_D.ORDER_ID

/* Patient Identifiers such as URN Medicare no etc */
JOIN P_A;PERSON_ALIAS; PATIENT_URN = P_A.ALIAS
    WHERE P_A.PERSON_ID = E.PERSON_ID
    AND
    /* this filters for the UR Number Alias' only */
   	P_A.ALIAS_POOL_CD = 9569589.00
	AND
    /* Effective Only */
	P_A.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
    AND
    /* Active Only */
    P_A.ACTIVE_IND = 1

/* Encounter Identifiers such as the Financial Number */
JOIN E_A;ENCNTR_ALIAS; ENCOUNTER_NO = E_A.ALIAS
    WHERE E_A.ENCNTR_ID = E.ENCNTR_ID
    /*  'FIN/ENCOUNTER/VISIT NBR' from code set 319 */
	AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
	/* active FIN NBRs only */
    AND E_A.ACTIVE_IND = 1
    /* effective FIN NBRs only */
	AND E_A.END_EFFECTIVE_DT_TM > SYSDATE

JOIN PR;PRSNL
    WHERE PR.PERSON_ID = OUTERJOIN(O.STATUS_PRSNL_ID);X.UPDT_ID
    AND PR.ACTIVE_IND = OUTERJOIN(1)

; JOIN O_E_FI; ORDER_ENTRY_FIELDS
;     WHERE O_E_FI.OE_FIELD_ID = O_D.OE_FIELD_ID

ORDER BY
	O_I.ORDER_ID

WITH TIME = 60,
	NOCOUNTER,
	SEPARATOR=" ",
	FORMAT

end
go
