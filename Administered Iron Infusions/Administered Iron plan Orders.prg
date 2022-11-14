SELECT    
    O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
    , O.CATALOG_CD
FROM
    ORDERS   O

WHERE
	O.CATALOG_CD IN
        (
        124212029 ;iron polymaltose (>1g) infusion xx mg in Sodium Chloride 0.9
        , 139426142 ;ferric (iron) carboxymaltose infusion xx mg in Sodium Chlori
        , 124212014 ; ferric (iron) carboxymaltose infusion 1000 mg in Sodium Chlo
        , 139439007 ; iron polymaltose infusion xx mg in Sodium Chloride 0.9% xx m
        , 124212035 ; iron polymaltose infusion 1000 mg in Sodium Chloride 0.9% 10
        )
    AND
    O.ORIG_ORDER_DT_TM > CNVTLOOKBEHIND("1,D")



