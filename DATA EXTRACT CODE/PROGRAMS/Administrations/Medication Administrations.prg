drop program wh_med_administrations2 go
create program wh_med_administrations2

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Administered After..." = "SYSDATE"
	, "Administered Before..." = "SYSDATE"

with OUTDEV, START_DATE_TIME, END_DATE_TIME


SELECT INTO $OUTDEV
	EVENT_BEG_TIME = M_A_E.BEG_DT_TM "dd/mmm/yyyy hh:mm"
    , M_A_E.END_DT_TM "dd/mmm/yyyy hh:mm"
    , ENCOUNTER_NO = E_A.ALIAS
    , PATIENT_URN = P_A.ALIAS
    , ORDER_ID = O.ORDER_ID
    , ITEM = O.ORDER_MNEMONIC
    , ITEM_INGREDIENT = O_I.ORDER_MNEMONIC
	, EVENT_TYPE = UAR_GET_CODE_DISPLAY(M_A_E.EVENT_TYPE_CD); evenT TYPE
	, UNIT = UAR_GET_CODE_DISPLAY(M_A_E.NURSE_UNIT_CD); unit
	, POSITION = UAR_GET_CODE_DISPLAY(M_A_E.POSITION_CD) ; POSITION
	, ORDERED_TIME = O.ORIG_ORDER_DT_TM "dd/mmm/yyyy hh:mm"
	, SERVICE = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , ENCOUNTER_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
    , ORDERER = PR.NAME_FULL_FORMATTED
	;, FIELD = O_E_FI.DESCRIPTION ; details filled out in the Order Entry Form
	; , FIELD_ENTRY = O_D.OE_FIELD_DISPLAY_VALUE

FROM
	; ORDER_DETAIL            O_D
    ORDER_ACTION          O_A
	; , ORDER_INGREDIENT      O_I
	, ORDERS                O
	, ENCOUNTER             E
	, MED_ADMIN_EVENT       M_A_E
    , PRSNL                 PR
    , PERSON_ALIAS          P_A
    , ENCNTR_ALIAS          E_A
	;, ORDER_ENTRY_FIELDS    O_E_FI

PLAN
	M_A_E
    WHERE
;	M_A_E.BEG_DT_TM > CNVTLOOKBEHIND ("1,H")
;	AND
	M_A_E.EVENT_TYPE_CD !=     4093095.00	;Not Administered/Task Purged
    AND M_A_E.BEG_DT_TM >= CNVTDATETIME($START_DATE_TIME)
    AND M_A_E.BEG_DT_TM <= CNVTDATETIME($END_DATE_TIME)



JOIN O_A ; ORDER_ACTION
    WHERE O_A.ORDER_ID = M_A_E.ORDER_ID
    AND O_A.ACTION_TYPE_CD = 2534.00	;Order
    ;AND O_A.ACTION_SEQUENCE = 1 ; get first action sequence only
    AND O_A.ORDER_CONVS_SEQ = 1 ; removes duplicates on this table


JOIN O ; ORDERS
	WHERE O.ORDER_ID = O_A.ORDER_ID
    ; AND O.ORIG_ORDER_DT_TM >= CNVTDATETIME("25-OCT-2023")
    ; AND O.ORIG_ORDER_DT_TM <= CNVTDATETIME("30-OCT-2023")

JOIN E ; ENCOUNTER
	WHERE E.ENCNTR_ID = O.ENCNTR_ID
    AND E.ACTIVE_IND = 1


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
    /* Patient URN */
;    AND
;    P_A.ALIAS = "1599017" ; ENTER URN!!!!!!!!!!!!!!!!!!!!

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
    WHERE PR.PERSON_ID = OUTERJOIN(O_A.ACTION_PERSONNEL_ID);X.UPDT_ID
    AND PR.ACTIVE_IND = OUTERJOIN(1)

; JOIN O_E_FI; ORDER_ENTRY_FIELDS
;     WHERE O_E_FI.OE_FIELD_ID = O_D.OE_FIELD_ID

ORDER BY
	O.ORDER_ID

WITH TIME = 10,
	NOCOUNTER,
	SEPARATOR=" ",
	FORMAT

end
go