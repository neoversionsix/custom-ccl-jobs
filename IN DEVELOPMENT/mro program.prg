/*
ICU is required to complete MRO (multi resistant organism) screening on
admission and every 7 days. The screening pathology requests are Vancomycin
Resistant Enterococcus (VRE) Culture Faeces and Carbapenemase Producing
Organisms (CPO) Screen Faeces. This is not easily viewable within EMR, which
leads to poor compliance and makes tracking difficult. Please make it possible
for the ICU team to run adhoc reports on MRO screening.
 */


IN DEVELELOPMENT/mro program.prg

SELECT
	C.AV_OPTIONAL_INGREDIENT_IND
	, C_CATALOG_DISP = UAR_GET_CODE_DISPLAY(C.CATALOG_CD)
	, C.COMP_ID
	, C.COMP_LABEL
	, C.COMP_MASK
	, C.COMP_REFERENCE
	, C.COMP_SEQ
	, C_COMP_TYPE_DISP = UAR_GET_CODE_DISPLAY(C.COMP_TYPE_CD)
	, C.COMP_TYPE_MEAN
	, C_CP_COL_CAT_DISP = UAR_GET_CODE_DISPLAY(C.CP_COL_CAT_CD)
	, C_CP_ROW_CAT_DISP = UAR_GET_CODE_DISPLAY(C.CP_ROW_CAT_CD)
	, C.INCLUDE_EXCLUDE_IND
	, C_INDEX_TYPE_DISP = UAR_GET_CODE_DISPLAY(C.INDEX_TYPE_CD)
	, C.INST_ID
	, C.LAST_UTC_TS
	, C.LINKED_DATE_COMP_SEQ
	, C.LOCKDOWN_DETAILS_FLAG
	, C.LONG_TEXT_ID
	, C.ORDER_SENTENCE_ID
	, C.ORD_COM_TEMPLATE_LONG_TEXT_ID
	, C.OUTCOME_PAR_COMP_SEQ
	, C.PARENT_COMP_SEQ
	, C.REQUIRED_IND
	, C.ROWID
	, C.TXN_ID_TEXT
	, C.UPDT_APPLCTX
	, C.UPDT_CNT
	, C.UPDT_DT_TM
	, C.UPDT_ID
	, C.UPDT_TASK
	, C.VARIANCE_FORMAT_ID

FROM
	CS_COMPONENT   C
	, CODE_VALUE CV

PLAN C
JOIN CV
	WHERE
	CV.CODE_VALUE = C.CATALOG_CD
	AND CV.CODE_SET = 200
	AND CV.CODE_VALUE = C.CATALOG_CD
	AND CNVTUPPER(CV.DISPLAY) = "*MRO*"


WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxrec = 1000, time = 10
	