SELECT
    ORD.ORIG_ORDER_DT_TM "dd/mm/yyyy hh:mm"
    , M.BEG_DT_TM "dd/mm/yyyy hh:mm"
    , M.END_DT_TM "dd/mm/yyyy hh:mm"
    , M_EVENT_TYPE_DISP = UAR_GET_CODE_DISPLAY(M.EVENT_TYPE_CD)
    , ORD.ORDER_MNEMONIC
    , O_I.ORDER_MNEMONIC
    , E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , M_NURSE_UNIT_DISP = UAR_GET_CODE_DISPLAY(M.NURSE_UNIT_CD)
    , O_I.ORDER_ID
    , URN = PA.ALIAS
FROM
    ORDER_DETAIL   O_D
    , ORDER_INGREDIENT   O_I
    , ORDERS   ORD
    , ENCOUNTER   E
    , MED_ADMIN_EVENT   M
    , PERSON_ALIAS PA
PLAN O_D
    WHERE
        O_D.OE_FIELD_VALUE = 318173.00 ;"IV Infusion"
        AND
        O_D.UPDT_DT_TM BETWEEN
            CNVTDATETIME("01-FEB-2019 00:00:00.00")
            AND
            CNVTDATETIME("03-FEB-2023 00:00:00.00")
        ; > CNVTLOOKBEHIND("3,D")
JOIN O_I
    WHERE O_I.ORDER_ID = O_D.ORDER_ID
        AND
        O_I.CATALOG_CD IN( ; Iron additives for infusions
            ;9814704 ; ferric carboxymaltose
           ; , 9742085 ; iron sucrose
             9741951 ; iron polymaltose
        )
        AND
        O_I.ACTION_SEQUENCE = 1; filter out duplicate rows in this table
JOIN ORD
    WHERE ORD.ORDER_ID = O_I.ORDER_ID
JOIN E
    WHERE E.ENCNTR_ID = ORD.ENCNTR_ID
JOIN M
    WHERE M.ORDER_ID =O_D.ORDER_ID

JOIN PA
    WHERE PA.PERSON_ID = E.PERSON_ID
    AND
   	PA.ALIAS_POOL_CD = 9569589.00 ; this filters for the UR Number
	AND
	PA.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
    AND
    PA.ACTIVE_IND = 1


ORDER BY
    O_I.ORDER_ID
    , M.BEG_DT_TM
WITH TIME = 60,
    NOCOUNTER,
    SEPARATOR=" ",
    FORMAT