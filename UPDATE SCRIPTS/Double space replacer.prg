declare DEPT_DISP_NAME_VAR = VC with Protect

with OUTDEV
 
;insert update scripts here

/*
****IN DEVELOPMENT********
*/
; UPDATE SCRIPT START FOR swapme123
UPDATE INTO ORDER_CATALOG O_C
SET
    O_C.DEPT_DISPLAY_NAME = (
        REPLACE(
            (SELECT
                O_C_2.DEPT_DISPLAY_NAME
            FROM
                ORDER_CATALOG O_C_2
            WHERE
                O_C_2.CATALOG_CD = swapme123
            )
            , "  "  ; FIND DOUBLE SPACE
            , " "   ; REPLACE WITH SINGLE SPACE
        )
        
    )
    , O_C.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , O_C.UPDT_ID = REQINFO->UPDT_ID
    , O_C.UPDT_CNT = O_C.UPDT_CNT + 1
WHERE
    O_C.CATALOG_CD = swapme123
; UPDATE SCRIPT END FOR swapme123
;
;
;

/*
; QUERY
SELECT
	O.DEPT_DISPLAY_NAME
	, O.CATALOG_CD

FROM
	ORDER_CATALOG   O

WHERE O.DEPT_DISPLAY_NAME = "*  *"

WITH MAXREC = 1000000, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 100
 */