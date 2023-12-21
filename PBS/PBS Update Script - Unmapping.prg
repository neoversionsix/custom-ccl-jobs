;REMOVE INCORRECT PBS MAPPINGS--------------------------------
UPDATE INTO PBS_OCS_MAPPING OCSM
SET
    /* End Date to 5 mins past midnight today */
    OCSM.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0005)
    /* Set the drug ID to the dummy number */
    , OCSM.PBS_DRUG_ID = 11111111
    , OCSM.UPDT_ID = REQINFO->UPDT_ID
    , OCSM.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)

WHERE
    /* Change Line below to select the PBS Drug ID to unmap */
    OCSM.PBS_DRUG_ID = _PBS_DRUG_ID_ ; EDIT this "_PBS_DRUG_ID_"
;--------------------------------------------------------------
