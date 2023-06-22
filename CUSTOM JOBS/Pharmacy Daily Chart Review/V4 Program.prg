DROP PROGRAM TESTING_QUERY_88 GO
CREATE PROGRAM TESTING_QUERY_88

PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "START TIME" = "SYSDATE"
	, "END TIME" = "SYSDATE"
WITH OUTDEV, STA_DATE_TM, END_DATE_TM
SELECT INTO $OUTDEV
        ITEM = "Pharmacy Daily Chart Review"
    ,   COMPLETED_AT = C_E.PERFORMED_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
    ,   PATIENT = P.NAME_FULL_FORMATTED
    ,   PATIENT_URN = P_A.ALIAS
    ,   COMPLETED_BY = PR.NAME_FULL_FORMATTED
    ,   ENCOUNTER_NO = E_A.ALIAS
    ,   LAST_HOSPITAL_FOR_ENCOUNTER = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
    ,   LAST_WARD_FOR_ENCOUNTER = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
FROM
        CLINICAL_EVENT          C_E
    ,   ENCOUNTER               E
    ,   ENCNTR_ALIAS            E_A
    ,   PERSON                  P
    ,   PERSON_ALIAS            P_A
    ,   PRSNL                   PR
PLAN C_E;CLINICAL_EVENT
    WHERE
    /* Viewable (not reverted etc) */
    C_E.VIEW_LEVEL = 1
    /* Determines whether the event record has been authenticated (removes duplicates) and 'patient refused rows*/
    AND C_E.AUTHENTIC_FLAG = 1
    /* "Auth (Verified)" Result Status, This effectively removes duplictes*/
    AND C_E.RESULT_STATUS_CD = 25.00
    /* Time Filter */
    AND C_E.PERFORMED_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
    /* 'Daily Pharmacy Review' Catalog filter */
    AND C_E.CATALOG_CD = 87786086
    /* 'Done' Event Filter */
    AND C_E.EVENT_CLASS_CD = 225.00
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
    /* 'FIN NBR' from code set 319 */
	AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
    /* active FIN NBRs only */
	AND E_A.ACTIVE_IND = 1
    /* effective FIN NBRs only */
	AND E_A.END_EFFECTIVE_DT_TM > SYSDATE
JOIN PR;PRSNL
    WHERE PR.PERSON_ID = C_E.PERFORMED_PRSNL_ID
ORDER BY
 C_E.PERFORMED_DT_TM
WITH
    TIME = 120
    , FORMAT
    , SEPERATOR = " "

END
GO