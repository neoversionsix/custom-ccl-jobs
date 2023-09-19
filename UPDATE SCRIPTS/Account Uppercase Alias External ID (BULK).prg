/* CHECKER */
SELECT
P_A.ALIAS
FROM
PERSON_ALIAS P_A
WHERE
P_A.ALIAS != CNVTUPPER(P_A.ALIAS) ; not uppercase
WITH TIME=10, FORMAT



/* UPDATE SCRIPT */
UPDATE INTO PRSNL_ALIAS P_A

SET
    P_A.ALIAS = CNVTUPPER(P_A.ALIAS)
    , P_A.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P_A.UPDT_ID = REQINFO->UPDT_ID
    , P_A.UPDT_CNT = P_A.UPDT_CNT + 1

WHERE
; This Where clause will target all external ID's that are not uppercase
        P_A.ALIAS_POOL_CD = 683991.00 ; External ID alias only
        AND
        P_A.ALIAS != CNVTUPPER(P_A.ALIAS) ; not uppercase
