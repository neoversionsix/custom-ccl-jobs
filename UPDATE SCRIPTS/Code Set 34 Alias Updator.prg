/* Selector */
SELECT
	 ALIAS_OUTBOUND_SOURCE = UAR_GET_CODE_DISPLAY(C_V_O.CONTRIBUTOR_SOURCE_CD)
	, ALIAS_OUTBOUND = C_V_O.ALIAS
	, C_V_O.CODE_VALUE
	, ALIAS_OUTBOUND_NUMBER = CNVTINT(C_V_O.ALIAS)
	, C_V_O.CODE_SET

FROM
	CODE_VALUE_OUTBOUND		C_V_O

WHERE
	C_V_O.CODE_SET = 34 ; Clinical Unit (HOSP_SERV)
	AND C_V_O.CONTRIBUTOR_SOURCE_CD =    10630393.00; "WH_LOCAL"
	AND CNVTSTRING(C_V_O.CODE_VALUE) = C_V_O.ALIAS ; ALIAS IS THE CODE VALUE
    AND C_V_O.CODE_VALUE = 170154951

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME= 5


; UPDATE INTO CODE_VALUE_OUTBOUND		C_V_O
; SET
;     C_V_O.ALIAS = <NEW_ALIAS>
;     , C_V_O.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
;     , C_V_O.UPDT_ID = REQINFO->UPDT_ID
;     , C_V_O.UPDT_CNT = C_V_O.UPDT_CNT + 1
; WHERE
; 	C_V_O.CODE_SET = 34 ; Clinical Unit (HOSP_SERV)
; 	AND C_V_O.CONTRIBUTOR_SOURCE_CD =    10630393.00; "WH_LOCAL"
; 	AND CNVTSTRING(C_V_O.CODE_VALUE) = C_V_O.ALIAS ; ALIAS IS THE CODE VALUE
;     AND C_V_O.CODE_VALUE = 170154951

UPDATE INTO CODE_VALUE_OUTBOUND	C_V_O
SET
	C_V_O.ALIAS = "<NEW_ALIAS>"
	, C_V_O.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
	, C_V_O.UPDT_ID = REQINFO->UPDT_ID
	, C_V_O.UPDT_CNT = C_V_O.UPDT_CNT + 1
WHERE
	C_V_O.CODE_SET = 34 ; Clinical Unit (HOSP_SERV)
	AND C_V_O.CONTRIBUTOR_SOURCE_CD = 10630393.00; "WH_LOCAL"
	AND C_V_O.CODE_VALUE = <CODE_VALUE_TARGET>
;----------------------------END SECTION -------------------------------------
;
