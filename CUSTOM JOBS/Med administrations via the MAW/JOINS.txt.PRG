MED_ADMIN_PT_ERROR      MED_ADMIN_PT_ERROR_ID  *    [BASE]
                        MED_ADMIN_ALERT_ID          [1]



MED_ADMIN_ALERT         MED_ADMIN_ALERT_ID  *       [1]
                        MED_ADMIN_EVENT_ID          IS ALWAYS ZERO!!!!!!!!!!!
                        PRSNL_ID

MED_ADMIN_MED_ERROR     MED_ADMIN_MED_ERROR_ID *
                        MED_ADMIN_ALERT_ID ; this is just zeros in the join
                        ENCOUNTER_ID
                        ORDER_ID
                        PERSON_ID
                        TEMPLATE_ORDER_ID
                        EVENT_ID


MED_ADMIN_EVENT         MED_ADMIN_EVENT_ID   *                             
                        EVENT_ID
                        ORDER_ID                    [3]
                        TEMPLATE_ORDER_ID


ORDERS                  ORDER_ID *                  [3]
                        ENCNTR_ID                   [4]
                        GROUP_ORDER_ID
                        ORIGINATING_ENCNTR_ID
                        PERSON_ID
                        PRODUCT_ID
                        SYNONYM_ID

ENCOUNTER               ENCNTR_ID *                  [4]
                        ENCNTR_FINANCIAL_ID
                        PERSON_ID


CLINICAL_EVENT          EVENT_ID *
                        CLINICAL_EVENT_ID *
                        PERSON_ID
                        ENCNTR_ID


PRSNL                   PRSNL_ID


MED_ADMIN_RECORD        ORDER_ID *
                        MED_ADMIN_RECORD_ID *
                        ENCNTR_ID
                        PERSON_ID





FROM
    MED_ADMIN_PT_ERROR      MAPE
    , MED_ADMIN_ALERT       MAA
    , MED_ADMIN_MED_ERROR   MAME 
    , PRSNL                 PR
    , MED_ADMIN_EVENT       MAE
    , PERSON                P
    , ENCOUNTER             E
    , ORDERS                O                 

PLAN MAPE
    WHERE MAPE.UPDT_DT_TM > CNVTLOOKBEHIND("1,D")

JOIN MAA    WHERE   MAA.MED_ADMIN_ALERT_ID      = OUTERJOIN(MAPE.MED_ADMIN_ALERT_ID)
JOIN MAME   WHERE   MAME.MED_ADMIN_ALERT_ID     = OUTERJOIN(MAA.MED_ADMIN_ALERT_ID) ; THIS JOIN DOES NOT WORK!
JOIN PR     WHERE   PR.PERSON_ID                = OUTERJOIN(MAPE.UPDT_ID)
JOIN MAE    WHERE   MAE.EVENT_ID                = OUTERJOIN(MAME.EVENT_ID)
JOIN O      WHERE   O.ORDER_ID                  = OUTERJOIN(MAE.ORDER_ID)
JOIN P      WHERE   P.PERSON_ID                 = OUTERJOIN(O.PERSON_ID)
JOIN E      WHERE   E.ENCNTR_ID                 = OUTERJOIN(O.ENCNTR_ID)

WITH MAXREC = 2000, TIME=10





JOIN CE     WHERE   CE.EVENT_ID                 = OUTERJOIN(MAE.EVENT_ID)



4003287