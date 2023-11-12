/************************************************************************
 *                      MODIFICATION CONTROL LOG                        *
 ************************************************************************
 *                                                                      *
 *Mod Date       Engineer             Comment                             *
 *--- --------   -------------------- ----------------------------------- *
 *00x 19/11/2015 Mark W				  Added Modification log
 *001 19/11/2015 Mark W				  Added Address line 3 to output
 *XXX 09/11/2023 Jason W              Fixed bug to pull most recent gp (not encounter based)
 ************************************************************************/


drop program wh_vic_gp_details_2 go
create program wh_vic_gp_details_2

%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

free record encntr_info
record encntr_info
(
  1 gp_consent          = c1
  1 gp_consent_cd       = f8
  1 gp_name             = vc
  1 gp_address_line_1   = vc
  1 gp_address_line_2   = vc
  1 gp_address_line_3	= vc
  1 gp_city             = vc
  1 gp_state            = vc
  1 gp_country          = vc
  1 gp_zipcode          = vc
  1 gp_phone            = vc
  1 gp_fax              = vc
)

declare GPVISIT       = f8 with constant(uar_get_code_by("DISPLAYKEY",333,"GENERALPRACTITIONER")),protect
declare FAXBUSINESS   = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS")) ,protect
declare PHONEBUSINESS = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS")) ,protect
declare ORG_ADDR_CD   = f8 with constant(uar_get_code_by("MEANING",212,"BUSINESS")),protect
;declare TECHNICALMETHOD   = f8 with constant(uar_get_code_by("DISPLAYKEY",212,"TECHNICAL"))
declare ADDRBUSINESS   = f8 with constant(uar_get_code_by("DISPLAYKEY",212,"BUSINESS"))
; declare ENCNTR_ID = f8 with constant(request->visit[1].encntr_id), protect
declare PERSON_ID_VAR = f8 with noconstant(request->person[1].person_id), protect ;002

; get gp_consent
select into "nl:"
from
  encounter e
plan
  e
where
  e.encntr_id = request->visit[1]->encntr_id
detail
  encntr_info->gp_consent = substring(1,1,UAR_GET_CODE_DISPLAY(e.courtesy_cd))
  encntr_info->gp_consent_cd = e.courtesy_cd
with
  nocounter

if(encntr_info->gp_consent != "N")

  select into "nl:"
  from
    encntr_prsnl_reltn epr,
    person pr,
    dummyt d1,
    address a,
    dummyt d2,
    phone p
  plan
    epr
  where
    epr.encntr_id =
      (select encntr_id from encounter where person_id = PERSON_ID_VAR and active_ind=1) and
    epr.ENCNTR_PRSNL_R_CD = GPVISIT and
    epr.active_ind = 1 and
    epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
    epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) and
    epr.beg_effective_dt_tm =
        (
        select max(epr1.beg_effective_dt_tm)
		    from encntr_prsnl_reltn epr1
        where
		      epr1.encntr_prsnl_r_cd = GPVISIT
		      and epr1.active_ind = 1
		      and epr1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
          and epr1.encntr_id in
            (select encntr_id from encounter where person_id = PERSON_ID_VAR and active_ind=1)
        )
  join
    pr
  where
    pr.person_id = epr.prsnl_person_id
  join
    d1
  join
    a
  where
    a.parent_entity_id = pr.person_id and
    a.address_type_cd = ADDRBUSINESS and
    a.active_ind =1 and
    (a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) or
     a.end_effective_dt_tm = null)
  join
    d2
  join
    p
  where
    p.parent_entity_id = a.parent_entity_id and
    p.active_ind = 1 and
    (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) or
     p.end_effective_dt_tm = null)
  detail

    if(epr.prsnl_person_id = 0)
      encntr_info->gp_name = epr.ft_prsnl_name
    else
      encntr_info->gp_name = pr.name_full_formatted
    endif

    encntr_info->gp_address_line_1  = a.street_addr
    encntr_info->gp_address_line_2  = a.street_addr2
    encntr_info->gp_address_line_3  = a.street_addr3
    encntr_info->gp_city            = a.city
    encntr_info->gp_state           = a.state
    encntr_info->gp_zipcode         = trim(a.zipcode,3)

    if(p.phone_type_cd = phonebusiness)
      encntr_info->gp_phone = p.phone_num
    elseif (p.phone_type_cd = faxbusiness)
      encntr_info->gp_fax = p.phone_num
    endif
  with
    dontcare=a,
    outerjoin=d2
endif

call echorecord(encntr_info)

call ApplyFont(active_fonts->normal)
if(encntr_info->gp_consent != "N")

  ; gp consent
  ;call PrintText("GP Consent:",1,0,0)
;   if(encntr_info->gp_consent_cd = 0)
;     call PrintText("**GP consent status unknown**",1,0,0)
;     call NextLine(1)
;   ;else
;    ; call PrintText(uar_get_code_display(encntr_info->gp_consent_cd),0,0,0)
;     ;call NextLine(1)
;   endif

  ; gp name
  call PrintText("Name: ",0,0,0)
  declare tempName = vc
  set tempName = trim(encntr_info->gp_name,3)
  call PrintText(build2(tempName),0,0,0)
  ;call PrintText(build2(" ",encntr_info->gp_name))
  call NextLine(1)

  ; address
  declare tempStr = vc
  call PrintText("Address:",0,0,0)
  set tempStr = build2(" ",trim(encntr_info->gp_address_line_1,3))
  if(textlen(encntr_info->gp_address_line_2) > 1)
    set tempStr = build2(tempStr,", ",trim(encntr_info->gp_address_line_2,3))
  endif
  if(textlen(encntr_info->gp_address_line_3) > 1)
    set tempStr = build2(tempStr,", ",trim(encntr_info->gp_address_line_3,3))
  endif
  if(textlen(encntr_info->gp_city) > 1)
    set tempStr = build2(tempStr,", ",encntr_info->gp_city)
  endif
  if(textlen(encntr_info->gp_state) > 1)
      set tempStr = build2(tempStr,", ",encntr_info->gp_state)
  endif
  if(textlen(encntr_info->gp_zipcode) > 1)
    set tempStr = build2(tempStr," ",encntr_info->gp_zipcode)
  endif
  if(textlen(encntr_info->gp_country) > 1)
    set tempStr = build2(tempStr,", ",encntr_info->gp_country)
  endif
  call PrintText(tempStr,0,0,0)
  call NextLine(1)

  ; phone
  call PrintText("Phone:",0,0,0)
  call PrintText(build2(" ",encntr_info->gp_phone),0,0,0)

  ; fax
  call PrintText("  Fax:",0,0,0)
  call PrintText(build2(" ",encntr_info->gp_fax),0,0,0)
  call NextLine(1)

else

  ;call PrintText("GP Consent: ",1,0,0)
  call PrintText("**Patient has not given consent to send their GP information regarding this stay in hospital**",1,0,0)
  call NextLine(1)
  call ApplyFont(active_fonts->normal2)

endif

call FinishText(0)
set reply->text = rtf_out->text

end
go