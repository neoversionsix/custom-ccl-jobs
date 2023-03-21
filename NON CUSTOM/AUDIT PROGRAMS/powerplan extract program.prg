/*
Notes
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"

WITH OUTDEV

DECLARE PATHWAY_CATALOG_ID_VAR = F4 WITH CONSTANT(124340476),PROTECT
;124340476 ; Unfractionated Heparin Infusion (Adults > 16 years) EKM

SELECT INTO $OUTDEV
    POWERPLAN_NAME = PATHWAY_CATALOG.DESCRIPTION
    , PATHWAY_TYPE_DISP = UAR_GET_CODE_DISPLAY(PATHWAY_CATALOG.PATHWAY_TYPE_CD)
    , POWERPLAN_ID = PATHWAY_CATALOG.PATHWAY_CATALOG_ID

FROM
	PATHWAY_CATALOG
    , PATHWAY_COMP
    , ORDER_CATALOG_SYNONYM

PLAN PATHWAY_CATALOG
    WHERE
        PATHWAY_CATALOG.PATHWAY_CATALOG_ID = PATHWAY_CATALOG_ID_VAR ; Unfractionated Heparin Infusion (Adults > 16 years) EKM

JOIN PATHWAY_COMP
    WHERE PATHWAY_COMP.PATHWAY_CATALOG_ID = OUTERJOIN(PATHWAY_CATALOG.PATHWAY_CATALOG_ID)

JOIN ORDER_CATALOG_SYNONYM
    WHERE CS.SYNONYM_ID = OUTERJOIN(PATHWAY_COMP.PARENT_ENTITY_ID)



; GROUP BY PATHWAY_CATALOG.PATHWAY_CATALOG_id

ORDER BY PATHWAY_CATALOG.PATHWAY_CATALOG_ID

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
	row +1 "<tr>"
	row +1 '<td style="font-weight: bold">'
	row +1 "POWERPLAN NAME:"
	row +1 "</td>"
	call print(concat('<td style="font-weight: bold">', POWERPLAN_NAME, "</td>"))
    row +1 "</tr>"
    row +1 "<tr>"
    row +1 '<td>'
	row +1 "PATHWAY TYPE:"
	row +1 "</td>"
    call print(concat("<td>", PATHWAY_TYPE_DISP, "</td>"))
    row +1 "</tr>"
    ;call print(concat("<td>", PATHWAY_TYPE_DISP, "</td>"))
	row +1 "</table>"
	row +1 "</body>"
	row +1 "</html>"
;DETAIL


;FOOT REPORT


WITH TIME = 60,
	; MAXREC = 5000,
	NOCOUNTER,
	MAXCOL = 5000,
	FORMAT

end
go