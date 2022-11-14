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
iron polymaltose (>1g) infusion xx mg in	  124212029.00	Pharmacy	iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9
ferric (iron) carboxymaltose infusion xx	  139426142.00	Pharmacy	ferric (iron) carboxymaltose infusion xx mg in Sodium Chlori
ferric (iron) carboxymaltose infusion 10	  124212014.00	Pharmacy	ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chlo
iron polymaltose infusion xx mg in Sodiu	  139439007.00	Pharmacy	iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx m
iron sucrose infusion 500 mg in Sodium C	  124212059.00	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 500 mL
iron polymaltose infusion 1000 mg in Sod	  124212035.00	Pharmacy	iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 10
iron sucrose infusion 500 mg in Sodium C	  124212052.00	Pharmacy	iron sucrose infusion 500 mg in Sodium Chloride 0.9% 250 mL
*/