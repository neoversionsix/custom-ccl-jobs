DROP PROGRAM WH_EXAMPLE_PROGRAM_1 GO ; Removes existing object
CREATE PROGRAM WH_EXAMPLE_PROGRAM_1 ; Creates object

PROMPT ; Prompt command for accepting parameters
    "Output to File/Printer/Mine" = "MINE"  ; VARIABLE 1 By default will display the output on screen
    , "Enter a Begin Date" = CURDATE        ; VARIABLE 2 default input in current date
    , "Enter an End Date" = CURDATE         ; VARIABLE 3 default input in current date

WITH
    OUTDEV          ; VARIABLE 1
    , BEG_DATE      ; VARIABLE 2
    , END_DATE      ; VARIABLE 3
    
SELECT INTO $OUTDEV
    E.ENCNTR_ID

FROM
    ENCOUNTER E

WHERE 
    E.REG_DT_TM
    BETWEEN
        CNVTDATETIME($BEG_DATE) ; VARIABLE 2
        AND
        CNVTDATETIME($END_DATE) ; VARIABLE 3

WITH NOCOUNTER
END ; Closes Object
GO ; Required, execute command
