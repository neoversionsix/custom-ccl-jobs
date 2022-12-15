/*
Notes
*/

drop program wh_med_administr_errors:dba go
create program wh_med_administr_errors:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE" 

with OUTDEV, STA_DATE_TM, END_DATE_TM


SELECT INTO $OUTDEV
    M_A_P_E.REASON_CD
    , REASON_DISP = UAR_GET_CODE_DISPLAY(M_A_P_E.REASON_CD)
    , ERROR_COUNT = CNVTSTRING(count(M_A_P_E.MED_ADMIN_PT_ERROR_ID))

FROM
	MED_ADMIN_PT_ERROR   M_A_P_E

WHERE
        M_A_P_E.UPDT_DT_TM BETWEEN CNVTLOOKBEHIND($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
        AND
        M_A_P_E.REASON_CD != 0.0

GROUP BY M_A_P_E.REASON_CD

ORDER BY M_A_P_E.REASON_CD

HEAD REPORT
    row +1 "<html>"
	row +1 "<head>"
	row +1 "<title>Patient List</title>"
    row +1 "<style>"
    row +1 "table, th, td {"
    row +1 "border: 1px solid black;"
    row +1 "border-collapse: collapse;"
    row +1 "}"
    row +1 "</style>"
    row +1 "</head>"
    row +1 "<h1>Medication Administration Patient Errors</h1>"
    row +1 "<h3>Time Range:"
    row +1 $STA_DATE_TM
    row +1 $END_DATE_TM
    row +1 "</h3>"
    row +1 "<p1>This Report gives you the counts of the Medication"
    row +1 "Administration errors for a chosen time range. It"
    row +1 "is useful for seeing how many times the wristbands"
    row +1 "were not scanned when administering medications."
    row +1 "</p1><br><br>"
	row +1 "</head>"
	row +1 "<body>"
	row +1 "<table width='40%'>"
    
DETAIL
	row +1 call print("<tr>")
	call print(concat('<td style="font-weight: bold">', REASON_DISP, "</td>"))
    call print(concat("<td>", ERROR_COUNT, "</td>"))
    call print("</tr>")

FOOT REPORT
	row +1 "</table>"
	row +1 "</body>"
	row +1 "</html>"

WITH TIME = 60,
	; MAXREC = 5000, 
	NOCOUNTER,  
	MAXCOL = 5000,
	FORMAT

end
go
