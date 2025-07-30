drop program WH_IMMUNISATIONS go
create program WH_IMMUNISATIONS

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Filter start date time" = "SYSDATE"
	, "Filter end date time" = "SYSDATE"

with OUTDEV, STA_DATE_TM, END_DATE_TM


SELECT INTO $OUTDEV
        PATIENT = P.NAME_FULL_FORMATTED
    ,   PATIENT_URN = P_A.ALIAS
    ,   ADMINISTERED = UAR_GET_CODE_DISPLAY(C_E.CATALOG_CD)
    ,   BATCH_LOT_NUMBER = C_M_R.SUBSTANCE_LOT_NUMBER
    ,   EXPIRY_DATE = C_M_R.SUBSTANCE_EXP_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
    ,   MANUFACTURER = UAR_GET_CODE_DISPLAY(C_M_R.SUBSTANCE_MANUFACTURER_CD)
    ,   COMPLETED = C_E.PERFORMED_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
    ,   ENCOUNTER_NO = E_A.ALIAS
    ,   LAST_HOSPITAL_FOR_ENCOUNTER = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
    ,   LAST_WARD_FOR_ENCOUNTER = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
	,   ROUTE = UAR_GET_CODE_DISPLAY(C_M_R.ADMIN_ROUTE_CD)
	,   SITE = UAR_GET_CODE_DISPLAY(C_M_R.ADMIN_SITE_CD)
    ,   DOSAGE = C_M_R.ADMIN_DOSAGE
    ,   DOSAGE_UNIT = UAR_GET_CODE_DISPLAY(C_M_R.DOSAGE_UNIT_CD)


FROM
        CLINICAL_EVENT      C_E
    ,   ENCOUNTER           E
    ,   ENCNTR_ALIAS        E_A
    ,   PERSON              P
    ,   PERSON_ALIAS        P_A
    ,   CE_MED_RESULT       C_M_R

PLAN C_E;
    WHERE
    /* "Immunization" Filter */
    C_E.EVENT_CLASS_CD = 228
    /* Viewable (not reverted etc) */
    AND C_E.VIEW_LEVEL = 1
    /* Time Filter */
    AND C_E.PERFORMED_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
    /* Determines whether the event record has been authenticated (removes duplicates) and 'patient refused rows*/
    AND C_E.AUTHENTIC_FLAG = 1
    /* "Auth (Verified)" Result Status, This effectively removes duplictes*/
    AND C_E.RESULT_STATUS_CD = 25.00

; JOIN O;ORDERS
;     WHERE
;     O.ORDER_ID = C_E.ORDER_ID
;     /* Completed Orders */
;     AND O.ORDER_STATUS_CD = 2543.00

JOIN E;ENCOUNTER
    WHERE
    E.ENCNTR_ID = C_E.ENCNTR_ID
    /* Not "DEMO 1 HOSPITAL" Removes Fake Data From The Demo Hospital */
    AND E.LOC_FACILITY_CD != 4038465.00

JOIN P;PERSON
	WHERE
    P.PERSON_ID = C_E.PERSON_ID
    /* Removes Fake Test Patients */
    AND P.NAME_LAST_KEY != "*TESTWHS*"

JOIN C_M_R; CE_MED_RESULT
    WHERE
    C_M_R.EVENT_ID = OUTERJOIN(C_E.EVENT_ID)

JOIN P_A;PERSON_ALIAS
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

JOIN E_A;ENCNTR_ALIAS;
    WHERE E_A.ENCNTR_ID = E.ENCNTR_ID
	AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077	; 'FIN NBR' from code set 319
	AND E_A.ACTIVE_IND = 1	; active FIN NBRs only
	AND E_A.END_EFFECTIVE_DT_TM > SYSDATE	; effective FIN NBRs only


WITH
    TIME = 30
    , FORMAT

end
go
