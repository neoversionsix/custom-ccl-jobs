; OEF FIELD LABEL CHANGE UPDATE SCRIPT -------------------------------------------
UPDATE INTO
    OE_FORMAT_FIELDS    O_F_F
SET
    O_F_F.LABEL_TEXT = "_NEW_LABEL_TEXT_" ;EDIT THIS WITH NEW FIELD LABEL
    , O_F_F.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , O_F_F.UPDT_ID = REQINFO->UPDT_ID
    , O_F_F.UPDT_CNT = O_F_F.UPDT_CNT + 1
WHERE
    O_F_F.OE_FORMAT_ID = _OE_FORMAT_ID_ ;EDIT THIS WITH OE_FORMAT_ID
    AND O_F_F.ACTION_TYPE_CD = _ACTION_TYPE_CD_ ;EDIT THIS WITH ACTION_TYPE_CD
    AND O_F_F.OE_FIELD_ID = _OE_FIELD_ID_ ;EDIT THIS WITH OE_FIELD_ID
    AND O_F_F.LABEL_TEXT = "_OLD_LABEL_TEXT_"
; END OF UPDATE SCRIPT ------------------------------------------------------------




; SELECT SCRIPT BELOW ---------------------------------------------------------


SELECT DISTINCT
    /*
    Use this for generating update scripts.
    You will need to delete rows and columns from excel to just focus on the
    stuff you want to edit
     */
    _NEW_LABEL_TEXT_ = "Discussed with (if applicable)" ; EDIT!!!! Put in the new label text in here
    , _OE_FORMAT_ID_ = O_F_F.OE_FORMAT_ID
    , _ACTION_TYPE_CD_ = O_F_F.ACTION_TYPE_CD
    , _OE_FIELD_ID_ = O_F_F.OE_FIELD_ID
    , _OLD_LABEL_TEXT_ = O_F_F.LABEL_TEXT
	/*
    Delete the following columns from excel after using them to filter for what you want to
	update. The columns above are required to generate the update scripts using the code
	generator tool
	 */
	; BELOW IS USED FOR FILTERING IN EXCEL
    , CATALOG = UAR_GET_CODE_DISPLAY(O_E_FO.CATALOG_TYPE_CD)
	, FORMAT_NAME = O_E_FO.OE_FORMAT_NAME
	, FIELD_DESCRIPTION = O_E_FI.DESCRIPTION
	, FIELD_TYPE = EVALUATE
		(
			O_E_FI.FIELD_TYPE_FLAG,
        	0,"ALPHANUMERIC",
	        1,"INTEGER",
	        2,"DECIMIAL",
	        3,"DATE",
	        5,"DATE/TIME",
	        6,"CODESET",
	        7,"YES/NO",
	        8,"PHYSICIAN/PROVIDER",
	        9,"LOCATION",
	        10,"ICD9",
	        11,"PRINTER",
	        12,"LIST",
	        13,"PERSONNEL",
	        14,"ACCESSION",
	        15,"SURGICAL DURATION"
	      )
	, MEANING = O_F_M.DESCRIPTION
	, FIELD_CODE_VALUE_CKI = C_V.CKI
	, O_E_FI.OE_FIELD_ID
FROM
	ORDER_ENTRY_FIELDS   			O_E_FI
	, OE_FORMAT_FIELDS				O_F_F
	, ORDER_ENTRY_FORMAT   			O_E_FO
	, OE_FIELD_MEANING				O_F_M
	, CODE_VALUE					C_V

PLAN O_E_FI
	WHERE O_E_FI.OE_FIELD_ID !=0

JOIN O_F_F ;OE_FORMAT_FIELDS
	WHERE O_F_F.OE_FIELD_ID = O_E_FI.OE_FIELD_ID

JOIN O_E_FO ;ORDER_ENTRY_FORMAT
	WHERE O_E_FO.OE_FORMAT_ID = O_F_F.OE_FORMAT_ID

JOIN O_F_M ;OE_FIELD_MEANING
 	WHERE O_F_M.OE_FIELD_MEANING_ID = O_E_FI.OE_FIELD_MEANING_ID

JOIN C_V ;CODE_VALUE
 	WHERE C_V.CODE_VALUE = O_E_FI.OE_FIELD_ID

ORDER BY
	O_E_FO.OE_FORMAT_NAME

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 10
