/*
SELECT SCRIPT FOR BEFORE AND AFTER CHANGES
Notes: The update script is to unmap a specific synonym from a specific pbs
item in a specific environment. A non environment specific update script will
have to identify by the P_O_M.SYNONYM_ID and P_O_M.PBS_DRUG_ID combination
 */

SELECT
; RUN BEFORE MAKING CHANGES you will need to edit the where clause first

      P_O_M.PBS_OCS_MAPPING_ID
    , P_O_M.PBS_DRUG_ID
    , P_O_M.SYNONYM_ID
    , P_O_M.DRUG_SYNONYM_ID
    , P_O_M.MAIN_MULTUM_DRUG_CODE
    , P_O_M.DRUG_IDENTIFIER
    , P_O_M.UPDT_ID
    , P_O_M.UPDT_DT_TM
    , P_O_M.END_EFFECTIVE_DT_TM
FROM PBS_OCS_MAPPING P_O_M
WHERE
    ; Change Line below to select the PBS Drug ID to unmap
    P_O_M.PBS_OCS_MAPPING_ID IN (160429007, 160429285) ; $$$$$$$$EDIT THIS LINE!!!!!!!!!!
; --------------------------------------------------------------


/*
UPDATE SCRIPT FOR MAKING CHANGES
Notes: The update script is to unmap a specific synonym from a specific pbs
item in a specific environment. A non environment specific update script will
have to identify by the P_O_M.SYNONYM_ID and P_O_M.PBS_DRUG_ID combination
 */

;REMOVE INCORRECT PBS MAPPINGS-------------------------------- */
UPDATE INTO PBS_OCS_MAPPING P_O_M
SET
    /* End Date to 5 mins past midnight today */
    P_O_M.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0005)
    /* Set the drug ID to the dummy number */
    , P_O_M.PBS_DRUG_ID = 11111111
    ; clear multum mapping (multum mappings are not used)
    , P_O_M.DRUG_SYNONYM_ID = 0
    ; Set the mapped Synonym to the dummy number
    , P_O_M.SYNONYM_ID = 1111111
    ; clear multum mapping
    , P_O_M.MAIN_MULTUM_DRUG_CODE = 0
    ; clear multum mapping
    , P_O_M.DRUG_IDENTIFIER = "0"
    /* Update trail edits below */
    , P_O_M.UPDT_ID = REQINFO->UPDT_ID
    , P_O_M.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
WHERE
    /* Change Line below to select the PBS Drug ID to unmap */
    P_O_M.PBS_OCS_MAPPING_ID IN (82230624.00) ; $$$$$$$$$EDIT THIS LINE!!!!!!!!!!
/* -------------------------------------------------------------- */
