drop program WHS_bulk_updates  go
create program WHS_bulk_updates


prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

UPDATE INTO PERSON P
SET
    P.ACTIVE_IND = 0
    , P.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_ID = REQINFO->UPDT_ID
    , P.UPDT_CNT = P.UPDT_CNT + 1
WHERE
    P.PERSON_ID IN
        (
        12851473.00
        , 13390656.00
        , 13530565.00
        , 13855532.00
        , 13922283.00
        , 13959090.00
        )

END
GO




/* TESTING SCRIPT BELOW */

SELECT
	P.NAME_FULL_FORMATTED
	, P.PERSON_ID
	, P.ACTIVE_IND
	, PA.ALIAS

FROM
	PERSON   P
	, PERSON_ALIAS   PA

PLAN PA WHERE PA.PERSON_ID IN
        (
        12851473.00
        , 13390656.00
        , 13530565.00
        , 13855532.00
        , 13922283.00
        , 13959090.00
        )

JOIN P WHERE P.PERSON_ID = PA.PERSON_ID

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 5
