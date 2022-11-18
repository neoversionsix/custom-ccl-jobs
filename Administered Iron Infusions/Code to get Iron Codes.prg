SELECT
	O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, O.CATALOG_CD
	, O_CATALOG_TYPE_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_TYPE_CD)
	, O.DESCRIPTION

FROM
	ORDER_CATALOG   O

WHERE 
	(
	O.DESCRIPTION = "*infusion*"
	OR
	O.DESCRIPTION = "*Infusion*"
	OR
	O.DESCRIPTION = "*INFUSION*"
    OR
    O.DESCRIPTION = "*intravenous*"
	)
	
	AND 
	(
	O.DESCRIPTION = "*iron*"
	OR
	O.DESCRIPTION = "*Iron*"
	OR
	O.DESCRIPTION = "*IRON*"
	)

WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 20


/*
CATALOG CODES FOR IRON INFUSIONS
iron polymaltose (>1g) infusion xx mg in	  124212029.00	Pharmacy	iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9
ferric (iron) carboxymaltose infusion xx	  139426142.00	Pharmacy	ferric (iron) carboxymaltose infusion xx mg in Sodium Chlori
ferric (iron) carboxymaltose infusion 10	  124212014.00	Pharmacy	ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chlo
iron polymaltose infusion xx mg in Sodiu	  139439007.00	Pharmacy	iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx m
iron sucrose infusion 500 mg in Sodium C	  124212059.00	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 500 mL
iron polymaltose infusion 1000 mg in Sod	  124212035.00	Pharmacy	iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 10
iron sucrose infusion 500 mg in Sodium C	  124212052.00	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 250 mL



Diluent Catalog code for
order id:   1474904689 (administered)   1474997937 not admins
test patient person id: 13312354.00
catalog code of diluent: 26767864.00

*/

SELECT
	OD.ACTION_SEQUENCE
	, OD.DETAIL_SEQUENCE
	, OD.OE_FIELD_DISPLAY_VALUE
	, OD.OE_FIELD_DISPLAY_VALUE_EXTEND
	, OD.OE_FIELD_DT_TM_VALUE
	, OD.OE_FIELD_ID
	, OD.OE_FIELD_MEANING
	, OD.OE_FIELD_MEANING_ID
	, OD.OE_FIELD_TZ
	, OD.OE_FIELD_VALUE
	, OD.ORDER_ID
	, OD.PARENT_ACTION_SEQUENCE
	, OD.ROWID
	, OD.UPDT_APPLCTX
	, OD.UPDT_CNT
	, OD.UPDT_DT_TM
	, OD.UPDT_ID
	, OD.UPDT_TASK
FROM
	ORDER_DETAIL OD
WHERE 
	OD.OE_FIELD_VALUE =      318173.00 ; "IV Infusion"
	; AND
	; OD.OE_FIELD_DISPLAY_VALUE = "IV Infusion"

WITH TIME = 20, MAXREC = 50



OD.OE_FIELD_MEANING_ID = 2050
OD.OE_FIELD_VALUE =      318173.00