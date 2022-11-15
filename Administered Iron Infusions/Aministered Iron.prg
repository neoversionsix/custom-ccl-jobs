SELECT
	START_DATE = M.BEG_DT_TM "YYYY-DD-MM HH:MM:SS;;D"
	, END_DATE = M.END_DT_TM "YYYY-DD-MM HH:MM:SS;;D"
	, M.EVENT_ID
	, M.MED_ADMIN_EVENT_ID
	, M_EVENT_TYPE_DISP = UAR_GET_CODE_DISPLAY(M.EVENT_TYPE_CD)
	, M_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(M.NURSE_UNIT_CD)
	, M.PRSNL_ID
	, O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, O.CATALOG_CD

FROM
	MED_ADMIN_EVENT   M
	, ORDERS   O

PLAN M
	WHERE
	;TIME FILTER
	M.BEG_DT_TM > CNVTLOOKBEHIND("10,M")
	;FILTER FOR "ADMINISTERED" MEDICATIONS ONLY
	AND M.EVENT_TYPE_CD = 4093094  ;4093094 = Administered

JOIN O
	WHERE O.ORDER_ID = M.ORDER_ID
	AND
	O.CATALOG_CD IN
	(
	124212029 ;iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9
	, 139426142 ;ferric (iron) carboxymaltose infusion xx mg in Sodium Chlori
	, 124212014 ; ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chlo
	, 139439007 ; iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx m
	, 124212035 ; iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 10
	)

WITH NOCOUNTER, SEPARATOR=" ", FORMAT