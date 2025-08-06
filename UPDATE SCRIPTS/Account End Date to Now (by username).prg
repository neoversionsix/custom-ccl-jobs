; ACCOUNT END DATE TO NOW FOR _USERNAME_
UPDATE INTO PRSNL P
    SET
        P.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
        , P.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
        , P.UPDT_ID = REQINFO->UPDT_ID
        , P.UPDT_CNT = P.UPDT_CNT + 1
    WHERE
        P.USERNAME = "_USERNAME_" ; <---COLUMN HEADER NAME FOR GENERATOR
        ; Only End date if not already end dated
        AND P.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
;------------------------------------------------------------------------