drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*
Notes:
Deactivates all clinical Events for an encounter
Note: This has never been used!
*/

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

UPDATE INTO CLINICAL_EVENT   C_E
  SET
    C_E.VIEW_LEVEL = 0 ; not viewable
    , C_E.VALID_UNTIL_DT_TM = CNVTDATETIME(CURDATE,CURTIME3) ; not valid
    /* Update Trail Updates Below */
    , C_E.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , C_E.UPDT_ID = REQINFO->UPDT_ID
    , C_E.UPDT_CNT = E_U.UPDT_CNT + 1

END
GO