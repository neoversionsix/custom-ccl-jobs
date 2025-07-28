/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88 go
create program wh_testing_query_88

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "MEDS SELECTIONS" = 0

with OUTDEV, PRIMARY

record RECORD_STRUCTURE_MEDS (
  1 LIST_MEDS [*]
    2 A_CATALOG_CD = f8
)


declare MEDS_PARAMETER_TYPE_VAR = vc with NoConstant(' '),Protect
declare MEDS_SELECTION_TYPE_VAR = vc with NoConstant(' '),Protect
declare MEDS_OPERATOR_VAR = vc with NoConstant(' '),Protect
declare MEDS_CD_VAR = F8 with NoConstant(55.00),Protect
declare MEDS_COUNT = I4 with NoConstant(0),Protect
declare COUNTER = I4 with NoConstant(0),Protect
DECLARE FIRST_PRIMARY_CD = F8 with NoConstant(0.00),Protect



SET MEDS_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($PRIMARY),0)))
SET FIRST_PRIMARY_CD = $PRIMARY

; Set the operator for the med depending on the user selection
SET MEDS_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($PRIMARY),0)))
IF (SUBSTRING(1,1,MEDS_PARAMETER_TYPE_VAR) = "L")
	SET MEDS_SELECTION_TYPE_VAR = "LIST SELECTION"
	SET MEDS_OPERATOR_VAR = "IN"
ELSE
    IF (FIRST_PRIMARY_CD = 0.00)
        SET MEDS_SELECTION_TYPE_VAR = "NO SELECTION"
        SET MEDS_OPERATOR_VAR = "!="
    ELSE
        SET MEDS_SELECTION_TYPE_VAR = "ONE SELECTION"
        SET MEDS_OPERATOR_VAR = "="
    ENDIF
ENDIF



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
	; add space to the list if needed
	IF (COUNTER > 1000)
		STAT = ALTERLIST(RECORD_STRUCTURE_MEDS->LIST_MEDS,COUNTER)
	ENDIF
	RECORD_STRUCTURE_MEDS->LIST_MEDS[COUNTER].A_CATALOG_CD = MED

WITH time = 90

SELECT INTO $OUTDEV
	D.USER
FROM DUMMYT D

HEAD REPORT
	"REFLECT PARAMETER TPYE: "
	MEDS_PARAMETER_TYPE_VAR
	ROW +1
	"SELECTION TYPE: "
	MEDS_SELECTION_TYPE_VAR
	ROW +1
	"CALCULATED OPERATOR: "
	MEDS_OPERATOR_VAR
	ROW +1
	"NUMBER OF ELEMENTS"
	MEDS_COUNT
	ROW +1
	"RAW VALUE SELECTED: "
	ROW +1
	RECORD_STRUCTURE_MEDS->LIST_MEDS[1].A_CATALOG_CD
	;substring(1,1,reflect(parameter(parameter2($MEDS),0)))
	ROW +1
	"END HEAD"
	ROW +1

FOOT REPORT
	"END FOOT"

WITH TIME = 5

end
go