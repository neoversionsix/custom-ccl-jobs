drop program 1_JW_MEDTRAIN go
create program 1_JW_MEDTRAIN
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;    Your Code Goes Here
SELECT INTO $OUTDEV
	E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
	, P.NAME_FULL_FORMATTED
	, E.ENCNTR_ID
	, E.REG_DT_TM
	, E.DISCH_DT_TM
	, E.REASON_FOR_VISIT
 
FROM
	PERSON   P
	, ENCOUNTER   E
	, ENCNTR_ALIAS   EA
 
PLAN E
 
WHERE
	E.REG_DT_TM
	BETWEEN
		CNVTDATETIME("01-JAN-2018 00:00:00.00")
		AND
		CNVTDATETIME("31-DEC-2019 23:59:59.00")
 
JOIN P
	WHERE
	P.PERSON_ID = E.PERSON_ID
JOIN EA
	WHERE
	EA.ENCNTR_ID = E.ENCNTR_ID
 
ORDER BY
	E.REG_DT_TM   DESC
 
HEAD REPORT
	ROW 1 COL 56 "MEDICAL SERVICE REPORT"
	ROW + 2
 

HEAD PAGE
	COL 5 "Report Date:"
	COL +2 CURDATE
	ROW +2
	;/*
	COL 5  "REPORT DATE:"
	
	COL 21  curdate
	
	ROW + 2
	
	COL 5  "MEDICAL SERVICE:"
	
	COL 30  "FULL NAME"
	
	COL 60  "MEDICAL RECORD NUMBER"
	
	COL 88  "ADMISSION DATE"
	
	COL 109  "DICHARGE DATE"
	
	ROW + 2
	
Detail

    COL 5 E_MED_SERVICE_DISP

    NAME = SUBSTRING(1,25,P.NAME_FULL_FORMATTED )

    COL 29 NAME

    ALIAS1 = SUBSTRING(1,15,EA.ALIAS )

    COL 61 ALIAS1

    COL 89 E.REG_DT_TM

    COL 109 E.DISCH_DT_TM

    ROW + 1
;*/
WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 