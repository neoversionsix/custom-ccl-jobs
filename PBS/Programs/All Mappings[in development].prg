drop program wh_pbs_unmapped go
create program wh_pbs_unmapped

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV

SELECT INTO $OUTDEV
/*
NOTES:
current mappings.
 */
      PBS_CODE = P_L.PBS_ITEM_CODE
    , PBS_PRIMARY_DRUG_NAME = P_I.DRUG_NAME
    , PBS_BRAND_NAME = P_D.BRAND_NAME
    , PBS_MNEMONIC_FORM_STRENGTH = P_D.FORM_STRENGTH
    , PBS_PRODUCT_PACKAGE_SIZE = P_D.PACK_SIZE
    , MAP_PBS_DRUG_ID = P_D.PBS_DRUG_ID
    , PBS_SCHEDULE = P_L.DRUG_TYPE_MEAN
    , PBS_ITEM_BEG_DATE = FORMAT(P_I.BEG_EFFECTIVE_DT_TM, "DD/MMM/YYYY HH:MM")
    , PBS_ITEM_END_DATE = FORMAT(P_I.END_EFFECTIVE_DT_TM, "DD/MMM/YYYY HH:MM")
	, PBS_PRODUCT_BEG_DATE = FORMAT(P_D.BEG_EFFECTIVE_DT_TM, "DD/MMM/YYYY HH:MM")
	, PBS_PRODUCT_END_DATE = FORMAT(P_D.END_EFFECTIVE_DT_TM, "DD/MMM/YYYY HH:MM")

FROM
      PBS_OCS_MAPPING           P_O_M
    , ORDER_CATALOG_SYNONYM     O_C_S
    , PBS_LISTING               P_L
    , PBS_ITEM                  P_I
    , PBS_DRUG                  P_D

PLAN P_O_M; PBS_OCS_MAPPING
    WHERE
        /* Get Mappings that are not expired at this time */
        P_O_M.END_EFFECTIVE_DT_TM > SYSDATE

JOIN O_C_S ;ORDER_CATALOG_SYNONYM
    WHERE O_C_S.SYNONYM_ID = P_O_M.SYNONYM_ID

JOIN P_D ; PBS_DRUG
    P_D.PBS_DRUG_ID = P



JOIN P_I ; PBS_ITEM
    WHERE P_I.PBS_ITEM_ID = P_D.PBS_ITEM_ID


JOIN	P_L ; PBS_LISTING
        WHERE P_L.PBS_LISTING_ID = P_I.PBS_LISTING_ID

WITH TIME = 20,
	NOCOUNTER,
	SEPARATOR=" ",
	FORMAT

end
go
