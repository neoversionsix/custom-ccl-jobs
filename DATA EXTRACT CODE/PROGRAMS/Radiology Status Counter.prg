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

with OUTDEV, STA_DATE_TM, END_DATE_TM


SELECT INTO $OUTDEV
    ORDERS.ORDER_STATUS_CD
    , STATUS_DISP = UAR_GET_CODE_DISPLAY(ORDERS.ORDER_STATUS_CD)
    , STATUS_COUNT = CNVTSTRING(count(ORDERS.ORDER_STATUS_CD))

FROM
	ORDERS
    , ORDER_ACTION

PLAN ORDERS WHERE
        ORDERS.ORIG_ORDER_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)

JOIN ORDER_ACTION
    WHERE
        ORDER_ACTION.ORDER_ID = ORDERS.ORDER_ID
        AND
        ORDER_ACTION.ACTION_TYPE_CD = 2534	;RADIOLOGY ORDERS ONLY

GROUP BY ORDERS.ORDER_STATUS_CD

ORDER BY ORDERS.ORDER_STATUS_CD

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
    row +1 $STA_DATE_TM
    row +1 $END_DATE_TM
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
	call print(concat('<td style="font-weight: bold">', STATUS_DISP, "</td>"))
    call print(concat("<td>", STATUS_COUNT, "</td>"))
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