SELECT
    NO_SCAN_REASON              = UAR_GET_CODE_DISPLAY(MAPE.REASON_CD)
	, DT_COMPLETED              = MAPE.UPDT_DT_TM "YYYY-MM-DD HH:MM:SS;;D"
	, DT_COMPLETED_YEAR         = MAPE.UPDT_DT_TM "YYYY;;D"
	, DT_COMPLETED_MONTH        = MAPE.UPDT_DT_TM "MM;;D"
	, DT_COMPLETED_DAY          = MAPE.UPDT_DT_TM "DD;;D"
	, DT_COMPLETED_TIME         = MAPE.UPDT_DT_TM "HH:MM:SS;;D"
	, SOURCE_APP                = EVALUATE(
		                        MAE.SOURCE_APPLICATION_FLAG
		                        , 0, "Default - no value"
		                        , 1, "Care Mobil"
		                        , 2, "MAW (Care Admin in DB)"
		                        , 3, "MAR (PowerChart in DB)"
		                        )
	, ORDERED                   = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, STAFF                     = PR.NAME_FULL_FORMATTED
	, E_LOC_NURSE_UNIT_DISP     = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
    , E_MED_SERVICE_DISP        = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , SCANNED                   = MAE.POSITIVE_PATIENT_IDENT_IND
    
    , MAPE_MED_ADMIN_ALERT_ID   = MAPE.MED_ADMIN_ALERT_ID
    , MAME_MED_ADMIN_ALERT_ID   = MAME.MED_ADMIN_ALERT_ID
    , MAPE_UPDT_ID              = MAPE.UPDT_ID
    , PR_PERSON_ID              = PR.PERSON_ID
    , MAME_EVENT_ID             = MAME.EVENT_ID
    , MAE_EVENT_ID              =  MAE.EVENT_ID
    , MAE_ORDER_ID              = MAE.ORDER_ID
    , O_ORDER_ID                = O.ORDER_ID
    , O_PERSON_ID               = O.PERSON_ID
    , P_PERSON_ID               = P.PERSON_ID
    , O_ENCNTR_ID               = O.ENCNTR_ID
    , E_ENCNTR_ID               = E.ENCNTR_ID

FROM
    MED_ADMIN_PT_ERROR      MAPE
    , MED_ADMIN_MED_ERROR   MAME
    , PRSNL                 PR
    , MED_ADMIN_EVENT       MAE
    , PERSON                P
    , ENCOUNTER             E
    , ORDERS                O                 

PLAN MAPE
    WHERE MAPE.UPDT_DT_TM > CNVTLOOKBEHIND("1,D")

JOIN MAME   WHERE   MAME.MED_ADMIN_ALERT_ID     = OUTERJOIN(MAPE.MED_ADMIN_ALERT_ID)
JOIN PR     WHERE   PR.PERSON_ID                = OUTERJOIN(MAPE.UPDT_ID)
JOIN MAE    WHERE   MAE.EVENT_ID                = OUTERJOIN(MAME.EVENT_ID)
JOIN O      WHERE   O.ORDER_ID                  = OUTERJOIN(MAE.ORDER_ID)
JOIN P      WHERE   P.PERSON_ID                 = OUTERJOIN(O.PERSON_ID)
JOIN E      WHERE   E.ENCNTR_ID                 = OUTERJOIN(O.ENCNTR_ID)

WITH MAXREC = 2000, TIME=10