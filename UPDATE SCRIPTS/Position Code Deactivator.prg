drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*
Notes:
Deactivates zz positions
*/

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts below---------------------------
UPDATE INTO CODE_VALUE C_V
SET
    C_V.ACTIVE_IND = 0 ; Inactivate the option
    , C_V.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE,CURTIME3) ; END DATE THE OPTION
    /* Update Trail Updates Below */
    , C_V.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , C_V.UPDT_ID = REQINFO->UPDT_ID
    , C_V.UPDT_CNT = C_V.UPDT_CNT + 1
WHERE
; This Where clause will target all zz positions
        C_V.CODE_SET = 88; POSITIONS
        AND C_V.DISPLAY_KEY = "ZZ*"
;------------------------------------------------------
END
GO

/*
;PRE RUN script
SELECT
    POSITION = C_V.DISPLAY
    , C_V.DESCRIPTION
	, C_V.DEFINITION
	, C_V.DISPLAY_KEY
    , C_V.CODE_VALUE
    , C_V.ACTIVE_IND
    , END_DATE =FORMAT(C_V.END_EFFECTIVE_DT_TM, "DD-MMM-YYYY")

FROM
	CODE_VALUE   C_V

WHERE
	C_V.CODE_SET = 88; POSITIONS
    AND C_V.DISPLAY_KEY = "ZZ*"
	;AND C_V.ACTIVE_IND = 1; ACTIVE ONLY

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=5

______________________________________________________________________

;POST RUN SCRIPT
SELECT
    POSITION = C_V.DISPLAY
    , C_V.DESCRIPTION
	, C_V.DEFINITION
	, C_V.DISPLAY_KEY
    , C_V.CODE_VALUE
    , C_V.ACTIVE_IND
    , END_DATE =FORMAT(C_V.END_EFFECTIVE_DT_TM, "DD-MMM-YYYY")
    , C_V.UPDT_ID
    , UPDT_DATE = FORMAT(C_V.UPDT_DT_TM, "DD-MMM-YYYY")

FROM
	CODE_VALUE   C_V

WHERE
	C_V.UPDT_ID = REQINFO->UPDT_ID ;Current user
    AND C_V.CODE_SET = 88; POSITIONS

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=5

 */