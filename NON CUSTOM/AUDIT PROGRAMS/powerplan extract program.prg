/*
Notes
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"

WITH OUTDEV

DECLARE PATHWAY_CATALOG_ID_VAR = F4 WITH CONSTANT(124340476.00),PROTECT
DECLARE FINALHTML_VAR = VC with NoConstant(" "),Protect
DECLARE POWERPLAN_ID_VAR = VC with NoConstant("NOT FOUND"),Protect

DECLARE POWERPLAN_NAME_VAR = VC with NoConstant("NOT FOUND"),Protect
DECLARE PATHWAY_TYPE_DISP_VAR = VC with NoConstant("NOT FOUND"),Protect
DECLARE TYPE_MEAN_VAR = VC with NoConstant("NOT FOUND"),Protect
DECLARE BEGIN_DT_VAR = VC with NoConstant("NOT FOUND"),Protect
DECLARE P_DISPLAY_METHOD_DISP_VAR = VC with NoConstant("NOT FOUND"),Protect
DECLARE UPDATED_DT_VAR = VC with NoConstant("NOT FOUND"),Protect

;124340476 ; Unfractionated Heparin Infusion (Adults > 16 years) EKM

SELECT INTO "NL:"
    ;POWERPLAN_ID_VAR = PATHWAY_CATALOG.PATHWAY_CATALOG_ID; eg '124340476'
      POWERPLAN_NAME = PATHWAY_CATALOG.DESCRIPTION ; eg 'Unfractionated Heparin Infusion (Adults > 16 years)'
    , PATHWAY_TYPE_DISP = UAR_GET_CODE_DISPLAY(PATHWAY_CATALOG.PATHWAY_TYPE_CD); eg 'Medical'
    , TYPE_MEAN = PATHWAY_CATALOG.TYPE_MEAN ; eg 'PATHWAY'
    , BEGIN_DT = PATHWAY_CATALOG.BEG_EFFECTIVE_DT_TM
    , P_DISPLAY_METHOD_DISP = UAR_GET_CODE_DISPLAY(PATHWAY_CATALOG.DISPLAY_METHOD_CD); eg 'Clinical Category'
    , UPDATED_DT = PATHWAY_CATALOG.UPDT_DT_TM

FROM
	PATHWAY_CATALOG
    ;, PATHWAY_COMP
    ;, ORDER_CATALOG_SYNONYM

WHERE
    PATHWAY_CATALOG.PATHWAY_CATALOG_ID = PATHWAY_CATALOG_ID_VAR

HEAD REPORT
    POWERPLAN_NAME_VAR = POWERPLAN_NAME
    PATHWAY_TYPE_DISP_VAR = PATHWAY_TYPE_DISP
    TYPE_MEAN_VAR = TYPE_MEAN
    BEGIN_DT_VAR = FORMAT(BEGIN_DT, "DD-MMM-YYYY HH:MM;;D")
    P_DISPLAY_METHOD_DISP_VAR = P_DISPLAY_METHOD_DISP
    UPDATED_DT_VAR = FORMAT(UPDATED_DT, "DD-MMM-YYYY HH:MM;;D")

; GROUP BY PATHWAY_CATALOG.PATHWAY_CATALOG_id

; ORDER BY PATHWAY_CATALOG.PATHWAY_CATALOG_ID

WITH TIME = 60,
	; MAXREC = 5000,
	NOCOUNTER,
	MAXCOL = 5000,
	FORMAT

set FINALHTML_VAR = build2(
    "<html>"
	, "<head>"
	, "<title>PowerPlan Audit</title>"
    , "<style>"
    , "table, th, td {"
    , "border: 1px solid black;"
    , "border-collapse: collapse;"
    , "}"
    , "</style>"
    , "</head>"
    , "<h1>Powerplan Audit (DEV)</h1>"
    , "<p1>This Report gives you XXXXXX"
    , "</p1><br><br>"
	, "</head>"
	, "<body>"
	, "<table width='90%'>"

	, "<tr>"
	, '<td style="font-weight: bold">'
	, "POWERPLAN NAME:"
	, "</td>"
	,'<td style="font-weight: bold">', POWERPLAN_NAME_VAR, "</td>"
    , "</tr>"

    , "<tr>"
    , '<td>'
	, "PATHWAY_CATALOG_ID:"
	, "</td>"
    ,"<td>", POWERPLAN_ID_VAR, "</td>"
    , "</tr>"

    , "<tr>"
    , '<td>'
	, "PATHWAY TYPE:"
	, "</td>"
    ,"<td>", PATHWAY_TYPE_DISP_VAR, "</td>"
    , "</tr>"

    ;,"<td>", PATHWAY_TYPE_DISP, "</td>"))
	, "</table>"
	, "</body>"
	, "</html>"
)

;Send the html text to the window
set _memory_reply_string = FINALHTML_VAR


;DETAIL


;FOOT REPORT




end
go