SELECT
/*
LIST OF CURRENT PATIENTS
 */
    PATIENT_URN = P_A.ALIAS
    , PATIENT_NAME = P.NAME_FULL_FORMATTED
    , E.ENCNTR_ID

FROM
    ENCOUNTER       E
    , PERSON        P
    , PERSON_ALIAS  P_A


PLAN E;ENCOUNTER
    WHERE

        ; Current Patients TIME FILTERS
            (;DEPARTED IN THE FUTURE OR NEVER AT ALL
                E.DEPART_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
                OR
                E.DISCH_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
                OR
                (E.DEPART_DT_TM IS NULL AND E.DISCH_DT_TM IS NULL)
            )
            AND
            (; TURNED UP IN THE PAST
                E.ARRIVE_DT_TM < CNVTDATETIME(CURDATE, CURTIME3)
                OR
                E.REG_DT_TM < CNVTDATETIME(CURDATE, CURTIME3)
            )
            ; Turned up at most 2 years ago
            AND E.ARRIVE_DT_TM > cnvtlookbehind("2,Y")


        ; ARRIVE TIME FILTER
;       and E.ARRIVE_DT_TM > CNVTDATETIME("01-Jan-2018 00:00:00.00")

        ; PATIENT TYPE FILTER
        ; E.ENCNTR_TYPE_CD = 309308 ; Only inpatient encounters

JOIN P;PERSON
	WHERE P.PERSON_ID = E.PERSON_ID
    AND P.ACTIVE_IND = 1
    AND P.NAME_LAST_KEY != "*TESTWHS*"
    AND P.END_EFFECTIVE_DT_TM > SYSDATE

JOIN P_A;PERSON_ALIAS
	WHERE P_A.PERSON_ID = E.PERSON_ID
	AND
	P_A.ALIAS_POOL_CD = 9569589 ; URN ALIAS ONLY
    AND
    P_A.ACTIVE_IND = 1
    AND
    P_A.END_EFFECTIVE_DT_TM > SYSDATE

ORDER BY
    E.ENCNTR_ID

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120