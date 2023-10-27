    , KEY_WORDS = CONCAT
        (
            TRIM(P_I.DRUG_NAME)
            , "|"
            , TRIM(P_D.FORM_STRENGTH)
            , "|"
            , TRIM(P_D.BRAND_NAME)
        )