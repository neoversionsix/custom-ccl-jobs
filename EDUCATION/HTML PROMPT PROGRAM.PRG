drop program wh_jw_test_example_1 go
create program wh_jw_test_example_1

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Person ID?" = 123456 

with OUTDEV, PID

SELECT into $OUTDEV
	P.BIRTH_DT_TM
	,P.BIRTH_TZ
	,P.BIRTH_PREC_FLAG
	,P.NAME_FULL_FORMATTED

FROM
	PERSON   P
WHERE 
	P.PERSON_ID = $PID
	AND
	P.ACTIVE_IND = 1

head report
	row +1 "<html>"
	row +1 "<head>"
	row +1 "<title>Patient List</title>"
	row +1 "</head>"
	row +1 "<body>"
	row +1 "<table border='0' width='100%'>"
detail
	row +1 call print("<tr>")
	call print(concat("<td>", DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY"), "</td>"))
	call print(concat("<td>", P.NAME_FULL_FORMATTED, "</td>"))
	call print("</tr>")
foot report
	row +1 "</table>"
	row +1 "</body>"
	row +1 "</html>"	

WITH NOCOUNTER, FORMAT, maxrec = 200, maxcol=500

end
go