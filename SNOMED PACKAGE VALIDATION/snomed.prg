drop program wh_validate_snomed:dba go
create program wh_validate_snomed:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV



/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare SNOMEDCT_CD_VAR = F4 with Constant(673967.0),Protect
declare LAST_UPDATE_VAR = VC with NoConstant("PLACEHOLDER"),Protect
declare FINALHTML_VAR = vc with NoConstant(" "),Protect
declare MAX_DATE_VAR = DQ8 with NoConstant(0),Protect
declare NAME_UPDATED_ACTIVE_VAR = VC with NoConstant("PLACEHOLDER"),Protect
declare NAME_UPDATED_INACTIVE_VAR = VC with NoConstant("PLACEHOLDER"),Protect


/**************************************************************
; DVDev Start Coding
**************************************************************/
;Package Install Date
SELECT
	LAST_UPDATED = MAX(N.UPDT_DT_TM)
FROM
	NOMENCLATURE   N
WHERE	N.SOURCE_VOCABULARY_CD = SNOMEDCT_CD_VAR
HEAD REPORT
	LAST_UPDATE_VAR = FORMAT(LAST_UPDATED, "DD-MMM-YYYY HH:MM;;D")
	MAX_DATE_VAR = LAST_UPDATED
WITH TIME=10


;Get an example of an active updated snomed item
SELECT
	SNOMED_ITEM_NAME = N.SOURCE_STRING
FROM
	NOMENCLATURE   N
WHERE	
	N.SOURCE_VOCABULARY_CD = 673967; snomed rows
	AND
	N.ACTIVE_IND = 1;Active Item
	AND
	N.UPDT_DT_TM >= MAX_DATE_VAR
HEAD REPORT
	NAME_UPDATED_ACTIVE_VAR = SNOMED_ITEM_NAME
WITH MAXREC = 1, TIME=10

;Get an example of an active updated snomed item
SELECT
	SNOMED_ITEM_NAME = N.SOURCE_STRING
FROM
	NOMENCLATURE   N
WHERE	
	N.SOURCE_VOCABULARY_CD = 673967; snomed rows
	AND
	N.ACTIVE_IND = 1; Inactive Item
	AND
	N.UPDT_DT_TM >= MAX_DATE_VAR
HEAD REPORT
	NAME_UPDATED_INACTIVE_VAR = SNOMED_ITEM_NAME
WITH MAXREC = 1, TIME=10


set FINALHTML_VAR = build2(
	'<!doctype html>'
    ,'<html>'
    ,'<head>'
	,'<meta charset=utf-8>'
	,'<title>Medication Administration Scanner Override Reason</title>'
    ,'<style>'
    ,'</style>'
    ,'</head>'
    ,'<body>'
    ,'<h1>Snomed Package Validation Checks</h1>'
	,'<h3>Last Update (Package Install Date): </h3>'
    , LAST_UPDATE_VAR
	,'<br>'
	,'<h3>Updated Active Item: </h3>'
    , NAME_UPDATED_ACTIVE_VAR
	,'<br>'
	,'<h3>Updated Inactive Item: </h3>'
    , NAME_UPDATED_INACTIVE_VAR
	,'<br>'
    ,'</body>'
    ,'</html>'
)

;Send the html text to the window
SELECT INTO $OUTDEV
HEAD REPORT
    FINALHTML_VAR
WITH MAXCOL=5000

/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end
go
