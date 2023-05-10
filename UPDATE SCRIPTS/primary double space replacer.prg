drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*

****IN DEVELOPMENT********

This script finds accounts on the person table
where the end date > year 2100 and then changes
the end date of those accounts to 31-DEC-2100 23:59:59.00

this fixes the issue where opening a users account in
hnauser causes hnauser to immediately close
*/

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

UPDATE INTO PERSON P
SET
    P.END_EFFECTIVE_DT_TM = CNVTDATETIME("31-DEC-2100")
    , P.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P.UPDT_ID = REQINFO->UPDT_ID
    , P.UPDT_CNT = P.UPDT_CNT + 1
WHERE
    P.END_EFFECTIVE_DT_TM > CNVTDATETIME("31-DEC-2100 23:59:59.00")

END
GO