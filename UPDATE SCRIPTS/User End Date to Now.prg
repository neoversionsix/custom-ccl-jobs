drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*
This script end dates users by the given person id's
*/

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

UPDATE INTO PRSNL P
SET
    P.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_ID = REQINFO->UPDT_ID
    , P.UPDT_CNT = P.UPDT_CNT + 1
WHERE
    P.PERSON_ID IN (
        11660810
        , 11661054
        , 11661684
        , 11660682
        , 11655263
        , 11658267
        , 11661574
        , 11660307
        , 11661226
        , 11662781
        , 14221904
        , 11659011
    )
END
GO