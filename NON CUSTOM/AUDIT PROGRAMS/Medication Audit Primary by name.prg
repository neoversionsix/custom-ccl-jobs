/*
This program is to count the Radiology Order status' for a given time range.
It is useful for monitoring issues relating to Rad orders. Origionally developed to
check if 'cancelled' orders were increasing. Rad dept suspected an issue with cancelled
orders increasing.
Programmer: Jason Whittle
*/


drop program wh_radiology_status_counts:dba go
create program wh_radiology_status_counts:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date and Time" = "CURDATE"
	, "End Date and Time" = "CURDATE"

with OUTDEV, PRIMARY_NAME

DECLARE PRIMARY_NAME = VC with NoConstant($PRIMARY_NAME),Protect

SELECT INTO "NL:"
      PRIMARY_MNEMONIC = OC.PRIMARY_MNEMONIC
    , PRIMARY_DESCRIPTION = OC.DESCRIPTION
    , CATALOG_TYPE = UAR_GET_CODE_DISPLAY(OC.CATALOG_TYPE_CD)
    , ACTIVITY_TYPE = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_TYPE_CD)
    , ACTIVITY_SUBTYPE = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_SUBTYPE_CD)
FROM
    ORDER_CATALOG   OC

WHERE
    OC.PRIMARY_MNEMONIC = $PRIMARY_NAME

    

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
    row +1 "<h1>Radiology Order Status Counts</h1>"
    row +1 "<h3>Time Range:"
    row +1 $PRIMARY_NAME
    row +1 "</h3>"
    row +1 "<p1>This Report gives you the counts of the Radiology"
    row +1 "order status' for a chosen time range. It"
    row +1 "is useful for monitoring issues relating to Rad orders."
    row +1 " The dates-times represent the time the order was originally made."
    row +1 "</p1><br><br>"
	row +1 "</head>"
	row +1 "<body>"
	row +1 "<table width='40%'>"

DETAIL
	row +1 call print("<tr>")
	call print(concat('<td style="font-weight: bold">', PRIMARY_NAME, "</td>"))
    call print(concat("<td>", PRIMARY_NAME, "</td>"))
    call print("</tr>")

FOOT REPORT
	row +1 "</table>"
	row +1 "</body>"
	row +1 "</html>"

WITH TIME = 30,
	; MAXREC = 5000,
	NOCOUNTER,
	MAXCOL = 5000,
	FORMAT

end
go