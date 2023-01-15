drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE" 

with OUTDEV, S_DATE_TM, E_DATE_TM

SELECT INTO $OUTDEV
/*
*/
;DECLARE LOOK_BACK = C3 WITH CONSTANT("1,W"), PROTECT

SELECT INTO $OUTDEV
    M_A_P_E.REASON_CD
    , REASON_DISP = UAR_GET_CODE_DISPLAY(M_A_P_E.REASON_CD)
    , ERROR_COUNT = count(M_A_P_E.MED_ADMIN_PT_ERROR_ID)

FROM
	MED_ADMIN_PT_ERROR   M_A_P_E

WHERE
        M_A_P_E.UPDT_DT_TM BETWEEN CNVTLOOKBEHIND($S_DATE_TM) AND CNVTDATETIME($E_DATE_TM)
        AND
        M_A_P_E.REASON_CD != 0.0

GROUP BY M_A_P_E.REASON_CD

ORDER BY M_A_P_E.REASON_CD

HEAD M_A_P_E.REASON_CD
    
COL_X = 0

DETAIL
    IF(ROW +2 > MAXROW)
    BREAK
    ENDIF
    IF(COL_X < 100)
        COL_X = COL_X + 25
        COL COL_X  REASON_DISP
        ROW +1
        COL COL_X ERROR_COUNT ";L"
        ROW -1     
    ELSE
        ROW + 2
        COL_X = 25
        COL COL_X  REASON_DISP
        ROW +1
        COL COL_X ERROR_COUNT ";L"
        ROW -1
    ENDIF

FOOT M_A_P_E.REASON_CD
    ROW +3


WITH TIME = 60,
	MAXREC = 1000,
	NOCOUNTER,  
	SEPARATOR=" ", 
	FORMAT

end
go