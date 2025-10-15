;____________________________________________________________________________________________________________
; This Script Is used for mapping a PBS Code to a Catalog Item
; It edits an unused line in the pbs_ocs_mapping table and switches the
; PBS_DRUG_ID and SYNONYM_ID to the ones that are now related

; Checker Script - recent updated lines by you
; select * from pbs_ocs_mapping where updt_dt_tm > cnvtlookbehind("1,H") and updt_id = reqinfo->updt_id
;____________________________________________________________________________________________________________

;____________________________________________________________________________________________________________
; PBS update mapping script for:
; PBS_DRUG_ID = MAP_PBS_DRUG_ID_
; SYNONYM_ID = MAP_SYNONYM_ID_
; CATALOG_PRIMARY ; Catalog Primary Name
; CATALOG_MNEMONIC = O_C_S.MNEMONIC ; The Synonym mnemonic
; CATALOG_MNEMONIC_TYPE = UAR_GET_CODE_DISPLAY(O_C_S.MNEMONIC_TYPE_CD) ; The Synonym Type
; PBS_CODE = P_L.PBS_ITEM_CODE ; The PBS Item Code
; PBS_PRIMARY = P_I.DRUG_NAME ; The PBS Primary Name
; PBS_BRAND = P_D.BRAND_NAME ; The PBS Brand Name
; PBS_FORM_STRENGTH = P_D.FORM_STRENGTH ; The PBS Form and Strength

UPDATE INTO PBS_OCS_MAPPING P_O_M
SET
    P_O_M.BEG_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE, 0004)
    ; ABOVE LINE SETS THE ACTIVATION TIME TO TODAY AT 12:04 AM, USED TO IDENTIFY THIS TYPE OF UPDATE
    , P_O_M.END_EFFECTIVE_DT_TM = CNVTDATETIME("31-DEC-2100")
    /*CHANGE THE ROW BELOW MAP_PBS_DRUG_ID_*/
    , P_O_M.PBS_DRUG_ID = MAP_PBS_DRUG_ID_ ; SWAP WITH PBS DRUG ID THAT MAPS TO THE SYNONYM ID
    /*CHANGE THE ROW BELOW MAP_SYNONYM_ID_*/
    , P_O_M.SYNONYM_ID = MAP_SYNONYM_ID_ ; SWAP WITH SYNONYM ID THAT MAPS TO THE PBS_DRUG_ID
    , P_O_M.DRUG_SYNONYM_ID = 0 ; CLEAR MULTUM MAPPING (MULTUM MAPPINGS ARE NOT USED)
    , P_O_M.MAIN_MULTUM_DRUG_CODE = 0 ; CLEAR MULTUM MAPPING
    , P_O_M.DRUG_IDENTIFIER = "0" ; CLEAR MULTUM MAPPING
    , P_O_M.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , P_O_M.UPDT_ID = REQINFO->UPDT_ID
    , P_O_M.UPDT_CNT = P_O_M.UPDT_CNT + 1
WHERE
    ;UPDATE THE NEXT UNUSED ROW
    P_O_M.PBS_OCS_MAPPING_ID =
    (SELECT MIN(PBS_OCS_MAPPING_ID) FROM PBS_OCS_MAPPING WHERE END_EFFECTIVE_DT_TM < SYSDATE)
    ; ONLY UPDATE IF THE MAPPING IS NOT ALREADY PRESENT
    AND NOT EXISTS
    (
        SELECT 1
        FROM PBS_OCS_MAPPING
        /*CHANGE THE ROW BELOW MAP_PBS_DRUG_ID_*/
        WHERE PBS_DRUG_ID = MAP_PBS_DRUG_ID_ ; SWAP WITH PBS DRUG ID
        /*CHANGE THE ROW BELOW MAP_SYNONYM_ID_*/
        AND SYNONYM_ID = MAP_SYNONYM_ID_ ; SWAP WITH SYNONYM ID
        AND END_EFFECTIVE_DT_TM > SYSDATE
    )
;____________________________________________________________________________________________________________