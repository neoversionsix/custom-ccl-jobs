/* REMOVE INCORRECT PBS MAPPINGS-------------------------------- */
UPDATE INTO PBS_OCS_MAPPING P_O_M
SET
    /* End Date to 5 mins past midnight today */
    P_O_M.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0005)
    /* Set the drug ID to the dummy number */
    , P_O_M.PBS_DRUG_ID = 11111111
    /* Update trail edits below */
    , P_O_M.UPDT_ID = REQINFO->UPDT_ID
    , P_O_M.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
WHERE
    /* Change Line below to select the PBS Drug ID to unmap */
    P_O_M.PBS_DRUG_ID = _PBS_DRUG_ID_ ; EDIT this "_PBS_DRUG_ID_"
/* -------------------------------------------------------------- */
