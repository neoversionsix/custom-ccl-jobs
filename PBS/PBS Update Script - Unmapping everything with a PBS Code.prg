/* REMOVE INCORRECT PBS MAPPINGS--------------------------------
Note: This may unmap multiple rows because it select the PBS drug,
Use when you have mapped an incorrect PBS Code
eg if you wanted to upmap everything with "13Q" you would find it's
corresponding P_O_M.PBS_DRUG_ID and then use that to unmap it

*/
UPDATE INTO PBS_OCS_MAPPING P_O_M
SET
    ; End Date to 5 mins past midnight today
    P_O_M.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0005)
    ; Set the drug ID to the dummy number
    , P_O_M.PBS_DRUG_ID = 11111111
    ; Set the mapped Synonym to the dummy number
    , P_O_M.SYNONYM_ID = 1111111
    ; clear multum mapping (multum mappings are not used)
    , P_O_M.DRUG_SYNONYM_ID = 0
    ; clear multum mapping
    , P_O_M.MAIN_MULTUM_DRUG_CODE = 0
    ; clear multum mapping
    , P_O_M.DRUG_IDENTIFIER = "0"
    /* Update trail edits below */
    , P_O_M.UPDT_ID = REQINFO->UPDT_ID
    , P_O_M.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
WHERE
    /* Change Line below to select the PBS Drug ID to unmap */
    P_O_M.PBS_DRUG_ID = _PBS_DRUG_ID_ ; EDIT this "_PBS_DRUG_ID_"
/* -------------------------------------------------------------- */
