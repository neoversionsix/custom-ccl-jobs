/*
Filter the order ingredient table for the following catalog codes
ferric carboxymaltose 		CATALOG_CD =	9814704 		order_id example =	517273871
iron sucrose			 	CATALOG_CD =	9742085			order_id example =	1420881306
iron polymaltose			CATALOG_CD =	9741951






	O_CATALOG_DISP	O_CATALOG_TYPE_DISP	PRIMARY_MNEMONIC	OC_CATALOG_DISP	OC_CATALOG_TYPE_DISP	MNEMONIC	MNEMONIC_KEY_CAP	ORDER_SENTENCE_ID	SYNONYM_ID
	iron polymaltose (>1g) infusion xx mg in	Pharmacy	iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9% 500 mL BAG BY BAG	iron polymaltose (>1g) infusion xx mg in	Pharmacy	iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9% 500 mL BAG BY BAG	IRON POLYMALTOSE (>1G) INFUSION XX MG IN SODIUM CHLORIDE 0.9% 500 ML BAG BY BAG	             0.00	  124212032.00
	ferric (iron) carboxymaltose infusion xx	Pharmacy	ferric (iron) carboxymaltose infusion xx mg in Sodium Chloride 0.9% xx mL BAG BY BAG (PAED)	ferric (iron) carboxymaltose infusion xx	Pharmacy	ferric (iron) carboxymaltose infusion xx mg in Sodium Chloride 0.9% xx mL BAG BY BAG (PAED)	FERRIC (IRON) CARBOXYMALTOSE INFUSION XX MG IN SODIUM CHLORIDE 0.9% XX ML BAG BY BAG (PAED)	             0.00	  139426145.00
	ferric (iron) carboxymaltose infusion 10	Pharmacy	ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chloride 0.9% 250 mL BAG BY BAG	ferric (iron) carboxymaltose infusion 10	Pharmacy	ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chloride 0.9% 250 mL BAG BY BAG	FERRIC (IRON) CARBOXYMALTOSE INFUSION 1000 MG IN SODIUM CHLORIDE 0.9% 250 ML BAG BY BAG	             0.00	  124212017.00
	iron polymaltose infusion xx mg in Sodiu	Pharmacy	iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx mL BAG BY BAG (PAED)	iron polymaltose infusion xx mg in Sodiu	Pharmacy	iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx mL BAG BY BAG (PAED)	IRON POLYMALTOSE INFUSION XX MG IN SODIUM CHLORIDE 0.9% XX ML BAG BY BAG (PAED)	             0.00	  139439010.00
	iron sucrose infusion 500 mg in Sodium C	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 500 mL BAG BY BAG	iron sucrose infusion 500 mg in Sodium C	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 500 mL BAG BY BAG	IRON SUCROSE INFUSION 500 MG IN SODIUM CHLORIDE 0.9% 500 ML BAG BY BAG	             0.00	  124212062.00
	iron polymaltose infusion 1000 mg in Sod	Pharmacy	iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 100 mL BAG BY BAG	iron polymaltose infusion 1000 mg in Sod	Pharmacy	iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 100 mL BAG BY BAG	IRON POLYMALTOSE INFUSION 1000 MG IN SODIUM CHLORIDE 0.9% 100 ML BAG BY BAG	             0.00	  124212038.00
	iron sucrose infusion 500 mg in Sodium C	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 250 mL BAG BY BAG - (RENAL)	iron sucrose infusion 500 mg in Sodium C	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 250 mL BAG BY BAG - (RENAL)	IRON SUCROSE INFUSION 500 MG IN SODIUM CHLORIDE 0.9% 250 ML BAG BY BAG - (RENAL)	             0.00	  124212055.00



O_CATALOG_DISP
iron polymaltose (>1g) infusion xx mg in
ferric (iron) carboxymaltose infusion xx
ferric (iron) carboxymaltose infusion 10
iron polymaltose infusion xx mg in Sodiu
iron sucrose infusion 500 mg in Sodium C
iron polymaltose infusion 1000 mg in Sod
iron sucrose infusion 500 mg in Sodium C

SYNONYM_ID
124212032
139426145
124212017
139439010
124212062
124212038
124212055


 */





SELECT

	O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	,O.CATALOG_CD
	, O.PRIMARY_MNEMONIC
	, OC.MNEMONIC
	, OC_CATALOG_DISP = UAR_GET_CODE_DISPLAY(OC.CATALOG_CD)
	, OC.MNEMONIC_KEY_CAP
	, OC.ORDER_SENTENCE_ID
	, OC.SYNONYM_ID

FROM
	ORDER_CATALOG   O
	, ORDER_CATALOG_SYNONYM   OC

PLAN O
	WHERE
	O.ACTIVE_IND =1
	AND
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
JOIN OC
	WHERE 
	OC.CATALOG_CD = O.CATALOG_CD

WITH NOCOUNTER, SEPARATOR=" ", FORMAT























/* 
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

*/