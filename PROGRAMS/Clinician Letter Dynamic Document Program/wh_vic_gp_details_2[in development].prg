/**************************************************************************************************
 *                      MODIFICATION CONTROL LOG                                                  *
 **************************************************************************************************
 *                                                                                                *
 *Mod Date       Engineer             Comment                                                     *
 *--- --------   -------------------- ------------------------------------------------------------*
 *00x 19/11/2015 Mark W				  Added Modification log
 *001 19/11/2015 Mark W				  Added Address line 3 to output
 *XXX 09/11/2023 Jason W        Fixed bug to pull most recent gp (not
                                filtering for specific encounter)
 *XXX 09/05/2024 Jason W        Pulling GP from the same table as GP View Mpage.
                                encntr_prsnl_reltn was pulling the most recent
                                gp from that table without a match on the
                                specific encounter. Turns out It needs to pull the
                                data from person_prsnl_reltn table. Changed the name of the
                                program to wh_gp_details_person from wh_vic_gp_details_2
                                this is basically a complete rewrite of the program.
 *************************************************************************************************/


drop program wh_gp_details_person go
create program wh_gp_details_person

%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

free record encntr_info
record encntr_info
(
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

declare GPVISIT_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY",333,"GENERALPRACTITIONER")),protect
declare FAXBUSINESS_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS")) ,protect
declare PHONEBUSINESS_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS")) ,protect
declare ADDRBUSINESS_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",212,"BUSINESS"))
declare PERSON_ID_VAR = f8 with noconstant(request->person[1].person_id), protect ;002



select into "nl:"
from
  ;encntr_prsnl_reltn epr, ; JW - deactivating this table
  person_prsnl_reltn P_P_R, ; JW - using this table instead
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
  epr.ENCNTR_PRSNL_R_CD = GPVISIT_VAR and
  epr.active_ind = 1 and
  epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
  epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) and
  epr.beg_effective_dt_tm =
      (
      select max(epr1.beg_effective_dt_tm)
    from encntr_prsnl_reltn epr1
      where
      epr1.encntr_prsnl_r_cd = GPVISIT_VAR
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
  a.address_type_cd = ADDRBUSINESS_VAR and
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
  if(p.phone_type_cd = PHONEBUSINESS_VAR)
    encntr_info->gp_phone = p.phone_num
  elseif (p.phone_type_cd = FAXBUSINESS_VAR)
    encntr_info->gp_fax = p.phone_num
  endif
with
  dontcare=a,
  outerjoin=d2


call echorecord(encntr_info)

call ApplyFont(active_fonts->normal)

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


call FinishText(0)
set reply->text = rtf_out->text

end
go