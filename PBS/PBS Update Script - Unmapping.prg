;REMOVE INCORRECT PBS MAPPINGS--------------------------------
UPDATE INTO PBS_OCS_MAPPING OCSM
SET OCSM.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0005)
, OCSM.PBS_DRUG_ID = 11111111
, OCSM.UPDT_ID = REQINFO->UPDT_ID
, OCSM.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
/* Change Line below to include the PBS Drug ID to unmap */
WHERE OCSM.PBS_DRUG_ID = _PBS_DRUG_ID_
;--------------------------------------------------------------
