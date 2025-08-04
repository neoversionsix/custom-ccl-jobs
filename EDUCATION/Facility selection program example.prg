/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88 go
create program wh_testing_query_88

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "prompt1" = ""

with OUTDEV, FACILITY

declare FACILTY_PARAMETER_TYPE_VAR = vc with NoConstant(' '),Protect
declare FACILTY_SELECTION_TYPE_VAR = vc with NoConstant(' '),Protect
declare FACILTY_OPERATOR_VAR = vc with NoConstant(' '),Protect
declare FACILTY_CD_VAR = F8 with NoConstant(0.00),Protect

SET FAC_PARAMETER_TYPE_VAR = trim(reflect(parameter(parameter2($FACILITY),0)))

IF (FAC_PARAMETER_TYPE_VAR = "C1")
	SET FACILTY_SELECTION_TYPE_VAR = "NO SELECTION"
	set FACILTY_OPERATOR_VAR = ">"
ELSEIF (SUBSTRING(1,1,FAC_PARAMETER_TYPE_VAR) = "L")
	SET FACILTY_SELECTION_TYPE_VAR = "LIST SELECTION"
	set FACILTY_OPERATOR_VAR = "IN"
ELSE; CX, where x is a number greater than one usually C9
	SET FACILTY_SELECTION_TYPE_VAR = "ONE SELECTION"
	SET FACILTY_CD_VAR = CNVTREAL($FACILITY)
ENDIF


SELECT INTO $OUTDEV
	D.USER
FROM DUMMYT D

HEAD REPORT
	"REFLECT PARAMETER TPYE: "
	FAC_PARAMETER_TYPE_VAR
	ROW +1
	"SELECTION TYPE: "
	FACILTY_SELECTION_TYPE_VAR
	ROW +1
	"CALCULATED OPERATOR: "
	FACILTY_OPERATOR_VAR
	ROW +1
	FACILTY_CD_VAR
	ROW +1
	"END HEAD"
	ROW +1

FOOT REPORT
	"END FOOT"

WITH TIME = 5

end
go