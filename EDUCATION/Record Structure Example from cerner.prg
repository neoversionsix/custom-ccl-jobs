DROP PROGRAM EX_RECORD GO
CREATE PROGRAM EX_RECORD

;initialize variables to keep track of the number of group orders and components
Declare CNT_ORD = I4
DECLARE CNT_DET = I4

;create a record structure to store person, order and component information
RECORD TEMP_1 (
     1 PERSON_ID = F8
     1 NAME = VC
     1 ORDERS[*]
          2 ORDER_ID = F8
          2 ORDER_MNE = VC
          2 DETAILS[*]
               3 RESULT_ID = F8
               3 PROC = VC)

SELECT INTO "NL:"
	P.PERSON_ID,
	P.NAME_FULL_FORMATTED,
	O.ORDER_ID,
	O.ORDER_MNEMONIC,
	R.RESULT_ID,
	PROC = UAR_GET_CODE_DISPLAY(R.TASK_ASSAY_CD)
FROM	PERSON P,
	ORDERS O,
	RESULT R
PLAN P WHERE P.PERSON_ID = 12345.0
JOIN O	WHERE P.PERSON_ID = O.PERSON_ID
JOIN R	WHERE O.ORDER_ID = R.ORDER_ID
ORDER	O.ORDER_ID,
        R.RESULT_ID
HEAD REPORT
	;store the person_id and name in the record structure
	TEMP_1->PERSON_ID = P.PERSON_ID
	TEMP_1->NAME = P.NAME_FULL_FORMATTED
        ;allocate memory to store information for 100 group orders
	call alterlist(TEMP_1->ORDERS,100)
HEAD O.ORDER_ID
	CNT_ORD = CNT_ORD + 1
	;if needed, allocate memory to store information for 10 additional group orders
	IF (MOD(CNT_ORD,10) = 1 AND CNT_ORD > 100)
             call alterlist(TEMP_1->ORDERS,CNT_ORD + 9)
        ENDIF
	;store information for the current group order in the record structure
	TEMP_1->ORDERS[CNT_ORD].ORDER_ID = O.ORDER_ID
        TEMP_1->ORDERS[CNT_ORD].ORDER_MNE = O.ORDER_MNEMONIC
	;set the component count for the current group order to zero
	CNT_DET = 0
	;allocate memory to store 10 components for the current group order
	call alterlist(TEMP_1->ORDERS[CNT_ORD].DETAILS,10)
DETAIL
	CNT_DET = CNT_DET + 1
	;if needed allocate memory to store 10 additional components
        IF (MOD(CNT_DET,10) = 1 AND CNT_DET != 1)
               call alterlist(TEMP_1->ORDERS[CNT_ORD].DETAILS,CNT_DET + 9)
        ENDIF
        ;store information for the current component in the record structure
        TEMP_1->ORDERS[CNT_ORD].DETAILS[CNT_DET].RESULT_ID = R.RESULT_ID
	TEMP_1->ORDERS[CNT_ORD].DETAILS[CNT_DET].PROC = PROC
FOOT O.ORDER_ID
	;free memory that was allocated but not used
	;for components of the current group order
	call alterlist(TEMP_1->ORDERS[CNT_ORD].DETAILS,CNT_DET)
FOOT REPORT
	;free memory that was allocated but not used for group orders
	call alterlist(TEMP_1->ORDERS,CNT_ORD)
END
GO