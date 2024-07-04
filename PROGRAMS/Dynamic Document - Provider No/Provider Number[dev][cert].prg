/*****************************************************************************

        Source file name:       vic_signedby_prsnl.prg
        Object name:            vic_signedby_prsnl
        Request #:              NA

        Program purpose:		Load current user and provider number for current org into RTF window.

        Executing from:         Powerchart - Smart Template

        Special Notes:			Must be built as a smart template in code set 16529.

******************************************************************************/


;~DB~*******************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                     *
;    *******************************************************************************
;    *                                                                             *
;    *Mod Date       Engineer             Comment                                    *
;    *--- --------   -------------------- ------------------------------------------ *
;    *001 20/3/2012  Anthony Steele       Initial Release                            *
;    *002 20/11/2015 Mark Wakefield       Add Position to Output ER692979            *
;~DE~*******************************************************************************

; 4th of July 2024 - Jason Whittle - Pulling back the provider number for the
; specific hospital the encounter is for

;~END~ ***********************  END OF ALL MODCONTROL BLOCKS  **********************

drop program vic_signedby_prsnl:dba go
create program vic_signedby_prsnl:dba

%i cclsource:ma_rtf_tags.inc
%i cclsource:vic_ds_common_fonts.inc

; Program Constants
declare DEBUG_IND = i1 with constant(0), protect
declare ENCNTR_ID = f8 with constant(request->visit[1]->encntr_id), protect
declare provider_no = vc with noconstant(""), protect
declare position = vc with noconstant(""), protect

; Code vars
declare PROVIDER_NBR_CD = f8 with protect, constant(uar_get_code_by("MEANING",320,"PROVIDER NUM"))
declare GPPROVIDER_VAR = f8 with protect, Constant(uar_get_code_by("DISPLAYKEY",263,"GPPROVIDER"))
declare ENCOUNTER_HOSP_NAME = vc with noconstant(""), protect


; Declare reply struct
record reply(
  1 text = vc
  1 format = i4
%i cclsource:status_block.inc
 )

set reply->status_data.status = "F"

call ApplyFont(active_fonts->normal)

; Get loged in users name.
select into "nl:"
from prsnl p
plan p where p.person_id = reqinfo->updt_id
detail
	call PrintText(concat("Name: ",trim(p.name_full_formatted)),0,0,0)
	call NextLine(1)
	position = UAR_GET_CODE_DISPLAY(p.position_cd)

with nocounter


; Get logged in users provider nuber for the current encounters organisation.
select into "nl:"
from encounter e
	, org_alias_pool_reltn oapr
	, prsnl_alias pla1
	, prsnl_alias pla2

plan e where e.encntr_id = encntr_id

join oapr where oapr.organization_id = e.organization_id
and oapr.alias_entity_alias_type_cd = PROVIDER_NBR_CD
and oapr.active_ind = 1
and oapr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
and oapr.alias_pool_cd != GPPROVIDER_VAR

join pla1 where pla1.person_id = outerjoin(reqinfo->updt_id)
and pla1.alias_pool_cd = outerjoin(oapr.alias_pool_cd)
and pla1.prsnl_alias_type_cd = outerjoin(PROVIDER_NBR_CD)
and pla1.active_ind = outerjoin(1)
and pla1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
and pla1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))

join pla2 where pla2.person_id = reqinfo->updt_id
and pla2.prsnl_alias_type_cd = PROVIDER_NBR_CD
and pla2.active_ind = 1
and pla2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
and pla2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)

order by e.encntr_id
		, pla1.beg_effective_dt_tm
		, pla2.beg_effective_dt_tm

head e.encntr_id
	if(pla1.prsnl_alias_id > 0.0)
		provider_no = cnvtalias(pla1.alias,pla1.alias_pool_cd)
	elseif(pla2.prsnl_alias_id > 0.0)
		provider_no = cnvtalias(pla2.alias,pla2.alias_pool_cd)
	endif

with nocounter


; Format RTF Output
if(provider_no > " ")
	call PrintText(concat("Provider Number: ",provider_no),0,0,0)
else
	call PrintText("Provider Number:",0,0,0)
endif

if (position > " ")
		call Nextline(1)
		call PrintText(concat("Position: ",trim(position)),0,0,0)
else
		call PrintText("Position:",0,0,0)
endif


call FinishText(0)
; Load output to output desination.
if(DEBUG_IND = 1)
	call echo(rtf_out->text)
else
	set reply->text = rtf_out->text
endif

set reply->status_data.status = "S"

end
go
