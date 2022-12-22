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
declare finalhtml = vc with NoConstant(" "),Protect
declare counter = i4 with noconstant(0),protect
declare administered_cd = i4 with Constant (4093094),protect
declare scanned_var = vc with NoConstant(" "),Protect
declare not_scanned_var = vc with NoConstant(" "),Protect

;Record Structure
record RS_REASON_COUNTS (
  1 R_LIST [*]  
    2 REASON_D = vc   
    2 REASON_D_CNT = vc
;   1 NUMBER_SCANNED = vc
;   1 NUMBER_NOT_SCANNED = vc
) 

; Query to Fetch the data on scan override reasons
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
    ;Loop through in the detail section and store variables
    DETAIL
        counter += 1
        RS_REASON_COUNTS->R_LIST[counter].REASON_D = REASON_DISP
        RS_REASON_COUNTS->R_LIST[counter].REASON_D_CNT = ERROR_COUNT
    WITH time = 60

; Query to fetch data on Successful Scans
    SELECT INTO "nl:"
        ;M.POSITIVE_MED_IDENT_IND
        ; , 
        SCANNED_1 = CNVTSTRING(count(M.POSITIVE_PATIENT_IDENT_IND))

    FROM
        MED_ADMIN_EVENT   M

    WHERE
        M.EVENT_TYPE_CD = administered_cd
        AND
        M.BEG_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
        AND
        M.POSITIVE_PATIENT_IDENT_IND = 1 ; 1 indicates scanned

    GROUP BY M.POSITIVE_PATIENT_IDENT_IND
    ORDER BY M.POSITIVE_PATIENT_IDENT_IND

    DETAIL
        scanned_var = SCANNED_1

    WITH
        TIME = 60

; Query to fetch data on Not-Scanned
     SELECT DISTINCT
        ;M.POSITIVE_MED_IDENT_IND
        ; , 
;        SCANNED_0 = CNVTSTRING(count(M.POSITIVE_PATIENT_IDENT_IND))
        M.MED_ADMIN_EVENT_ID
    FROM
        MED_ADMIN_EVENT   M

    WHERE
        M.EVENT_TYPE_CD = administered_cd
        AND
        M.BEG_DT_TM BETWEEN CNVTDATETIME($STA_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
        AND
        M.POSITIVE_PATIENT_IDENT_IND = 0 ; 0 = not scanned
    
    set not_scanned_var = CNVTSTRING(CURQUAL)
    WITH
        TIME = 60

;HTML Document Header
set finalhtml = build2(
	'<!doctype html>'
    ,'<html>'
    ,'<head>'
	,'<meta charset=utf-8>'
	,'<title>Medication Administration Scanner Override Reason</title>'

    ,'</style>'
    ,'</head>'
    ,'<body>'
    ,'<h1>Medication Administration Scanner Override Reason</h1>'
    ,'<h3>Time Range:'
    ,$STA_DATE_TM
    ,' To '
    ,$END_DATE_TM
    ,'</h3>'

)

; HTML table Header Row
set finalhtml = build2(
    finalhtml
    ,'<p><button onclick="sortTable()">Sort</button></p>'
    ,'<table id="myTable">'
        ,'<tr>'
            ,'<th>Reason</th>'
            ,'<th>Count</th>'
        ,'</tr>'
)

; Loop through Reasons and counts and add new rows to the html table
for(x =1 to counter)
	set finalhtml = build2(
				finalhtml
                ,'<tr>'
				,'<td>'
				,RS_REASON_COUNTS->R_LIST[x].REASON_D
                ,'</td>'
                ,'<td>'
				,RS_REASON_COUNTS->R_LIST[x].REASON_D_CNT
                ,'</td>'
                ,'</tr>'
                
    )
endfor

;Close the html table
set finalhtml = build2(
	finalhtml
    ,'</table>'
)

; SCRIPT FOR SORTING table
set finalhtml = build2(
	finalhtml
    ,'<script>'
        ,'function sortTable() {'
        ,'var table, rows, switching, i, x, y, shouldSwitch;'
        ,'table = document.getElementById("myTable");'
        ,'switching = true;'
        ; ,'/*Make a loop that will continue until'
        ; ,'no switching has been done:*/'
        ,'while (switching) {'
            ; ,'//start by saying: no switching is done:'
            ,'switching = false;'
            ,'rows = table.rows;'
            ; ,'/*Loop through all table rows (except the'
            ; ,'first, which contains table headers):*/'
            ,'for (i = 1; i < (rows.length - 1); i++) {'
            ; ,'//start by saying there should be no switching:'
            ,'shouldSwitch = false;'
            ; ,'/*Get the two elements you want to compare,'
            ; ,'one from current row and one from the next:*/'
            ,'x = rows[i].getElementsByTagName("TD")[1];'
            ,'y = rows[i + 1].getElementsByTagName("TD")[1];'
            ; ,'//check if the two rows should switch place:'
            ,'if (Number(x.innerHTML) < Number(y.innerHTML)) {'
                ; ,'//if so, mark as a switch and break the loop:'
                ,'shouldSwitch = true;'
                ,'break;'
            ,'}'
            ,'}'
            ,'if (shouldSwitch) {'
            ; ,'/*If a switch has been marked, make the switch'
            ; ,'and mark that a switch has been done:*/'
            ,'rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);'
            ,'switching = true;'
            ,'}'
        ,'}'
        ,'}'
    ,'</script>'
)

;End the html document
set finalhtml = build2(
	finalhtml
    , '<p>not scanned: </p>'
    , not_scanned_var
    , "<br>"
    , '<p>scanned: </p>'
    , scanned_var
    ,'</body>'
    ,'</html>'
)

SELECT INTO $OUTDEV
	HEAD REPORT
		finalhtml

WITH 
    MAXCOL = 5000, time=60

end
go
