/*
Notes
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE" 

with OUTDEV, STA_DATE_TM, END_DATE_TM

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare finalhtml = vc with NoConstant("placeholder"),Protect
declare counter = i4 with noconstant(0),protect

record RS_REASON_COUNTS (
  1 R_LIST [*]  
    2 REASON_D = vc   
    2 REASON_D_CNT = vc   
) 

SELECT INTO "nl:"
    M_A_P_E.REASON_CD
    , REASON_DISP = UAR_GET_CODE_DISPLAY(M_A_P_E.REASON_CD)
    , ERROR_COUNT = CNVTSTRING(count(M_A_P_E.MED_ADMIN_PT_ERROR_ID))

FROM
	MED_ADMIN_PT_ERROR   M_A_P_E

WHERE
        M_A_P_E.UPDT_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
        AND
        M_A_P_E.REASON_CD != 0.0

GROUP BY M_A_P_E.REASON_CD

ORDER BY M_A_P_E.REASON_CD

HEAD REPORT
	counter = 0
	;allocate memory to store information for 100 reasons
	STAT = ALTERLIST(RS_REASON_COUNTS->R_LIST,100)
    
DETAIL
	counter += 1

	 RS_REASON_COUNTS->R_LIST[counter].REASON_D = REASON_DISP
	 RS_REASON_COUNTS->R_LIST[counter].REASON_D_CNT = ERROR_COUNT
/*
FOOT REPORT
	row +1 "</table>"
	row +1 "</body>"
	row +1 "</html>"
*/
WITH time = 60


set finalhtml = build2(
	"<!doctype html><html><head>"
	,"<meta charset=utf-8><meta name=description><meta http-equiv=X-UA-Compatible content=IE=Edge>"
	,"<title>Change this title</title>"
	,"<p>"
)
; for(x = 1 to RS_REASON_COUNTS->counter)
for(x =1 to counter)
	set finalhtml = build2(
				finalhtml
				,"<br>"
				 ,RS_REASON_COUNTS->R_LIST[x].REASON_D
				,"<br>"
				 ,RS_REASON_COUNTS->R_LIST[x].REASON_D_CNT
                , x
                
	)
endfor
set finalhtml = build2(
	finalhtml
    ,"end"
	, "</p>"
)



SELECT INTO $OUTDEV
	HEAD REPORT
		finalhtml

WITH MAXCOL = 5000, time=60

end
go
