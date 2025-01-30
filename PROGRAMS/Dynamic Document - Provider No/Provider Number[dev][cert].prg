/*
PROGRAM NOTES
Output is found in the "Clinician Letter" after "yours sincerely" in the signature block
Open patient chart, click on add documentation, click on "Clinician Letter"

Complete rebuild of old HTS CODE to make it simple and pull back the
correct provider number for the patients encounter/hospital

CONTROL LOG
(1) 4th of July 2024 - Jason Whittle - Complete rebuild of old HTS CODE
old hts code can still be found here: https://github.com/neoversionsix/custom-ccl-jobs/blob/ef77bff2f7eef1532f6bca4ac64ac33886102a6d/PROGRAMS/Dynamic%20Document%20-%20Provider%20No/Provider%20Number%20original.prg
 30th Jan 2025 continuing developing and testing in cert
*/

drop program vic_signedby_prsnl:dba go
create program vic_signedby_prsnl:dba

%i CUST_SCRIPT:ma_rtf_tags.inc
%i CUST_SCRIPT:vic_ds_common_fonts.inc

; Program Constants
declare ENCNTR_ID_VAR = f8 with constant(request->visit[1]->encntr_id), protect
declare PRSNL_ALIAS_TYPE_CD_VAR = f8 with constant(1090.00), protect ; "Provider No"

; Program variables
declare PROVIDER_NO_VAR = vc with noconstant("non-recorded"), protect
declare POSITION_VAR = vc with noconstant("Position Placeholder"), protect
declare ENCOUNTER_HOSP_NAME_NOSPACE_VAR = vc with noconstant("Hospital not found"), protect
declare ENCOUNTER_HOSP_NAME_VAR = vc with noconstant("Hospital not found"), protect
declare HOSPITAL_DISPLAYKEY_VAR = vc with noconstant("PLACEHOLDER"), protect
declare ALIAS_POOL_CD_VAR = f8 with noconstant(0.00), protect
declare DEBUG_IND_VAR = i1 with noconstant(0), protect
declare HOSPITAL_DISPLAY_VAR = vc with noconstant("Hospital display placeholder"), protect

; Declare reply struct
record reply(
  1 text = vc
  1 format = i4
%i cclsource:status_block.inc
 )

set reply->status_data.status = "F"

call ApplyFont(active_fonts->normal)

; Get logged in users name and position
select into "nl:"
from prsnl p
plan p where p.person_id = reqinfo->updt_id
detail
	call PrintText(concat("Name: ",trim(p.name_full_formatted)),0,0,0)
	call NextLine(1)
	POSITION_VAR = UAR_GET_CODE_DISPLAY(p.position_cd)

with nocounter

; Get the encounters hospital location name
SELECT INTO "nl:"
  HOSPITAL_NAME_NOSPACE = REPLACE (UAR_GET_CODE_DISPLAY(e.LOC_FACILITY_CD), " ", "", 0)
  HOSPITAL_NAME = UAR_GET_CODE_DISPLAY(e.LOC_FACILITY_CD)
FROM
	ENCOUNTER E
WHERE E.ENCNTR_ID = ENCNTR_ID_VAR
	AND E.ACTIVE_IND =1
DETAIL
	ENCOUNTER_HOSP_NAME_NOSPACE_VAR = HOSPITAL_NAME_NOSPACE
	ENCOUNTER_HOSP_NAME_VAR = HOSPITAL_NAME
WITH NOCOUNTER

; Set the hospital name for use in title and patstring search
SET HOSPITAL_DISPLAYKEY_VAR = CNVTUPPER(ENCOUNTER_HOSP_NAME_NOSPACE_VAR)
SET HOSPITAL_DISPLAYKEY_VAR = CONCAT("*", HOSPITAL_DISPLAYKEY_VAR, "*")
SET HOSPITAL_DISPLAY_VAR = trim(ENCOUNTER_HOSP_NAME_VAR)
SET HOSPITAL_DISPLAY_VAR = CONCAT (" - ", HOSPITAL_DISPLAY_VAR, " Hospital")


; Get Provider Number Alias pool code for the encounters location
SELECT INTO "NL:"
ALIAS_POOL_CODE = C_V.CODE_VALUE
FROM CODE_VALUE C_V
WHERE C_V.CODE_SET = 263 ; GP PROVIDER
	AND C_V.DISPLAY_KEY = "*WHS*"
	AND C_V.DISPLAY_KEY = "*PROVIDER*"
	AND C_V.DISPLAY_KEY = PATSTRING(HOSPITAL_DISPLAYKEY_VAR)
DETAIL
	ALIAS_POOL_CD_VAR = ALIAS_POOL_CODE
WITH NOCOUNTER

; Get the provider number for the current user and encounters location
SELECT INTO "NL:"
	PROVIDER_NO = P_A.ALIAS
FROM
	PRSNL_ALIAS P_A
WHERE
	P_A.ACTIVE_IND = 1
	and P_A.ACTIVE_STATUS_CD = 188 ; ACTIVE
	and P_A.BEG_EFFECTIVE_DT_TM < sysdate
	and P_A.END_EFFECTIVE_DT_TM > sysdate
	AND P_A.ALIAS_POOL_CD = ALIAS_POOL_CD_VAR
	AND P_A.PRSNL_ALIAS_TYPE_CD = PRSNL_ALIAS_TYPE_CD_VAR
	AND P_A.PERSON_ID = (reqinfo->updt_id)
DETAIL
	PROVIDER_NO_VAR = PROVIDER_NO
WITH NOCOUNTER


; Format RTF Output
if(PROVIDER_NO_VAR > " ")
	call PrintText(concat("Provider Number: ",PROVIDER_NO_VAR, HOSPITAL_DISPLAY_VAR),0,0,0)
else
	call PrintText("Provider Number:",0,0,0)
endif

if (POSITION_VAR > " ")
		call Nextline(1)
		call PrintText(concat("Position: ",trim(POSITION_VAR)),0,0,0)
else
		call PrintText("Position:",0,0,0)
endif


call FinishText(0)
; Load output to output desination.
if(DEBUG_IND_VAR = 1)
	call echo(rtf_out->text)
else
	set reply->text = rtf_out->text
endif

set reply->status_data.status = "S"

end
go
