    SELECT
    C_V.DESCRIPTION
    , PHONE =                                                           ; "PHONE" IN DESCRIPTION?
        IF (CNVTUPPER(C_V.DESCRIPTION)="*PHONE*") "Y"
        ELSE "N"
        ENDIF
    FROM C_V
    WHERE