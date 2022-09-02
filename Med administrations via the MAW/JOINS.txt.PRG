MED_ADMIN_PT_ERROR      MED_ADMIN_PT_ERROR_ID  *    [BASE]
                        MED_ADMIN_ALERT_ID          [1]



MED_ADMIN_ALERT         MED_ADMIN_ALERT_ID  *       [1]
                        MED_ADMIN_EVENT_ID          [2]
                        PRSNL_ID


MED_ADMIN_EVENT         MED_ADMIN_EVENT_ID   *      [2]                        
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




FROM
    MED_ADMIN_PT_ERROR  MAPE
    , MED_ADMIN_ALERT   MAA
    , PRSNL             PR
    , MED_ADMIN_EVENT   MAE
    , CLINICAL_EVENT    CE
    , PERSON            P
    , ENCOUNTER         E
    , ORDERS            O                 

PLAN MAPE
    WHERE MAPE.UPDT_DT_TM > CNVTLOOKBEHIND("1,D")

JOIN MAA    WHERE   MAA.MED_ADMIN_ALERT_ID      = OUTERJOIN(MAPE.MED_ADMIN_ALERT_ID)
JOIN PR     WHERE   PR.PRSNL                    = OUTERJOIN(MAE.PRSNL_ID)
JOIN MAE    WHERE   MAE.MED_ADMIN_EVENT_ID      = OUTERJOIN(MAA.MED_ADMIN_EVENT_ID)
JOIN CE     WHERE   CE.EVENT_ID                 = OUTERJOIN(MAE.EVENT_ID)
JOIN P      WHERE   P.PERSON_ID                 = OUTERJOIN(CE.PERSON_ID)
JOIN E      WHERE   E.ENCNTR_ID                 = OUTERJOIN(CE.ENCNTR_ID)
JOIN O      WHERE   O.ORDER_ID                  = OUTERJOIN(CE.ORDER_ID)