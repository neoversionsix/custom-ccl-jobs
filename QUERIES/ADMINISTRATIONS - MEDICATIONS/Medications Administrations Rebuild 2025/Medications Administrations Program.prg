drop program wh_med_administrations2 go
create program wh_med_administrations2
/*
Programmer: Jason Whittle
Created: 16 Nov 2023
Updated: 25 Jun 2025
Use: Medication Administrations (including surgery)
Config Instructions: Queries for the selection boxes at bottom
START_DATE_TIME
    - Control Type: Date Time
    - Prompt Type: String
    - Prompt Options: Date and Time
END_DATE_TIME
    - Control Type: Date Time
    - Prompt Type: String
    - Prompt Options: Date and Time
FACILITY
    - Control Type: List Box
    - Prompt Type: Expression
    - Data Source->Where will the data come from?: Query (paste in the query)
    - Data Source-> Check Multiple Selection
UNITS
    - Control Type: List Box
    - Prompt Type: Expression
    - Data Source->Where will the data come from?: Query
    - Data Source-> Check Multiple Selection
    - Data Source-> Check 'Include Any'
    - Data Source-> Properties -> Okay -> Properties -> 'Define Any': Set default to 0.00
    - Data Source-> Properties -> Okay -> Properties -> Make the code_value the key, hide all except level 3 display
PRIMARY
    - Control Type: List Box
    - Prompt Type: Expression
    - Data Source->Where will the data come from?: Query (paste in the query)
    - Data Source-> Check Multiple Selection
 */

prompt
	"Output to File/Printer/MINE" = "MINE"                    ;* Enter or select the printer or file name to send this report to.
	, "Administered After..." = "SYSDATE"
	, "Administered Before..." = "SYSDATE"
	, "Select facilities:" = 0
	, "Select Units:" = 0
	, "Seletct primaries (leave blank to include all):" = 0

with OUTDEV, START_DATE_TIME, END_DATE_TIME, FACILITY, UNITS, PRIMARY

RECORD RECORD_STRUCTURE_MEDS (
  1 LIST_MEDS [*]
    2 A_CATALOG_CD = f8
)

DECLARE MEDS_SELECTION_TYPE_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE COUNTER = I4 WITH NOCONSTANT(0),PROTECT
DECLARE i = I4 WITH PROTECT, NOCONSTANT(0)
DECLARE FIRST_PRIMARY_CD = F8 WITH NOCONSTANT(0.00),PROTECT
DECLARE FACILITY_SELECTION_TYPE_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE FACILITY_PARAMETER_TYPE_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE FACILITY_OPERATOR_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE UNITS_SELECTION_TYPE_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE UNITS_PARAMETER_TYPE_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE UNITS_OPERATOR_VAR = VC WITH NOCONSTANT(" "),PROTECT

; Set the operator for the facility depending on the user selection
SET FACILITY_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($FACILITY),0)))
IF (SUBSTRING(1,1,FACILITY_PARAMETER_TYPE_VAR) = "L")
	SET FACILITY_SELECTION_TYPE_VAR = "LIST SELECTION"
	SET FACILITY_OPERATOR_VAR = "IN"
ELSE
    IF ($FACILITY = 0.00)
        SET FACILITY_SELECTION_TYPE_VAR = "ANY SELECTION"
        SET FACILITY_OPERATOR_VAR = "!="
    ELSE
        SET FACILITY_SELECTION_TYPE_VAR = "ONE SELECTION"
        SET FACILITY_OPERATOR_VAR = "="
    ENDIF
ENDIF

; Set the operator for the facility depending on the user selection
SET UNITS_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($UNITS),0)))
IF (SUBSTRING(1,1,UNITS_PARAMETER_TYPE_VAR) = "L")
	SET UNITS_SELECTION_TYPE_VAR = "LIST SELECTION"
	SET UNITS_OPERATOR_VAR = "IN"
ELSE
    IF ($UNITS = 0.00)
        SET UNITS_SELECTION_TYPE_VAR = "ANY SELECTION"
        SET UNITS_OPERATOR_VAR = "!="
    ELSE
        SET UNITS_SELECTION_TYPE_VAR = "ONE SELECTION"
        SET UNITS_OPERATOR_VAR = "="
    ENDIF
ENDIF

; Determine Med Selection Type
SET MEDS_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($PRIMARY),0)))
IF (SUBSTRING(1,1,MEDS_PARAMETER_TYPE_VAR) = "L")
	SET MEDS_SELECTION_TYPE_VAR = "LIST SELECTION"
ELSE
    IF (FIRST_PRIMARY_CD = 0.00)
        SET MEDS_SELECTION_TYPE_VAR = "NO SELECTION"
    ELSE
        SET MEDS_SELECTION_TYPE_VAR = "ONE SELECTION"
    ENDIF
ENDIF


; Put the Primary Catalog Codes into a record structure
SELECT
	IF (MEDS_SELECTION_TYPE_VAR = "LIST SELECTION")
		MED = O.CATALOG_CD
		FROM ORDER_CATALOG O
		WHERE O.CATALOG_CD IN ($PRIMARY)
	ELSEIF (MEDS_SELECTION_TYPE_VAR = "ONE SELECTION")
		MED = O.CATALOG_CD
		FROM ORDER_CATALOG O
		WHERE O.CATALOG_CD = FIRST_PRIMARY_CD
	ELSE ; no selection
		MED = O.CATALOG_CD
		FROM ORDER_CATALOG O
		WHERE O.CATALOG_CD > 0
		AND O.CATALOG_TYPE_CD = 2516 ;pharmacy
	ENDIF
INTO "NL:"
FROM DUMMYT
HEAD REPORT
	COUNTER = 0
	STAT = ALTERLIST(RECORD_STRUCTURE_MEDS->LIST_MEDS,1000)
DETAIL
	COUNTER += 1
	; add storage space to the list if needed, after it gets to 1000 catalog codes
	IF (COUNTER > 1000)
		STAT = ALTERLIST(RECORD_STRUCTURE_MEDS->LIST_MEDS,COUNTER)
	ENDIF
    ; store the catalog code in the record structure
	RECORD_STRUCTURE_MEDS->LIST_MEDS[COUNTER].A_CATALOG_CD = MED
WITH TIME = 90


SELECT DISTINCT INTO $OUTDEV
	PATIENT = P.NAME_FULL_FORMATTED
	, PATIENT_URN = P_A.ALIAS
	, ELH_FACILITY = UAR_GET_CODE_DISPLAY(ELH.LOC_FACILITY_CD)
	, UNIT =
        IF (MAE.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(MAE.NURSE_UNIT_CD); unit
        ELSE UAR_GET_CODE_DISPLAY(ELH.LOC_NURSE_UNIT_CD)
        ENDIF
	, ENCOUNTER_ = E_A.ALIAS
	, EVENT_TYPE =
        IF(MAE.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(MAE.EVENT_TYPE_CD); EVENT TYPE
        ELSE "SURGINET"
        ENDIF
    , INTERFACE = ; POWERCHART OR SURGINET?
        IF (MAE.MED_ADMIN_EVENT_ID>0) "POWERCHART"
        ELSE "SURGINET"
        ENDIF
    , PRIMARY = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, ORDER_MNEMONIC = O.ORDER_MNEMONIC
    , EVENT_TAG = C.EVENT_TAG
	, ORDERED_TIME = FORMAT(O.ORIG_ORDER_DT_TM, "YYYY-MM-DD HH:MM:SS")
    ;O.ORIG_ORDER_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
    ;FORMAT(O.ORIG_ORDER_DT_TM, "YYYY-MM-DD HH:MM:SS")
	, ADMINISTERED_BEG =
        IF(MAE.BEG_DT_TM>0) FORMAT(MAE.BEG_DT_TM, "YYYY-MM-DD HH:MM:SS")
        ELSE FORMAT(C.EVENT_START_DT_TM, "YYYY-MM-DD HH:MM:SS")
        ENDIF
	, ADMINISTERED_END = FORMAT(MAE.END_DT_TM, "YYYY-MM-DD HH:MM:SS")
	, ADMINISTER_POSITION =
        IF (MAE.BEG_DT_TM>0) UAR_GET_CODE_DISPLAY(MAE.POSITION_CD) ; direct position form med admin table
        ELSE UAR_GET_CODE_DISPLAY(PR.POSITION_CD) ; position from prsnl table if a surgery administration
        ENDIF
	, SERVICE = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , ENCOUNTER_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
    , ADMINISTERED_BY = PR.NAME_FULL_FORMATTED
    , ORDERED_BY = PR_2.NAME_FULL_FORMATTED
FROM
    ORDER_ACTION          	O_A
    , ORDER_ACTION          O_A_2
	, ORDERS                O
	, ENCOUNTER             E
	, MED_ADMIN_EVENT       MAE
    , PRSNL                 PR
    , PRSNL                 PR_2
    , PERSON				P
    , PERSON_ALIAS          P_A
    , ENCNTR_ALIAS          E_A
    , SA_MEDICATION_ADMIN   S
    , CLINICAL_EVENT        C
    , ENCNTR_LOC_HIST       ELH
PLAN O_A ; ORDER_ACTION
    WHERE
    O_A.ORDER_STATUS_CD IN(2548, 2543) 	; In process or complete orders only
    AND O_A.ORDER_CONVS_SEQ = 1 ; removes duplicates on this table
    AND O_A.ACTION_DT_TM >= CNVTDATETIME($START_DATE_TIME)
    AND O_A.ACTION_DT_TM <= CNVTDATETIME($END_DATE_TIME)
JOIN PR;PRSNL
    ; This is to get the person completing/administering the medication
    WHERE PR.PERSON_ID = OUTERJOIN(O_A.ACTION_PERSONNEL_ID);X.UPDT_ID
    AND PR.ACTIVE_IND = OUTERJOIN(1)
/* Joining Order Action table again to get the original ordering personell */
JOIN O_A_2 ; ORDER_ACTION
    WHERE O_A_2.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)
    AND O_A_2.ACTION_TYPE_CD = OUTERJOIN(2534); New Order
JOIN PR_2;PRSNL
    WHERE PR_2.PERSON_ID = OUTERJOIN(O_A_2.ACTION_PERSONNEL_ID);X.UPDT_ID
    AND PR_2.ACTIVE_IND = OUTERJOIN(1)
JOIN O ; ORDERS
	WHERE O.ORDER_ID = O_A.ORDER_ID
    /*Pharmacy Catalog only */
    AND O.CATALOG_TYPE_CD = 2516.00;
    AND O.ACTIVE_IND = 1
    ; Primary filter for all the catalog codes in the record structure
    AND EXPAND(i,1,COUNTER,O.CATALOG_CD,RECORD_STRUCTURE_MEDS->LIST_MEDS[i].A_CATALOG_CD)
JOIN E ; ENCOUNTER
	WHERE E.ENCNTR_ID = O.ENCNTR_ID
    AND E.ACTIVE_IND = 1
    /* Not "DEMO 1 HOSPITAL" Removes Fake Data From The Demo Hospital */
    AND E.LOC_FACILITY_CD != 4038465.00
/* Patient Identifiers such as URN Medicare no etc */
JOIN P_A;PERSON_ALIAS; PATIENT_URN = P_A.ALIAS
    WHERE P_A.PERSON_ID = E.PERSON_ID
    AND
    /* this filters for the UR Number Alias' only */
   	P_A.ALIAS_POOL_CD = 9569589.00
	AND
    /* Effective Only */
	P_A.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
    AND
    /* Active Only */
    P_A.ACTIVE_IND = 1
/* Patients */
JOIN P;PERSON
	WHERE P.PERSON_ID = E.PERSON_ID
    /* Remove Inactive Patients */
    AND P.ACTIVE_IND = 1
    /* Remove Fake 'Test' Patients */
    ;AND P.NAME_LAST_KEY != "*TESTWHS*"
    /* Remove Ineffective Patients */
    AND P.END_EFFECTIVE_DT_TM > SYSDATE
/* Encounter Identifiers such as the Financial Number */
JOIN E_A;ENCNTR_ALIAS; ENCOUNTER_NO = E_A.ALIAS
    WHERE E_A.ENCNTR_ID = E.ENCNTR_ID
    /*  'FIN/ENCOUNTER/VISIT NBR' from code set 319 */
	AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
	/* active FIN NBRs only */
    AND E_A.ACTIVE_IND = 1
    /* effective FIN NBRs only */
	AND E_A.END_EFFECTIVE_DT_TM > SYSDATE
JOIN MAE ;MED_ADMIN_EVENT
    WHERE MAE.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)
    AND OPERATOR(MAE.NURSE_UNIT_CD, UNITS_OPERATOR_VAR, $UNITS)
JOIN S ;SA_MEDICATION_ADMIN
    WHERE
        S.ORDER_ID = OUTERJOIN(O_A.ORDER_ID)
        AND S.ORDER_ID > OUTERJOIN(0)
        AND S.EVENT_ID > OUTERJOIN(0)
        AND S.ACTIVE_IND = OUTERJOIN(1)
JOIN C
    WHERE
        C.ORDER_ID = OUTERJOIN(S.ORDER_ID)
	    AND C.VIEW_LEVEL = OUTERJOIN(1)
JOIN	ELH ; ENCNTR_LOC_HIST
    WHERE ELH.ENCNTR_ID = OUTERJOIN(E.ENCNTR_ID) ; join on encounter
    AND OPERATOR(ELH.LOC_FACILITY_CD, FACILITY_OPERATOR_VAR, $FACILITY)
    AND OPERATOR(ELH.LOC_NURSE_UNIT_CD, UNITS_OPERATOR_VAR, $UNITS)
    AND ELH.ACTIVE_IND = OUTERJOIN(1)	; remove inactive rows
    AND ELH.BEG_EFFECTIVE_DT_TM <  OUTERJOIN(CNVTDATETIME($START_DATE_TIME)); location began before administered
    AND ELH.END_EFFECTIVE_DT_TM >  OUTERJOIN(CNVTDATETIME($START_DATE_TIME)); location ended after administered
ORDER BY
    O.PERSON_ID
	, O.ORDER_ID
WITH TIME = 200,
	NOCOUNTER,
	SEPARATOR=" ",
	FORMAT

end
go


/*
QUERIES FOR
- FACILTIY SELECTOR
- UNIT SELECTOR
- PRIMARY SELECTOR

FACILITY SELECTOR QUERY
-------------------------------------------------------------------------

SELECT
      CV.CODE_VALUE
    , CV.DISPLAY

FROM
    CODE_VALUE   CV

WHERE CV.CODE_SET = 220
    and CV.CDF_MEANING = "FACILITY"
    and CV.ACTIVE_IND = 1
    and CV.BEGIN_EFFECTIVE_DT_TM < sysdate
    and CV.END_EFFECTIVE_DT_TM > sysdate
    and CV.DISPLAY NOT IN
    (
         "DEMO 2 HOSPITAL"
        ,"DEMO 4 WOMENS CLINIC"
        ,"DEMO 3 MEDICAL CENTER"
        ,"216704"
        ,"CHCS"
        ,"CEPEXCHANGE"
        ,"1180"
        ,"CHM"
        ,"CHBM"
        ,"CHW"
    )

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 10


UNIT SELECTOR QUERY
-------------------------------------------------------------------------
SELECT DISTINCT
    LV1_GROUP_TYPE = UAR_GET_CODE_DISPLAY(LG1.LOCATION_GROUP_TYPE_CD)
    , LV1_DISP = UAR_GET_CODE_DISPLAY(LG1.PARENT_LOC_CD)
    , LV2_GROUP_TYPE = UAR_GET_CODE_DISPLAY(LG2.LOCATION_GROUP_TYPE_CD)
    , LV2_DISP = CV1.DISPLAY
    , LV3_DISP = CV2.DISPLAY
    , CV2.CODE_VALUE

FROM
    LOCATION_GROUP   LG1
    , CODE_VALUE   CV1
    , LOCATION_GROUP   LG2
    , CODE_VALUE   CV2

PLAN LG1 ; 85758822.00  Footscray
WHERE LG1.PARENT_LOC_CD          IN ($FACILITY)
  AND LG1.ACTIVE_IND  = 1
  AND LG1.BEG_EFFECTIVE_DT_TM    <= CNVTDATETIME(CURDATE, CURTIME3)
  AND LG1.END_EFFECTIVE_DT_TM    >= CNVTDATETIME(CURDATE, CURTIME3)
  AND LG1.ROOT_LOC_CD            = 0

JOIN CV1
WHERE LG1.CHILD_LOC_CD           = CV1.CODE_VALUE
  AND CV1.ACTIVE_IND             = 1
  AND CV1.BEGIN_EFFECTIVE_DT_TM  <= CNVTDATETIME(CURDATE, CURTIME3)
  AND CV1.END_EFFECTIVE_DT_TM    >= CNVTDATETIME(CURDATE, CURTIME3)

JOIN LG2
WHERE LG2.PARENT_LOC_CD          = LG1.CHILD_LOC_CD
  AND LG2.ACTIVE_IND             = 1
  AND LG2.BEG_EFFECTIVE_DT_TM    <= CNVTDATETIME(CURDATE, CURTIME3)
  AND LG2.END_EFFECTIVE_DT_TM    >= CNVTDATETIME(CURDATE, CURTIME3)
  AND LG2.ROOT_LOC_CD            = 0

JOIN CV2
WHERE CV2.CODE_VALUE = LG2.CHILD_LOC_CD
  AND CV2.CDF_MEANING IN ("AMBULATORY","NURSEUNIT")
  AND CV2.ACTIVE_IND = 1
  AND CV2.BEGIN_EFFECTIVE_DT_TM <= CNVTDATETIME(CURDATE, CURTIME3)
  AND CV2.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE, CURTIME3)

ORDER BY
    LV1_GROUP_TYPE
    , LV1_DISP
    , LV2_GROUP_TYPE
    , LV2_DISP
    , LV3_DISP

WITH TIME = 90

PRIMARY SELECTOR QUERY
---------------
SELECT
      OC.CATALOG_CD
    , OC.PRIMARY_MNEMONIC
FROM
      ORDER_CATALOG     OC
    , CODE_VALUE         CV
PLAN OC
    WHERE
        OC.ACTIVE_IND = 1
        AND OC.CATALOG_TYPE_CD =        2516.00 ; Pharmacy
        ; AND OC.DCP_CLIN_CAT_CD =       10577.00 ; Medications
        AND OC.CKI != "IGNORE"
        AND CNVTUPPER(OC.PRIMARY_MNEMONIC) = PATSTRING(CNVTUPPER(CONCAT("*",$CURACCEPT,"*")))

JOIN CV
    WHERE
        OC.CATALOG_CD = CV.CODE_VALUE
        AND CV.END_EFFECTIVE_DT_TM > sysdate

ORDER BY OC.DESCRIPTION

 */