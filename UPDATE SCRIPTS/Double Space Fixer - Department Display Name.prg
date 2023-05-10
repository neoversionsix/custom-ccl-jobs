drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*

****IN DEVELOPMENT********

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
    P.CATLOG_CD IN(
          152000067
        , 151999209
        , 151999233
        , 151999441
        , 151999543
        , 152000239
        , 151999243
        , 152004607
        , 152004759
        , 152004391
        , 152005459
        , 152004957
        , 151885353
        , 152004283
        , 152005467
        , 152004605
        , 152031673
        , 152005101
        , 152007305
        , 152002205
        , 152002265
        , 152001359
        , 152002315
        , 152030929
        , 152031047
    )

END
GO


