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





; THIS IS JUST FOR CHECKING AFTERWARDS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT
	P.USERNAME
	, P.END_EFFECTIVE_DT_TM "YYYY-MM-DD HH:MM:SS"
	, P.UPDT_DT_TM "YYYY-MM-DD HH:MM:SS"

FROM
	PRSNL   P
WHERE
	P.UPDT_DT_TM > CNVTLOOKBEHIND("1,H") ;was updated in the last hour
	AND P.UPDT_ID = REQINFO->UPDT_ID ; Was updated by the person running this script

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10
