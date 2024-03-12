/*****************************************************************************

        Source file name:       vic_gp_add_recip_ds_details.prg
        object name:            vic_gp_add_recip_ds_details

        Program purpose:		To display GP and additional reciepiant details in a Genview, including Fax and electronic
        						transmission details.

        Executing from:         Powerchart

        Special Notes:

******************************************************************************


;~DB~*******************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                     *
;    *******************************************************************************
;    *                                                                             *
;    *Mod Date     Engineer             Comment                                    *
;    *--- -------- -------------------- ------------------------------------------ *
;    *001 MAY 2012 Anthony Steele       Initial Development                        *
;	 *002 JUN 2016 Mark Wakefield		added MyHealth Consent Flag to output
;										for (ER753640)
	  003 Sep 2016 Grant W				RNET changes:
	  									Display both HEALTHLINK and RNET identifiers
	  									in GP Details / Electronic Identifier


;    *020 Feb 2024 Jason Whittle		Bug Fix - Changing Latest GP to pull from
										PERSON_PRSNL_RELTN and no longer from ENCNTR_PRSNL_RELTN. This is
										because it's actually stored in the PERSON_PRSNL_RELTN table.

;~DE~*******************************************************************************/

drop program vic_gp_add_recip_ds_details:dba go
create program vic_gp_add_recip_ds_details:dba

; Include standard rtf includes
%i cclsource:ma_rtf_tags.inc
%i cclsource:vic_ds_common_fonts.inc

record enc (
  1 consent_flag = c1
  1 inactive_gp_flag = i1
  1 cnt = i2
 ; 1 max_recips_cnt = i4
 ; 1 recips_cnt = i4
 1 MyHealth_consent = vc ;002
  1 gps[*]
    2 recips_cnt = i4
    2 max_recips_cnt = i4
    2 person_id = f8
    2 ref_person_id = f8
    2 name_title = vc
    2 name_first = vc
    2 name_middle = vc
    2 name_last = vc
    2 patdocname = vc
    2 Freetext_recip = vc
    2 recip_ft    = vc
    2 name_free_text = vc
    2 enc_gp_flag = i1
    2 latest_gp_flag = i1
    2 referring_gp_flag = i1
    2 fax_flag = i1
    2 address_line_1 = vc
    2 address_line_2 = vc
    2 city = vc
    2 state = vc
    2 country = vc
    2 zipcode = vc
    2 phone = vc
    2 fax = vc
    2 fax_2 = vc
    2 area_code = vc
    2 fax_exchange = vc
    2 phone_suffix = vc
    2 ARGUS	= vc			;003
    2 helthelink = vc
    2 RNET = vc				;003
    2 helthlink_flag = i1 	;003 No longer used
)

declare ENCNTR_ID = f8 with constant(request->visit[1].encntr_id), protect
;declare ENCNTR_ID = f8 with constant(18868491.00), protect; - TESTING
declare PERSON_ID = f8 with noconstant(request->person[1].person_id), protect ;002

declare FAX_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",333,"FAXDISCHARGESUMMARY")), protect
declare GP_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",333,"GENERALPRACTITIONER")), protect
declare REFERDOC_CD = f8 with constant(uar_get_code_by("MEANING",333,"REFERDOC")), protect
declare PRSNL_CD = f8 with constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
declare BUSINESS_ADDR_CD = f8 with constant(uar_get_code_by("MEANING",212,"BUSINESS")), protect
declare FAX_PHONE_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS")), protect
declare BUSINESS_PHONE_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS")), protect
declare ARGUS_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",263,"ARGUS")), protect
declare HEALTHLINK_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",263,"HEALTHLINK")), protect
declare RNET_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",263,"RNET")), protect ;003

declare idx = i4 with noconstant(0), protect
declare pat_ed_document_flex = vc with noconstant(""), protect
declare outstring = vc with noconstant(""), protect
declare outstringfax = vc with noconstant(""), protect
declare enc_gp_heading_flag  = i1 with noconstant(0), protect
declare latest_gp_heading_flag  = i1 with noconstant(0), protect
declare ref_gp_heading_flag  = i1 with noconstant(0), protect
declare add_rec_heading_flag = i1 with noconstant(0), protect
declare dont_print_flag = i1 with noconstant(0), protect

declare UDF_CD = f8 with constant(uar_get_code_by("MEANING", 355, "USERDEFINED")) ;002
declare PCEHR_UDF_CD = f8 with constant(uar_get_code_by("MEANING", 356, "PCEHR_PATCON"))  ;002

; Latest person GP
select into "nl:"
from encounter e
	, encounter e2
	, encntr_prsnl_reltn epr
	, person_prsnl_reltn p_r_r
	, prsnl pl
	, person_name pn

plan p_r_r ;person_prsnl_reltn
	where p_r_r.person_id = PERSON_ID ; related to this patient
	and p_r_r.active_ind = 1 ; active
	and p_r_r.PERSON_PRSNL_R_CD = 1115.00 ; Primary Care Physician
	and p_r_r.BEG_EFFECTIVE_DT_TM =
		(
			select max (p_r_r_inline.beg_effective_dt_tm)
			from person_prsnl_reltn p_r_r_inline
			where
				p_r_r_inline.person_id = PERSON_ID ; related to this patient
				and p_r_r_inline.active_ind = 1 ; active
				and p_r_r_inline.PERSON_PRSNL_R_CD = 1115.00 ; Primary Care Physician
		)

/*
plan e where e.encntr_id = ENCNTR_ID

join e2 where e2.person_id = e.person_id+0
;and e2.organization_id = e.organization_id;should look across  all encounters for the patient
;regardless of organization
and e2.active_ind = 1

join epr where epr.encntr_id = e2.encntr_id
and epr.encntr_prsnl_r_cd = GP_CD
and epr.active_ind = 1
and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
and epr.beg_effective_dt_tm = (select max(epr1.beg_effective_dt_tm)
								from encntr_prsnl_reltn epr1
									, encounter e3

								where e3.person_id = e.person_id
								and e3.active_ind = 1 ;must be on a noncancelled encounter
														and epr1.encntr_id = e3.encntr_id
								and epr1.encntr_prsnl_r_cd = GP_CD
								and epr1.active_ind = 1
								and epr1.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
								)
*/

join pl where pl.person_id = outerjoin(p_r_r.prsnl_person_id)

join pn where pn.person_id = outerjoin(pl.person_id)
and pn.name_type_cd = outerjoin(PRSNL_CD)
and pn.active_ind = outerjoin(1)
and pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
and pn.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))

order by p_r_r.beg_effective_dt_tm desc
		, pl.person_id

head report
	cnt = enc->cnt

head pl.person_id
	cnt = cnt+1
	stat = alterlist(enc->gps,cnt) ; should only be 1 GP
	if(pl.person_id > 0.0)
		enc->gps[cnt].person_id = pl.person_id
		enc->gps[cnt].name_title = pn.name_prefix
		enc->gps[cnt].name_first = pl.name_first
		enc->gps[cnt].name_middle = pn.name_middle
		enc->gps[cnt].name_last = pl.name_last
	else
		enc->gps[cnt].name_free_text = p_r_r.ft_prsnl_name
	endif
	enc->gps[cnt].latest_gp_flag = 1

foot report
	enc->cnt = cnt
 	PERSON_ID = e.person_id ;002 - to save looking it up again
with nocounter



; Load Encounter GP and Referring Doctor
select into "nl:"
sorter = if(epr.encntr_prsnl_r_cd = GP_CD) 1 else 2 endif
from encntr_prsnl_reltn epr
	, prsnl pl
	, person_name pn

plan epr where epr.encntr_id = ENCNTR_ID
;and c = GP_CD
and epr.encntr_prsnl_r_cd in (GP_CD,REFERDOC_CD)
;and epr.prsnl_person_id != 0.0
;and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100");removed because inactive were not pulling for default statement

join pl where pl.person_id = outerjoin(epr.prsnl_person_id)

join pn where pn.person_id = outerjoin(pl.person_id)
and pn.name_type_cd = outerjoin(PRSNL_CD)
and pn.active_ind = outerjoin(1)
and pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
and pn.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))

order by
	sorter
	, epr.beg_effective_dt_tm desc

	, pl.person_id

head report
	cnt = enc->cnt

head sorter
	if(epr.active_ind = 1 and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"))
		cnt = cnt+1
		stat = alterlist(enc->gps,cnt) ; should only be 1 GP
		if(pl.person_id > 0.0)

			enc->gps[cnt].name_title = pn.name_prefix
			enc->gps[cnt].name_first = pl.name_first
			enc->gps[cnt].name_middle = pn.name_middle
			enc->gps[cnt].name_last = pl.name_last
		else
			enc->gps[cnt].name_free_text = epr.ft_prsnl_name
		endif
		if(epr.encntr_prsnl_r_cd = GP_CD)
			enc->gps[cnt].enc_gp_flag = 1
			enc->gps[cnt].person_id = pl.person_id
		else
			enc->gps[cnt].referring_gp_flag = 1
			enc->gps[cnt].ref_person_id = pl.person_id
		endif
	else
		if(epr.encntr_prsnl_r_cd = GP_CD and epr.end_effective_dt_tm < cnvtdatetime("31-DEC-2100"))
			enc->inactive_gp_flag = 1
		endif
	endif

foot report
	enc->cnt = cnt

with nocounter

;002* myHealth Consent flag.  similar to GP consent flag, but stored on Person_info and
;    (if GP consent flag set to Y as well )governs electronic submission of patient info to
;myHealthRecord
if (PCEHR_UDF_CD > 0)
	select into "nl:"
	from person_info pi
	where
	   pi.person_id = PERSON_ID
	   and pi.info_type_cd = UDF_CD
       and pi.info_sub_type_cd = PCEHR_UDF_CD
       and pi.active_ind = 1
       and  (pi.beg_effective_dt_tm  < cnvtdatetime(curdate,curtime3)
  						and   pi.end_effective_dt_tm  > cnvtdatetime(curdate,curtime3))
	order by pi.updt_dt_tm asc

	detail
		if(pi.person_info_id > 0)
			enc->MyHealth_consent = uar_get_code_meaning(pi.value_cd)
		endif
	with nocounter
endif
; *002


 /*
; Other FAX Relationships
select into "nl:"
from encntr_prsnl_reltn epr
	, prsnl pl
	, person_name pn

plan epr where epr.encntr_id = ENCNTR_ID
and epr.encntr_prsnl_r_cd = FAX_CD
and epr.active_ind = 1
and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)

join pl where pl.person_id = outerjoin(epr.prsnl_person_id)

join pn where pn.person_id = outerjoin(pl.person_id)
and pn.name_type_cd = outerjoin(PRSNL_CD)
and pn.active_ind = outerjoin(1)
and pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
and pn.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))

order by
	pl.person_id
	, epr.beg_effective_dt_tm

head report
	cnt = enc->cnt

head pl.person_id
	cnt = cnt+1
	stat = alterlist(enc->gps,cnt) ; should only be 1 GP
	if(pl.person_id > 0.0)
		enc->gps[cnt].person_id = pl.person_id
		enc->gps[cnt].name_title = pn.name_prefix
		enc->gps[cnt].name_first = pl.name_first
		enc->gps[cnt].name_middle = pn.name_middle
		enc->gps[cnt].name_last = pl.name_last
	else
		enc->gps[cnt].name_free_text = epr.ft_prsnl_name
	endif
	enc->gps[cnt].fax_flag = 1

foot report
	enc->cnt = cnt

with nocounter
 */

; Create string so not to qualify already fetched GP / FAX GP as an additional recipient.
if(enc->cnt > 0)
	set pat_ed_document_flex = "pedf.provider_id not in ("
	for(x=1 to enc->cnt)
		set pat_ed_document_flex = concat(pat_ed_document_flex,trim(cnvtstring(enc->gps[x].person_id)))
		if(x < enc->cnt)
			set pat_ed_document_flex = concat(pat_ed_document_flex,",")
		endif
	endfor
	set pat_ed_document_flex = concat(pat_ed_document_flex,")")
else
	set pat_ed_document_flex = "1=1"
endif


;Load additional Reciepts -codified
select into "nl:"
from pat_ed_document ped
	, pat_ed_doc_followup pedf
	, prsnl pl
	, person_name pn

plan ped where ped.encntr_id = ENCNTR_ID

join pedf where pedf.pat_ed_doc_id = ped.pat_ed_document_id
and pedf.active_ind = 1
;and parser(pat_ed_document_flex); We want to show that someone added an existing GP as a
;recipient as well

join pl where pl.person_id = pedf.provider_id

join pn where pn.person_id = pl.person_id
and pn.name_type_cd =PRSNL_CD
and pn.active_ind = 1
and pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)

order by pl.name_first
	, pl.name_last
	, pl.person_id

head report
	cnt = enc->cnt

head pl.person_id
	call echo(pl.name_first)
	call echo(pl.name_last)
	cnt = cnt+1
	stat = alterlist(enc->gps,cnt)
	enc->gps[cnt].person_id = pl.person_id
	enc->gps[cnt].name_title = pn.name_prefix
	enc->gps[cnt].name_first = pl.name_first
	enc->gps[cnt].name_middle = pn.name_middle
	enc->gps[cnt].name_last = pl.name_last

foot report
	enc->cnt = cnt

with nocounter


;Load additional Reciepts - freetext
select into "nl:"
from pat_ed_document ped
	, pat_ed_doc_followup pedf


plan ped where ped.encntr_id = ENCNTR_ID

join pedf where pedf.pat_ed_doc_id = ped.pat_ed_document_id
	and pedf.active_ind = 1
	and pedf.provider_id = 0

order by pedf.provider_name,
	pedf.pat_ed_doc_followup_id
head report
	cnt = enc->cnt

head pedf.pat_ed_doc_followup_id

	cnt = cnt+1
	stat = alterlist(enc->gps,cnt)
	enc->gps[cnt].name_free_text= concat(pedf.provider_name,"(Freetext Entry)")


foot report
	enc->cnt = cnt

with nocounter


; load consent flag
select into "nl:"
from encounter e
plan e where e.encntr_id = ENCNTR_ID
detail
	enc->consent_flag = substring(1,1,uar_get_code_display(e.courtesy_cd))
with nocounter


; Load address GP/Additional Recip
select into "nl:"
from address a

plan a where expand(idx,1,enc->cnt,a.parent_entity_id,enc->gps[idx].person_id)
and a.parent_entity_name = "PERSON"
and a.address_type_cd = BUSINESS_ADDR_CD
and a.active_ind = 1
and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
and a.parent_entity_id+0 > 0.0

order by a.parent_entity_id
	,a.address_type_seq
	, a.beg_effective_dt_tm desc

head report
	pos = 0

head a.parent_entity_id
	pos = locateval(idx,1,enc->cnt,a.parent_entity_id,enc->gps[idx].person_id)
	while(pos > 0)
		enc->gps[pos].address_line_1 = trim(a.street_addr)
		enc->gps[pos].address_line_2 = trim(a.street_addr2)
		enc->gps[pos].city = trim(a.city)
		enc->gps[pos].state = trim(a.state)
		enc->gps[pos].country = trim(a.country)
		enc->gps[pos].zipcode = trim(a.zipcode)

		pos = locateval(idx,pos+1,enc->cnt,a.parent_entity_id,enc->gps[idx].person_id)
	endwhile

with nocounter

 ; Load address Referring Doctor
select into "nl:"
from address a

plan a where expand(idx,1,enc->cnt,a.parent_entity_id,enc->gps[idx].ref_person_id)
and a.parent_entity_name = "PERSON"
and a.address_type_cd = BUSINESS_ADDR_CD
and a.active_ind = 1
and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
and a.parent_entity_id+0 > 0.0

order by a.parent_entity_id
	,a.address_type_seq
	, a.beg_effective_dt_tm desc

head report
	pos = 0

head a.parent_entity_id
	pos = locateval(idx,1,enc->cnt,a.parent_entity_id,enc->gps[idx].ref_person_id)
	while(pos > 0)
		enc->gps[pos].address_line_1 = trim(a.street_addr)
		enc->gps[pos].address_line_2 = trim(a.street_addr2)
		enc->gps[pos].city = trim(a.city)
		enc->gps[pos].state = trim(a.state)
		enc->gps[pos].country = trim(a.country)
		enc->gps[pos].zipcode = trim(a.zipcode)

		pos = locateval(idx,pos+1,enc->cnt,a.parent_entity_id,enc->gps[idx].ref_person_id)
	endwhile

with nocounter

; Load Phone and prsnl record FAX  GP/Additional Recips
select into "nl:"
from phone p

plan p where expand(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)
and p.parent_entity_name = "PERSON"
and p.phone_type_cd in (BUSINESS_PHONE_CD, FAX_PHONE_CD)
and p.active_ind = 1
and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
and p.parent_entity_id+0 > 0.0

order by p.parent_entity_id
		,p.phone_type_seq
		, p.beg_effective_dt_tm

head p.parent_entity_id
	phone_num = fillstring(30," ")
	fax_num = fillstring(30," ")
	pos = 0

detail
	if(p.phone_type_cd = BUSINESS_PHONE_CD)
		phone_num = p.phone_num
	else
		fax_num = p.phone_num
	endif

foot p.parent_entity_id
	pos = locateval(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)
	while(pos > 0)
		enc->gps[pos].phone = trim(phone_num)
		enc->gps[pos].fax = trim(fax_num)
		pos = locateval(idx,pos+1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)
	endwhile

with nocounter

 ; Load Phone and prsnl record FAX Referring Doctor
select into "nl:"
from phone p

plan p where expand(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].ref_person_id)
and p.parent_entity_name = "PERSON"
and p.phone_type_cd in (BUSINESS_PHONE_CD, FAX_PHONE_CD)
and p.active_ind = 1
and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
and p.parent_entity_id+0 > 0.0

order by p.parent_entity_id
		,p.phone_type_seq
		, p.beg_effective_dt_tm

head p.parent_entity_id
	phone_num = fillstring(30," ")
	fax_num = fillstring(30," ")
	pos = 0

detail
	if(p.phone_type_cd = BUSINESS_PHONE_CD)
		phone_num = p.phone_num
	else
		fax_num = p.phone_num
	endif

foot p.parent_entity_id
	pos = locateval(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].ref_person_id)
	while(pos > 0)
		enc->gps[pos].phone = trim(phone_num)
		enc->gps[pos].fax = trim(fax_num)
		pos = locateval(idx,pos+1,enc->cnt,p.parent_entity_id,enc->gps[idx].ref_person_id)
	endwhile

with nocounter



 ; Load FAX Number from device Xref for Auto Fax Build
select into "nl:"
from device_xref p,
	Remote_device r

plan p where expand(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)
;and p.parent_entity_name = "PRSNL"
;and p.usage_type_cd =        2282.00
;and p.parent_entity_id+0 > 0.0
join r where p.device_cd = r.device_cd

order by p.parent_entity_id
	head report
	pos = 0

head p.parent_entity_id
	pos = locateval(idx,1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)
	if (enc->gps[pos].referring_gp_flag !=1)
	while(pos > 0)
		enc->gps[pos].area_code = r.area_code
		enc->gps[pos].fax_exchange = r.exchange
		enc->gps[pos].phone_suffix = r.phone_suffix

		;fax_num_xref =concat(trim(jen));r.area_code,"-",r.exchange," ",r.phone_suffix))
		pos = locateval(idx,pos+1,enc->cnt,p.parent_entity_id,enc->gps[idx].person_id)

	endwhile
 	endif
with nocounter

;003 +++

; Load Electronic Identifier(s)
select into "nl:"
from (dummyt d with seq = enc->cnt)
	 ,prsnl_alias pa

PLAN d
	WHERE enc->gps[d.seq].person_id != 0

join pa
	where pa.person_id 			= enc->gps[d.seq].person_id
	and pa.alias_pool_cd 		in (ARGUS_CD, HEALTHLINK_CD, RNET_CD)
	and pa.active_ind 			= 1
	and cnvtdatetime(curdate, curtime) between pa.beg_effective_dt_tm
										   and pa.end_effective_dt_tm

order by d.seq

detail
 	case (pa.alias_pool_cd)
 		of HEALTHLINK_CD:	enc->gps[d.seq].helthelink 	= trim(pa.alias)
 		of RNET_CD:			enc->gps[d.seq].RNET 		= trim(pa.alias)
 		of ARGUS_CD:		enc->gps[d.seq].ARGUS 		= trim(pa.alias)
 	endcase

with nocounter, check

; Load Healthlink Identifier
;select into "nl:"
;from prsnl_alias pa
;
;plan pa where expand(idx,1,enc->cnt,pa.person_id,enc->gps[idx].person_id)
;and pa.alias_pool_cd in (ARGUS_CD, HEALTHLINK_CD)
;and pa.active_ind = 1
;and pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
;and pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
;and pa.person_id+0 > 0.0
;
;order by pa.person_id
;		, pa.beg_effective_dt_tm desc
;
;head report
;	pos = 0
;
;head pa.person_id
;	pos = locateval(idx,1,enc->cnt,pa.person_id,enc->gps[idx].person_id)
;
; 		if (enc->gps[pos].referring_gp_flag !=1)
;		while(pos > 0)
;
;			enc->gps[pos].helthelink = trim(cnvtalias(pa.alias, pa.alias_pool_cd))
;
;			if(pa.prsnl_alias_type_cd = ARGUS_CD)
;				enc->gps[pos].helthlink_flag = 0
;			else
;			enc->gps[pos].helthlink_flag = 1
;			endif
;
;		pos = locateval(idx,pos+1,enc->cnt,pa.person_id,enc->gps[idx].person_id)
;
;		endwhile
; 	endif
;foot report
;	null
;
;with nocounter

;003 ---


;call echorecord(enc)


; Create RTF Output.
call ApplyFont(active_fonts->header_patient_name)
if(enc->consent_flag = "N")
	call PrintText("No GP Consent",1,0,1)
    call NextLine(2)
elseif(enc->consent_flag != "Y")
	call PrintText("GP Consent Unknown",1,0,1)
	call NextLine(2)
else
		call PrintText("GP Consent Given",1,0,1)
    call NextLine(2)
endif

;002* print myHealthRecord consent
if (PCEHR_UDF_CD > 0)
	if(enc->MyHealth_consent = "YES")
		call PrintText("My Health Record Consent Given",1,0,1)
		call NextLine(2)

	elseif(enc->MyHealth_consent = "NO")
		call PrintText("No My Health Record Consent",1,0,1)
		call NextLine(2)
	else
		call PrintText("My Health Record Consent Unknown",1,0,1)
		call NextLine(2)
	endif
endif
;*002

call echorecord(enc)

if(enc->cnt > 0)
	for(x=1 to enc->cnt)
		set outstring = ""
		set dont_print_flag = 0

		; Headings
		if(latest_gp_heading_flag = 0)
			call ApplyFont(active_fonts->header_patient_name)
			call PrintText("Latest GP Details",1,0,1)
			call NextLine(1)
			set latest_gp_heading_flag = 1

			if(enc->gps[x].latest_gp_flag != 1)
				call ApplyFont(active_fonts->normal)
				if(enc->inactive_gp_flag = 1)
					call PrintText("**No Active GP for this patient**",0,0,0)
				else
					call PrintText("**No GP for this patient**",0,0,0)
				endif
				;call PrintText("**No Active GP for this patient**",0,0,0)
				call NextLine(2)
				set dont_print_flag = 1
			endif
		elseif(enc_gp_heading_flag = 0)
			call ApplyFont(active_fonts->header_patient_name)
			call PrintText("Visit GP Details",1,0,1)
			call NextLine(1)
			set enc_gp_heading_flag = 1

			if(enc->gps[x].enc_gp_flag != 1)
				call ApplyFont(active_fonts->normal)
				if(enc->inactive_gp_flag = 1)
					call PrintText("**No Active GP for this visit**",0,0,0)
				else
					call PrintText("**No GP for this visit**",0,0,0)
				endif
				call NextLine(2)
				set dont_print_flag = 1
			endif
		elseif(ref_gp_heading_flag = 0)
			call ApplyFont(active_fonts->header_patient_name)
			call PrintText("Referring Dr Details",1,0,1)
			call NextLine(1)
			set ref_gp_heading_flag = 1

			if(enc->gps[x].referring_gp_flag != 1)
				call ApplyFont(active_fonts->normal)
				call PrintText("**No Referring Dr(s) for this visit**",0,0,0)
				call NextLine(2)
				set dont_print_flag = 1
			endif
		elseif(add_rec_heading_flag = 0)
			call ApplyFont(active_fonts->header_patient_name)
			call PrintText("Additional Recipients",1,0,1)
			call NextLine(1)
			set add_rec_heading_flag = 1
		endif

		; Name
		if(dont_print_flag = 0)
			call ApplyFont(active_fonts->normal)
			if(enc->gps[x].name_free_text > " ")
				call PrintText(enc->gps[x].name_free_text,1,0,0)
			else
				set outstring = trim(enc->gps[x].name_title)
				if(outstring > " ")
					set outstring = concat(outstring," ",trim(enc->gps[x].name_first))
				else
					set outstring = trim(enc->gps[x].name_first)
				endif
				if(enc->gps[x].name_middle > " ")
					set outstring = concat(outstring," ",trim(enc->gps[x].name_middle))
				endif
				if(enc->gps[x].name_last > " ")
					set outstring = concat(outstring," ",trim(enc->gps[x].name_last))
				endif
				call PrintText(outstring,1,0,0)
			endif
			call NextLine(1)

			; Address
			if(enc->gps[x].address_line_1 > " ")
				set outstring = trim(enc->gps[x].address_line_1)
				if(enc->gps[x].address_line_2 > " ")
					set outstring = concat(outstring,", ",trim(enc->gps[x].address_line_2))
				endif
				if(enc->gps[x].city > " ")
					set outstring = concat(outstring,", ",trim(enc->gps[x].city))
				endif
				if(enc->gps[x].state > " ")
					set outstring = concat(outstring,"  ",trim(enc->gps[x].state))
				endif
			;	if(enc->gps[x].country > " ")
			;		set outstring = concat(outstring," ",trim(enc->gps[x].country))
			;	endif
				if(enc->gps[x].zipcode > " ")
					set outstring = concat(outstring,"  ",trim(enc->gps[x].zipcode))
				endif
				call PrintText(outstring,0,0,0)
				call NextLine(1)
			endif

			; Phone
			if(enc->gps[x].phone > " ")
				call PrintLabeledDataFixed("Phone: ",enc->gps[x].phone,30)
				call NextLine(1)
			endif

			; PRSNL record Fax
			if(enc->gps[x].fax > " ")
				call PrintLabeledDataFixed("Prsnl Record Fax: ",enc->gps[x].fax,30)
				call NextLine(1)
			endif
			; Fax 2 PRSNL - Device_Xref AUTO fax build
			if(enc->gps[x].area_code > " ")
				set outstringfax = trim(enc->gps[x].area_code)

				if(enc->gps[x].fax_exchange > " ")
					set outstringfax = concat(outstringfax," ",trim(enc->gps[x].fax_exchange))
				endif
				if(enc->gps[x].phone_suffix > " ")
					set outstringfax = concat(outstringfax,"  ",trim(enc->gps[x].phone_suffix))
				endif

			call PrintLabeledDataFixed("Auto Fax: ",outstringfax,30)

				call NextLine(1)
			endif

			;003 +++
			;Electronic Identifiers
			set EI_cnt = 0
			set EI_id = 0

			if (enc->gps[x].helthelink > " ")
				set outstring = concat("HealthLink:",enc->gps[x].helthelink)
				set EI_cnt = EI_cnt + 1
				set EI_id = 1
			endif

			if(enc->gps[x].RNET > " ")
				if (EI_cnt = 1)
					set outstring = concat(outstring, ",   ", "RNET:", enc->gps[x].RNET)
				else
					set outstring = concat("RNET:", enc->gps[x].RNET)
				endif
				set EI_cnt = EI_cnt + 1
				set EI_id = 1
			endif

			if(enc->gps[x].ARGUS > " ")
				set outstring = concat("Argus - ",enc->gps[x].ARGUS)
				set EI_cnt = EI_cnt + 1
				set EI_id = 1
			endif

			if (EI_id = 1)
				if (EI_cnt > 1)
					call PrintLabeledDataFixed("Electronic Identifiers: ",outstring,30)
				else
					call PrintLabeledDataFixed("Electronic Identifier: ",outstring,30)
				endif
				call NextLine(1)
			endif


;			if(enc->gps[x].helthelink > " ")
;				if(enc->gps[x].helthlink_flag = 1)
;					set outstring = concat("Healthlink - ",enc->gps[x].helthelink)
;				else
;					set outstring = concat("Argus - ",enc->gps[x].helthelink)
;				endif
;				call PrintLabeledDataFixed("Electronic Identifier: ",outstring,30)
;				call NextLine(1)
;			endif

			;003 ---

			call NextLine(1)
		else
			set x = x-1
		endif
	endfor
endif

; Print headings not printed above.
if(latest_gp_heading_flag = 0)
	call ApplyFont(active_fonts->header_patient_name)
	call PrintText("Latest GP Details",1,0,1)
	call NextLine(1)
	set latest_gp_heading_flag = 1
	call ApplyFont(active_fonts->normal)
	if(enc->inactive_gp_flag = 1)
		call PrintText("**No Active GP for this patient**",0,0,0)
	else
		call PrintText("**No GP for this patient**",0,0,0)
	endif
	;call PrintText("**No Active GP for this patient**",0,0,0)
	call NextLine(2)
endif

if(enc_gp_heading_flag = 0)
	call ApplyFont(active_fonts->header_patient_name)
	call PrintText("Visit GP Details",1,0,1)
	call NextLine(1)
	set enc_gp_heading_flag = 1
	call ApplyFont(active_fonts->normal)
	if(enc->inactive_gp_flag = 1)
		call PrintText("**No Active GP for this visit**",0,0,0)
	else
		call PrintText("**No GP for this visit**",0,0,0)
	endif
	call NextLine(2)
endif

if(ref_gp_heading_flag = 0)
	call ApplyFont(active_fonts->header_patient_name)
	call PrintText("Referring Dr Details",1,0,1)
	call NextLine(1)
	set ref_gp_heading_flag = 1
	call ApplyFont(active_fonts->normal)
	call PrintText("**No Referring Dr(s) for this visit**",0,0,0)
	call NextLine(2)
endif

if(add_rec_heading_flag = 0)
	call ApplyFont(active_fonts->header_patient_name)
	call PrintText("Additional Recipients",1,0,1)
	call NextLine(1)
	set add_rec_heading_flag = 1
	call ApplyFont(active_fonts->normal)
	call PrintText("**No additional recipients entered for this visit**",0,0,0)
endif

;else
;	call ApplyFont(active_fonts->normal)
;	call PrintText("**No GP or Additional Recipients Found**",0,0,0)


call FinishText(0)
call echo(rtf_out->text)
set reply->text = rtf_out->text

end
go