drop program WHS_bulk_updates  go
create program WHS_bulk_updates

/*
This changes the Directory ind to 1 for users that
  1) edited by theperson running the script
  2) and updated in the last hour

Set Line 20 (E_U.DIRECTORY_IND = X) as below
  Indicates WHERE the user's password is maintained:
   -1       Not a directory user - User has to put in a username and pw manual login
    0       Use Authview default (show -defaults) - Have never used
    1       Is a directory user - Usual selection

;POST UPDATE CHECK SCRIPT:

SELECT
  E_U.USERNAME
  , E_U.DIRECTORY_IND
  , E_U.UPDT_DT_TM

FROM
  EA_USER E_U

WHERE
  E_U.USERNAME IN
  (SELECT USERNAME FROM PRSNL WHERE UPDT_ID = REQINFO->UPDT_ID AND UPDT_DT_TM > CNVTLOOKBEHIND("1,H"))

*/


prompt
	"Output to File/Printer/MINE" = "MINE"
WITH OUTDEV

;insert update scripts here
; DIRECTORY IND SCRIPT
UPDATE INTO EA_USER E_U
SET
  E_U.DIRECTORY_IND = 1
  ,E_U.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
  ,E_U.UPDT_ID = REQINFO->UPDT_ID
  ,E_U.UPDT_CNT = E_U.UPDT_CNT + 1

WHERE
  E_U.USERNAME IN
  (SELECT USERNAME FROM PRSNL WHERE UPDT_ID = REQINFO->UPDT_ID AND UPDT_DT_TM > CNVTLOOKBEHIND("1,H"))



END
GO