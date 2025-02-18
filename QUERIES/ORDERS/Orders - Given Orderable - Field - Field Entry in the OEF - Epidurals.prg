drop program wh_epidural_requests go
create program wh_epidural_requests

/*
Ticket No: SR930296 using code from SR92306

Programmer: Jason Whittle

DATE: Febuary 2025

DESCRIPTION:
This aims to show Epidural Requests, Identified by orders for "Consult to Medical Specialty (MO Use Only)"
"Epidural Service" in the "Service Selection in OEF" field with "Reason for Consult freetext pulled in as a column

SETTINGS
Prompts:
    OUTDEV (checkboxes to turn on)
        GENERAL
            HIDE LABEL
            PROMPT ONLY
        OUTPUT
            Hide Browser Button
            Disallow Freetext Devices

    ORDER_AFTER_DT AND ORDER_BEFORE_DT
        GENERAL
            COTROL TYPE = DATE/TIME
        DATE/TIME
            DATE & TIME
        CALCULATE DEFAULT
            CURRENT DATE/TIME 'CHECKED'
            DAY: -30
*/

prompt
	"Output to File/Printer/MINE" = "MINE"         ;* Enter or select the printer or file name to send this report to.
	, "Ordered After Date and Time" = "SYSDATE"
	, "Ordered Before Date and Time" = "SYSDATE"

with OUTDEV, ORDER_AFTER_DT, ORDER_BEFORE_DT

SELECT INTO $OUTDEV
      O.ORDER_ID
    , ORDERED = UAR_GET_CODE_DISPLAY (O.CATALOG_CD)
    , SERVICE_SELECTION_IN_OEF = "EPIDURAL SERVICE" ; This is filtered in the code
    , ORDER_STATUS = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD)
    , PATIENT_URN = P_A.ALIAS
    , PATIENT_DOB = DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY")
    , AGE_AT_ORDER = CNVTAGE(P.BIRTH_DT_TM, O.ORIG_ORDER_DT_TM,0)
    , PATIENT_SEX = UAR_GET_CODE_DISPLAY(P.SEX_CD)
    , ENCOUNTER_FIN = E_A.ALIAS
    , REASON_FOR_CONSULT_FREETEXT = O_D.OE_FIELD_DISPLAY_VALUE
    , ORDERED_DATE = FORMAT(O.ORIG_ORDER_DT_TM,  "DD-MMM-YYYY")
    , ORDERED_TIME = FORMAT(O.ORIG_ORDER_DT_TM,  "HH:MM:SS;;D")
    , FACILITY = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
    , NURSE_UNIT =
        IF(ELH.LOC_NURSE_UNIT_CD > 0) UAR_GET_CODE_DISPLAY(ELH.LOC_NURSE_UNIT_CD)
        ELSE UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
        ENDIF
    , ORDERED_BY = PR.NAME_FULL_FORMATTED
    , DISPLAY_L = O_A.CLINICAL_DISPLAY_LINE
FROM
    ORDER_DETAIL    O_D
    , ORDERS    O
    , ORDER_ACTION  O_A
    , PRSNL PR
    , PERSON    P
    , PERSON_ALIAS  P_A
    , ENCOUNTER E
    , ENCNTR_ALIAS  E_A
    ;, ORDER_ENTRY_FIELDS    O_E_FI
    , ENCNTR_LOC_HIST   ELH
    ; , ORDER_CATALOG_SYNONYM O_C_S
PLAN O
    WHERE
    ;Filter update time
    O.ORIG_ORDER_DT_TM > CNVTDATETIME($ORDER_AFTER_DT)
    AND O.ORIG_ORDER_DT_TM < CNVTDATETIME($ORDER_BEFORE_DT)
    AND O.ACTIVE_IND = 1 ;Active Only
    AND O.CATALOG_CD = 90228280.00 ; Primary Code = "Consult to Medical Specialty (MO Use Only)"
    AND O.ORDER_ID IN ; Orders where FIELD and FIELD Entry are the following
        (
            SELECT
                O_D_TEMP.ORDER_ID
            FROM
                ORDER_DETAIL O_D_TEMP
                /* Procedure text input field*/
            WHERE
                O_D_TEMP.OE_FIELD_ID = 633614.00 ;CONSULTMEDSERVICE
                ;AND O_D_TEMP.OE_FIELD_DISPLAY_VALUE = "EPIDURAL SERVICE"
                AND O_D_TEMP.OE_FIELD_VALUE = 116420686 ;EPIDURAL SERVICE
        )
JOIN O_D ; ORDER_DETAIL
    WHERE O_D.ORDER_ID = OUTERJOIN(O.ORDER_ID)
    ;MODIFIED TO ONLY SHOW "REASON FOR CONSULT FREETEXT" AS REQUESTED BY CUONG 18/6/24
    AND O_D.OE_FIELD_ID = OUTERJOIN(79849885) ;REASON FOR CONSULT FREETEXT
    ;ORDER ACTION TABLE TO GET ORDERING STAFF

JOIN O_A;ORDER_ACTION
    WHERE
            O_A.ORDER_ID = OUTERJOIN(O.ORDER_ID)
        AND O_A.ACTION_TYPE_CD = OUTERJOIN(2534.00);Order


JOIN PR;PRSNL
    WHERE
        PR.PERSON_ID = OUTERJOIN(O_A.ACTION_PERSONNEL_ID)
        AND PR.ACTIVE_IND = OUTERJOIN(1)
        AND PR.END_EFFECTIVE_DT_TM > OUTERJOIN(SYSDATE)

JOIN P;PERSON
    WHERE P.PERSON_ID = O.PERSON_ID
    /* Remove Inactive Patients */
    AND P.ACTIVE_IND = 1
    /* Remove Fake 'Test' Patients */
    AND P.NAME_LAST_KEY != "TESTWHS"
    /* Remove Ineffective Patients */
    AND P.END_EFFECTIVE_DT_TM > SYSDATE

JOIN P_A;PERSON_ALIAS
    WHERE P_A.PERSON_ID = O.PERSON_ID
    AND
    ;this filters for the UR Number Alias' only
    P_A.ALIAS_POOL_CD = 9569589.00
    AND
    ;Effective Only
    P_A.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
    AND
    ;Active Only
    P_A.ACTIVE_IND = 1

JOIN E;ENCOUNTER
    WHERE E.ENCNTR_ID = O.ENCNTR_ID
    AND E.ACTIVE_IND = 1

JOIN E_A;ENCNTR_ALIAS
    WHERE E_A.ENCNTR_ID = O.ENCNTR_ID
    /*  'FIN/ENCOUNTER/VISIT NBR' from code set 319 */
    AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
    /* active FIN NBRs only */
    AND E_A.ACTIVE_IND = 1
    /* effective FIN NBRs only */
    AND E_A.END_EFFECTIVE_DT_TM > SYSDATE

JOIN ELH ;ENCNTR_LOC_HIST
    WHERE ELH.ENCNTR_ID = OUTERJOIN(O.ENCNTR_ID)
    AND ELH.ACTIVE_IND = OUTERJOIN(1)   ; to remove inactive rows that seem to appear for unknown reason(s)
    AND ELH.PM_HIST_TRACKING_ID > OUTERJOIN(0)  ; to remove duplicate row that seems to occur at discharge
    AND ELH.BEG_EFFECTIVE_DT_TM < OUTERJOIN(O.ORIG_ORDER_DT_TM) ; encounter location began before order was placed
    AND ELH.END_EFFECTIVE_DT_TM >  OUTERJOIN(O.ORIG_ORDER_DT_TM)    ; encounter location ended after order was placed

ORDER BY
      O_D.ORDER_ID
    , O_D.DETAIL_SEQUENCE

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 60

END
GO