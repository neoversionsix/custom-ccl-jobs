/*
PROGRAM NOTES
Completly rebuild of old HTS CODE to make it simple and pull back the
correct provider number for the patients encounter/hospital

CONTROL LOG
(1) 4th of July 2024 - Jason Whittle - Complete rebuild of old HTS CODE
old code can still be found by searching github repo for neoversionsix
*/

drop program vic_signedby_prsnl:dba go
create program vic_signedby_prsnl:dba

%i CUST_SCRIPT:ma_rtf_tags.inc
%i CUST_SCRIPT:vic_ds_common_fonts.inc

; Program Constants
declare ENCNTR_ID_VAR = f8 with constant(request->visit[1]->encntr_id), protect
declare PRSNL_ALIAS_TYPE_CD_VAR = f8 with constant(1090.00), protect ; "Provider No"

; Program variables
declare PROVIDER_NO_VAR = vc with noconstant(""), protect
declare POSITION_VAR = vc with noconstant(""), protect
declare ENCOUNTER_HOSP_NAME_VAR = vc with noconstant(""), protect
declare ALIAS_POOL_CD_VAR = f8 with noconstant(0.00), protect
declare DEBUG_IND_VAR = i1 with noconstant(0), protect


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
  HOSPITAL_NAME = REPLACE (UAR_GET_CODE_DISPLAY(e.LOC_FACILITY_CD), " ", "", 0)
FROM
	ENCOUNTER E
WHERE E.ENCNTR_ID = ENCNTR_ID_VAR
	AND E.ACTIVE_IND =1
HEAD REPORT
	ENCOUNTER_HOSP_NAME_VAR = HOSPITAL_NAME
WITH NOCOUNTER

SET ENCOUNTER_HOSP_NAME_VAR = CONCAT("*", ENCOUNTER_HOSP_NAME_VAR, "*")

; Get Alias pool code for the encounters location
SELECT INTO "NL:"
ALIAS_POOL_CODE = C_V.CODE_VALUE
FROM CODE_VALUE C_V
WHERE C_V.CODE_SET = 263 ; GP PROVIDER
	AND DISPLAY_KEY = "*WHS*"
	AND DISPLAY_KEY = "*PROVIDER*"
	AND DISPLAY_KEY = PATSTRING(ENCOUNTER_HOSP_NAME_VAR)
HEAD REPORT
	ALIAS_POOL_CD_VAR = ALIAS_POOL_CODE
WITH NOCOUNTER

; Get the provider number for the prsln and encounters location
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
HEAD REPORT
	PROVIDER_NO_VAR = PROVIDER_NO
WITH NOCOUNTER


; Format RTF Output
if(PROVIDER_NO_VAR > " ")
	call PrintText(concat(" IN DEVELOPMENT Provider Numberz: ",PROVIDER_NO_VAR),0,0,0)
else
	call PrintText("Provider Numberz:",0,0,0)
endif

if (POSITION_VAR > " ")
		call Nextline(1)
		call PrintText(concat("Positionz: ",trim(POSITION_VAR)),0,0,0)
else
		call PrintText("Positionz:",0,0,0)
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
