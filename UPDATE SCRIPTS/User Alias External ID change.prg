UPDATE INTO PRSNL_ALIAS P
SET
    P.ALIAS = CNVTUPPER(P.ALIAS) 
    , P.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_ID = REQINFO->UPDT_ID
    , P.UPDT_CNT = P.UPDT_CNT + 1

WHERE
; This Where clause will target all external ID's that are not uppercase
        P.ALIAS_POOL_CD = 683991.00 ; External ID alias only
        AND
        P.ALIAS != CNVTUPPER(P.ALIAS) ; not uppercase