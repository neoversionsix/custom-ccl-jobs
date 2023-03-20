/*
Notes
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


SELECT INTO $OUTDEV
    POWERPLAN_NAME = pathway_catalog.description
    , PATHWAY_TYPE_DISP = UAR_GET_CODE_DISPLAY(pathway_catalog.PATHWAY_TYPE_CD)
    , POWERPLAN_ID = pathway_catalog.pathway_catalog_id

FROM
	pathway_catalog

; WHERE
;     pathway_catalog.pathway_catalog_id = 124340476

; GROUP BY pathway_catalog.pathway_catalog_id

ORDER BY pathway_catalog.pathway_catalog_id

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
    row +1 "<h1>Powerplan Audit (DEV)</h1>"
    row +1 "<p1>This Report gives you XXXXXX"
    row +1 "</p1><br><br>"
	row +1 "</head>"
	row +1 "<body>"
	row +1 "<table width='90%'>"

DETAIL
	row +1 "<tr>"
	row +1 '<td style="font-weight: bold">'
	row +1 "POWERPLAN NAME:"
	row +1 "</td>"
	call print(concat('<td style="font-weight: bold">', POWERPLAN_NAME, "</td>"))
    row +1 "</tr>"
    row +1 "<tr>"
    call print(concat("<td>", PATHWAY_TYPE_DISP, "</td>"))
    row +1 "</tr>"
    ;call print(concat("<td>", PATHWAY_TYPE_DISP, "</td>"))

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