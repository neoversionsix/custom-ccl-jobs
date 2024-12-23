drop program wh_med_administrations2 go
create program wh_med_administrations2
/*
Programmer: Jason Whittle
Created: 16 Nov 2023
Updated: 18 Sep 2024
Use: Medication Administrations (including surgery)
 */

prompt
	"Output to File/Printer/MINE" = "MINE"                           ;* Enter or select the printer or file name to send this repo
	, "Administered After..." = "SYSDATE"
	, "Administered Before..." = "SYSDATE"
	, "Patient URN (leave blank if you don't want to filter)" = ""

with OUTDEV, START_DATE_TIME, END_DATE_TIME, URN

DECLARE URN_VAR = VC WITH NOCONSTANT(" "),PROTECT

SET URN_VAR = $URN
IF (URN_VAR = "")
	SET URN_VAR = "*"
	ELSE
	SET URN_VAR = CONCAT("*", URN_VAR, "*")
ENDIF

SELECT DISTINCT INTO $OUTDEV
	PATIENT = P.NAME_FULL_FORMATTED
	, PATIENT_URN = P_A.ALIAS
	, ENCOUNTER_ = E_A.ALIAS
	, EVENT_TYPE =
        IF(M_A_E.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(M_A_E.EVENT_TYPE_CD); EVENT TYPE
        ELSE "SURGINET"
        ENDIF
    , INTERFACE = ; POWERCHART OR SURGINET?
        IF (M_A_E.MED_ADMIN_EVENT_ID>0) "POWERCHART"
        ELSE "SURGINET"
        ENDIF
	, ITEM = O.ORDER_MNEMONIC
    , EVENT_TAG = C.EVENT_TAG
	, ORDERED_TIME = FORMAT(O.ORIG_ORDER_DT_TM, "YYYY-MM-DD HH:MM:SS")
    ;O.ORIG_ORDER_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
    ;FORMAT(O.ORIG_ORDER_DT_TM, "YYYY-MM-DD HH:MM:SS")
	, ADMINISTERED_BEG =
        IF(M_A_E.BEG_DT_TM>0) FORMAT(M_A_E.BEG_DT_TM, "YYYY-MM-DD HH:MM:SS")
        ELSE FORMAT(C.EVENT_START_DT_TM, "YYYY-MM-DD HH:MM:SS")
        ENDIF
	, ADMINISTERED_END = FORMAT(M_A_E.END_DT_TM, "YYYY-MM-DD HH:MM:SS")
	, UNIT =
        IF (M_A_E.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(M_A_E.NURSE_UNIT_CD); unit
        ELSE UAR_GET_CODE_DISPLAY(E_L_H.LOC_NURSE_UNIT_CD)
        ENDIF
	, POSITION =
        IF (M_A_E.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(M_A_E.POSITION_CD) ; direct position form med admin table
        ELSE UAR_GET_CODE_DISPLAY(PR.POSITION_CD) ; position from prsnl table if a surgery administration
        ENDIF
	, SERVICE = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , ENCOUNTER_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
    , ADMINISTERED_BY = PR.NAME_FULL_FORMATTED
    , ORDERED_BY = PR_2.NAME_FULL_FORMATTED

FROM
    ORDER_ACTION          	O_A
    , ORDER_ACTION          O_A_2
	, ORDERS                O
	, ENCOUNTER             E
	, MED_ADMIN_EVENT       M_A_E
    , PRSNL                 PR
    , PRSNL                 PR_2
    , PERSON				P
    , PERSON_ALIAS          P_A
    , ENCNTR_ALIAS          E_A
    , SA_MEDICATION_ADMIN   S
    , CLINICAL_EVENT        C
    , ENCNTR_LOC_HIST       E_L_H

PLAN O_A ; ORDER_ACTION
    WHERE
    O_A.ORDER_STATUS_CD IN(2548, 2543) 	; In process or complete orders only
    AND O_A.ORDER_CONVS_SEQ = 1 ; removes duplicates on this table
    AND O_A.ACTION_DT_TM >= CNVTDATETIME($START_DATE_TIME)
    AND O_A.ACTION_DT_TM <= CNVTDATETIME($END_DATE_TIME)

JOIN PR;PRSNL
    ; This is to get the person completing/administering the medication
    WHERE PR.PERSON_ID = OUTERJOIN(O_A.ACTION_PERSONNEL_ID);X.UPDT_ID
    AND PR.ACTIVE_IND = OUTERJOIN(1)

/* Joining Order Action table again to get the original ordering personell */
JOIN O_A_2 ; ORDER_ACTION
    WHERE O_A_2.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)
    AND O_A_2.ACTION_TYPE_CD = OUTERJOIN(2534); New Order

JOIN PR_2;PRSNL
    WHERE PR_2.PERSON_ID = OUTERJOIN(O_A_2.ACTION_PERSONNEL_ID);X.UPDT_ID
    AND PR_2.ACTIVE_IND = OUTERJOIN(1)

JOIN O ; ORDERS
	WHERE O.ORDER_ID = O_A.ORDER_ID
    /*Pharmacy Catalog only */
    AND O.CATALOG_TYPE_CD = 2516.00;

JOIN E ; ENCOUNTER
	WHERE E.ENCNTR_ID = O.ENCNTR_ID
    AND E.ACTIVE_IND = 1
    /* Not "DEMO 1 HOSPITAL" Removes Fake Data From The Demo Hospital */
    AND E.LOC_FACILITY_CD != 4038465.00

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
    AND
    P_A.ALIAS = PATSTRING(URN_VAR) ; ENTER URN!

/* Patients */
JOIN P;PERSON
	WHERE P.PERSON_ID = E.PERSON_ID
    /* Remove Inactive Patients */
    AND P.ACTIVE_IND = 1
    /* Remove Fake 'Test' Patients */
    ;AND P.NAME_LAST_KEY != "*TESTWHS*"
    /* Remove Ineffective Patients */
    AND P.END_EFFECTIVE_DT_TM > SYSDATE

/* Encounter Identifiers such as the Financial Number */
JOIN E_A;ENCNTR_ALIAS; ENCOUNTER_NO = E_A.ALIAS
    WHERE E_A.ENCNTR_ID = E.ENCNTR_ID
    /*  'FIN/ENCOUNTER/VISIT NBR' from code set 319 */
	AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
	/* active FIN NBRs only */
    AND E_A.ACTIVE_IND = 1
    /* effective FIN NBRs only */
	AND E_A.END_EFFECTIVE_DT_TM > SYSDATE

JOIN M_A_E ;MED_ADMIN_EVENT
    WHERE M_A_E.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)

JOIN S ;SA_MEDICATION_ADMIN
    WHERE
        S.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)
        AND S.ORDER_ID > OUTERJOIN(0)
        AND S.EVENT_ID > OUTERJOIN(0)
        AND S.ACTIVE_IND = OUTERJOIN(1)

JOIN C
    WHERE
        C.ORDER_ID = OUTERJOIN(S.ORDER_ID)
	    AND C.VIEW_LEVEL = OUTERJOIN(1)

JOIN	E_L_H ; ENCNTR_LOC_HIST
    WHERE E_L_H.ENCNTR_ID = OUTERJOIN(C.ENCNTR_ID) ; join on encounter
    ; Look at location history after the medication administered time filter
    AND E_L_H.UPDT_DT_TM > OUTERJOIN(CNVTDATETIME($START_DATE_TIME))
    AND E_L_H.ACTIVE_IND = OUTERJOIN(1)	; remove inactive rows
    AND E_L_H.BEG_EFFECTIVE_DT_TM < OUTERJOIN(C.EVENT_START_DT_TM); location began before administered
    AND E_L_H.END_EFFECTIVE_DT_TM > OUTERJOIN(C.EVENT_START_DT_TM); location ended after administered

ORDER BY
    O.PERSON_ID
	, O.ORDER_ID

WITH TIME = 200,
	NOCOUNTER,
	SEPARATOR=" ",
	FORMAT

end
go