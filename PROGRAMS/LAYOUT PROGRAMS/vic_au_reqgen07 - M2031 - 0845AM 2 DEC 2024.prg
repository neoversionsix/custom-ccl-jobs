/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
/*****************************************************************************

        Source file name:		vic_au_reqgen07.PRG
        Object name:				vicaureqgen7
        Request #:					N/A

        Product:						PowerChart
        Product Team:				Order Management
        HNA Version:        500
        CCL Version:

        Program purpose:	print LABORATORY requisitions

******************************************************************************/
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;    *001 02/01/01 CERNER		Initial Release                     *
;    *003 03/01/04 BC9129		CAPEP00118848 - Attending MD        *
;    *004 05/01/05 LP010060             Fix multiple order details defects  *
;    *005 05/26/05 RM010964             Fix printing age, height and weight *
;    *006 12/13/06 KS012546             CR 1-853090761 - Orders requiring   *
;                                       dr. cosign are not printing a       *
;                                       requisition.                        *
;    *007 04/17/07 GG013711             Added Free set for various records  *
;    *008 06/15/07 SH016288             Add printing on activate action     *
;                                       Removed print on future action      *
;                                       CR 1-1127184331                     *
;    *009 06/15/07 SH016288             Remove time zone on dob and admit   *
;                                       CR 1-919486297                      *
;    *010 06/15/07 SH016288             Remove dcpreq07       CR 1-919486121*
;    *011 06/15/07 SH016288             Add ordered time to order d/t       *
;                                       display time zone if utc            *
;                                       CR 1-919486328                      *
;    *012 06/20/07  SH016288            Blank order_id requisition print fix*
;                                       CR 1-1162354921                     *
;    *009 06/06/07 SH016288             Add Modify, & Discontinue Banner Bar*
;                                       reduced Modify header               *
;                                       CR 1-899593932 & CR 1-1127184359    *
;    *010 06/06/07 SH016288             Add printing on activate action     *
;                                       Removed print on future action      *
;                                       CR 1-1127184331                     *
;    *011 06/06/07 SH016288             Remove time zone on dob and admit   *
;                                       CR 1-919486297                      *
;    *012 06/06/07 SH016288             Remove dcpreq06       CR 1-919486121*
;    *013 06/06/07 SH016288             Add ordered time to order d/t       *
;                                       display time zone if utc            *
;                                       CR 1-919486328                      *
;    *014 06/20/07 SH016288             Requisition tries to print the total*
;                                       number of orders instead of orders  *
;                                       that count                          *
;                                       CR 1-1162354921                     *
;    *015 06/21/07 SH016288             DOB one day off CR 1-1065284374     *
;	 *016 08/07/07 RD012555 			Add ellipsis to mnemonics that are 	*
;										truncated.   						*
;    *017 02/05/09 MK012585             Join Order_action table using       *
;                                       conversation_id if one is passed in.*
;    *018 10/22/09 DC7242               Several cosmetic changes  			*
;    *019 06/01/10 GG009738				Changed the object name from 		*
;										vic_au_reqgen07	to vicaureqgen7		*
;    *020 03/31/11 CC010582				updates							    *
;	*023 13/09/11 HSSJM3009			NOTE 021 and 022were not moded correctly
;										add logic to print ordering doctor  *
;										for correct facility				*
;	*024 16/12/11 HSSLW2309	SR 205459 - Correct not printing multiple orders for some patients
;	*025  17/02/12 HSSLW2309  SR 202129 	- Add patients address
;											- Chg how Pathology provider pulled
;											- Improved spacing in layout program in the patient demographics area
;	*026  26/06/12 HSSLW2309			- Chg for layout builder so can sort on Container no.
;	*027  10/12/12 Leigh W-Y			- SR295122 [EHS] - chg layout for Blood Bank Req
;											 - chg to .inc file to have a flag for layout
;										- SR295122 - Layout chg - label for Request date chg
;   *028  26/02/13 Leigh W-Y			- SR342705 - Blood Bank only - Date & Time product required in US format
;   *029  01/05/13 Leigh W-Y			- Put back in code for Grp1 auto printing - got lost in version above
;	*030  03/10/2017 MarkW				- fix bug in blood bank line count, added wh-specific oefs and
;										wh specific layout for WH project.
;	31/32 n/a
;   *033  18/07/2018 Mark W				- SR 811163 Fix issue with provider number lookup seen on radiology
;										  requisition

;~DE~***************************************************************************************************************

drop program vicaureqgen7:dba go
create program vicaureqgen7:dba

;Request structure always be present as the first record
;declaration as Output server calls CCLSET_RECORD without
;passing in a record structure name. The memory gets allocated
;to this request definition

record request
( 1 person_id = f8
  1 print_prsnl_id = f8
  1 order_qual[*]
    2 order_id = f8
    2 encntr_id = f8
    2 conversation_id = f8
  1 printer_name = c50
)




/*  testing
select into value(concat("cer_temp:9request",format(sysdate,"mmddyyhhmmss;;d"),".dat"))
from (dummyt d with seq = size(request->order_qual,5))
head report
	col 1 "p_id:", request->person_id
	row +1
	col 1 "pp_id:", request->print_prsnl_id
	row +1
	col 1 "pn:",request->printer_name
	row +2
detail
	col 5 "order_id:", request->order_qual[d.seq].order_id
	row +1
	col 5 "encntr_id:",request->order_qual[d.seq].encntr_id
	row +1
	col 5 "conversation:",request->order_qual[d.seq].conversation_id
	row +1
foot report
row +2
	col 1 "size:", d.seq
with nocounter */
; mod 007
;free set orders
free set allergy
free set diagnosis
free set pt
free set comments
free set copydoctors

%i cust_script:vic_au_reqgen07.inc

record allergy
( 1 cnt = i2
  1 qual[*]
    2 list = vc
  1 line = vc
  1 line_cnt = i2
  1 line_qual[*]
    2 line = vc
)

record diagnosis
( 1 cnt = i2
  1 qual[*]
    2 diag = vc
  1 dline = vc
  1 dline_cnt = i2
  1 dline_qual[*]
    2 dline = vc
)

record pt
( 1 line_cnt = i2
  1 lns[*]
    2 line = vc
)

record alerts(
 1 qual[*]
   2 alert_disp = vc
)

record comments(
 1 qual[*]
  2 long_text = vc
  2 order_id = f8
  2 gen_hist = i2
)

record copydoctors(
 1 order_id = f8
 1 qual[*]
  2 name = vc
)

record Bing(
	1 admit_provider = c130
	1 admit_provider_PN = c130
	1 appt_loc = vc
;	1 Email = vc
;	1 Department = vc
	1 Ref_urn = vc
;	1 qual[*]
;	2 test = f8
	)



/*****************************************************************************
*    Program Driver Variables                                                *
*****************************************************************************/

declare order_cnt      = i4 with protect, noconstant(size(request->order_qual,5))
declare ord_cnt        = i4 with protect, noconstant(size(request->order_qual,5));014
set stat = alterlist(orders->qual,order_cnt)

declare person_id      = f8 with protect, noconstant(0.0)
declare encntr_id      = f8 with protect, noconstant(0.0)

set orders->spoolout_ind = 0
set pharm_flag = 0     ; Set to 1 if you want to pull the MNEM_DISP_LEVEL and IV_DISP_LEVEL from the tables.

declare ordered_cd    = f8 with protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
declare mrn_alias_cd   = f8 with protect, constant(uar_get_code_by("MEANING", 4, "MRN"))
declare ssn_alias_cd   = f8 with protect, constant(uar_get_code_by("MEANING", 4, "SSN")) ;018
declare milt_alias_cd   = f8 with protect, constant(uar_get_code_by("MEANING", 4, "MILITARYID"))
declare comment_cd     = f8 with protect, constant(uar_get_code_by("MEANING", 14, "ORD COMMENT"))
declare fnbr_cd        = f8 with protect, constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare mrnnbr_cd        = f8 with protect, constant(uar_get_code_by("MEANING", 319, "MRN"))
declare admit_doc_cd   = f8 with protect, constant(uar_get_code_by("MEANING", 333, "ADMITDOC"))
declare attend_doc_cd  = f8 with protect, constant(uar_get_code_by("MEANING", 333, "ATTENDDOC"))
declare canceled_cd    = f8 with protect, constant(uar_get_code_by("MEANING", 12025, "CANCELED"))
declare inerror_cd     = f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERROR"))
declare pharmacy_cd    = f8 with protect, constant(uar_get_code_by("MEANING", 6000, "PHARMACY"))
declare iv_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 16389, "IVSOLUTIONS"))
declare complete_cd    = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "COMPLETE"))
declare modify_cd      = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "MODIFY"))
declare order_cd       = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ORDER"))
declare cancel_cd      = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "CANCEL"))
declare discont_cd     = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "DISCONTINUE"))
declare studactivate_cd = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "STUDACTIVATE")) ;006
declare activate_cd    = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ACTIVATE")) ;008
declare status_change_cd = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "STATUSCHANGE")) ;021
declare CRIT_ALERTS_CD = f8  with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",12033,"CRITICALALERTS")) ;018
declare ACTIVE_CD      = f8  with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",12030,"ACTIVE"))         ;018
declare RESOLVED_CD    = f8  with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",12030,"RESOLVED"))       ;018
declare DOCNBR_CD      = f8 with protect, constant(uar_get_code_by("MEANING",320,"DOCNBR"))               ;018
declare FACILITY_CD    = f8  with protect, constant(UAR_GET_CODE_BY("MEANING",222,"FACILITY"))       ;018
declare PROVIDER_NBR_CD = f8 with protect, constant(uar_get_code_by("MEANING",320,"PROVIDER NUM"))               ;020
declare GPPROVIDER_VAR = f8 with protect, Constant(uar_get_code_by("DISPLAYKEY",263,"GPPROVIDER")),protect ;023
DECLARE ORG_ALIAS_POOL_VAR = f8 with protect,noconstant(0)											;023
declare LAB_CD      = f8 with protect, constant(uar_get_code_by("MEANING",222,"LAB"))
declare BLOODBANK_CD = F8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",5801,"BLOODBANK")) ; AS QC-505
declare URGENT_CD	= f8 with protect, constant(uar_get_code_by("MEANING",1304,"URGENT")) ;020
declare addr_cd = f8 with protect, constant(uar_get_code_by("MEANING",212,"HOME")) ;025

;033++
declare SITEPROVIDER_VAR = f8 with protect, Constant(uar_get_code_by("DISPLAYKEY",263,"SITE")),protect ;0
declare HPROFPROVIDER_VAR = f8 with protect, Constant(uar_get_code_by("DISPLAYKEY",263,"HPROF")),protect ;0
declare ALLSITES_PROVIDER_VAR = f8 with protect, Constant(uar_get_code_by("DISPLAYKEY",263,"PROVIDER")),protect ;0
;033--

declare offset = i2 with protect, noconstant(0)
declare daylight = i2 with protect, noconstant(0)
declare tz_index = i4 with protect, noconstant(0)

declare rtf_font_tbl = c28 with constant("{\fonttbl{\f0\fswiss Helv;}}")
declare rtf_font_0 = c16 with noconstant("\plain\f0 \fs20 ")
declare rtf_font_12 = c16 with noconstant("\plain\f0 \fs24 ")
declare rtf_bold = c3 with constant("\b ")
declare rtf_end_bold = c4 with constant("\b0 ")
declare rtf_cr = c5 with constant("\par ")

;027
declare rtf_uline = c4 with constant("\ul ")
declare rtf_font_11 = c16 with noconstant("\plain\f0 \fs22 ")

declare crlf   = c2 with protect, constant(concat(char(10),char(13)))

declare accession_ind = i2 with noconstant(0)
declare loop_cnt = i2 with noconstant(1)
declare max_loop = i2 with noconstant(0)
declare wait_sec = i2 with noconstant(1)

declare mnemonic_size = i4 with protect, noconstant(0)	;016
declare mnem_length = i4 with protect, noconstant(0)	;016



/******************************************************************************
*     Checking for accessions                                                 *
******************************************************************************/
call echo("Checking fo accessions")

set max_loop = 3
set wait_sec = size(request->order_qual,5)

call echo(build("max_loop=",max_loop))
call echo(build("wait_sec=",wait_sec))

call echo("starting check loop")
while (accession_ind = 0)
	call echo(build("loop_cnt=",loop_cnt))
	if (loop_cnt = max_loop)
		set accession_ind = 1
		call echo(build("setting accession_ind = 1, exit loop"))
	endif

	if (accession_ind = 0)
		call echo(build("checking accession_order_r for order_id=",request->order_qual[wait_sec].order_id))
		select into "nl:"
		from accession_order_r aor
		where aor.order_id = request->order_qual[wait_sec].order_id
		detail
			accession_ind = 1
			call echo(build("setting accession_ind = 1, inside query, exit"))
		with nocounter
	endif

	if (accession_ind = 0)
		call echo(build("accession number not found, waiting=",wait_sec))
		for (i = 1 to wait_sec)
			call pause(1)
		endfor
	endif

	set loop_cnt = (loop_cnt + 1)
endwhile

/******************************************************************************
*     PATIENT INFORMATION                                                     *
******************************************************************************/
 if (request-> print_prsnl_id > 0)
 	set orders->reprint_ind = 1
 endif

select into "nl:"
n_addr2 = nullind(a.street_addr2)
from person p,
     encounter e,
     person_alias pa,
     person_alias pa2, ;018
     person_alias pa3,
     encntr_alias ea,
     encntr_prsnl_reltn epr,
     prsnl pl,
     address a,                       ;025
    (dummyt d1 with seq = 1),
    (dummyt d2 with seq = 1),
    (dummyt d3 with seq = 1),
    (dummyt d4)
  ,encntr_loc_hist elh
  ,time_zone_r t
plan p
  where p.person_id = request->person_id
join e
  where e.encntr_id = request->order_qual[1].encntr_id
join elh
  where elh.encntr_id = e.encntr_id
join a  ;025
	where a.parent_entity_id = outerjoin(p.person_id)  ;chg to outerjoin 25/6/12
	  and a.active_ind = outerjoin(1)
	  and a.address_type_cd = outerjoin(ADDR_CD)
	  and a.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
	  and a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
join t
  where t.parent_entity_id = outerjoin(elh.loc_facility_cd)
   and t.parent_entity_name = outerjoin("LOCATION")
join d1
join pa
  where pa.person_id = p.person_id
    and pa.person_alias_type_cd = mrn_alias_cd
    and pa.active_ind = 1
    and pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
join pa2
  where pa2.person_id = p.person_id
    and pa2.person_alias_type_cd = ssn_alias_cd
    and pa2.active_ind = 1
    and pa2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pa2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
join d2
join ea
  where ea.encntr_id = e.encntr_id
    and ea.encntr_alias_type_cd = fnbr_cd
    and ea.active_ind = 1
join d3
join epr
  where epr.encntr_id = e.encntr_id
    and (epr.encntr_prsnl_r_cd = admit_doc_cd
         or epr.encntr_prsnl_r_cd = attend_doc_cd)
    and epr.active_ind = 1
join pl
  where pl.person_id = epr.prsnl_person_id
join d4
join pa3
  where pa3.person_id = p.person_id
    and pa3.person_alias_type_cd = milt_alias_cd
    and pa3.active_ind = 1
    and pa3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pa3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
;----
head report

  person_id = p.person_id
  encntr_id = e.encntr_id
  orders->name = p.name_full_formatted
  orders->pat_type = trim(uar_get_code_display(e.encntr_type_cd))
  orders->sex = uar_get_code_display(p.sex_cd)
  orders->age = cnvtage(p.birth_dt_tm)	;005
  tz_index = datetimezonebyname(trim(t.time_zone))

 call echo(build("Name is ",p.name_full_formatted))

 ;025 ++++
	state = uar_get_code_display(a.state_cd)
	country = uar_get_code_display(a.country_cd)

  If (n_addr2 = 0)

     orders->pat_addr = concat(trim(a.street_addr)," ",trim(a.street_addr2)," ",trim(a.city)," ",trim(state)," ",
                                trim(a.zipcode)," " ,trim(country) )

    Else
       orders->pat_addr = concat(trim(a.street_addr)," ",trim(a.city)," ",trim(state)," ",
                                trim(a.zipcode)," " ,trim(country) )
  EndIf

 ; 025 -------

  ;AS QC-505 orders->dob = format(datetimezone(p.birth_dt_tm, p.birth_tz,2),"mm/dd/yy;;d") ;009 015
  orders->dob = format(p.birth_dt_tm,"dd/mm/yyyy;;d") ;AS QC-505
  orders->admit_dt = format(datetimezone(e.reg_dt_tm, tz_index), "mm/dd/yy;;d");009
  orders->dischg_dt=format(datetimezone(e.disch_dt_tm, tz_index), "mm/dd/yy;;d");009

  if (e.disch_dt_tm = null or e.disch_dt_tm = 0)
    		orders->los = datetimecmp(cnvtdatetime(curdate,curtime3),e.reg_dt_tm)+1
  else
    		orders->los = datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+1
  endif
	  orders->facility = uar_get_code_description(e.loc_facility_cd)
	  orders->nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
	  orders->room = uar_get_code_display(e.loc_room_cd)
	  orders->bed = uar_get_code_display(e.loc_bed_cd)
	  orders->location = concat(trim(orders->nurse_unit),"/",trim(orders->room),"/",
	    trim(orders->bed))
	  orders->admit_diagnosis = e.reason_for_visit
	  orders->med_service = uar_get_code_display(e.med_service_cd)
  ;orders->concess_nbr = trim(uar_get_code_display(p.vet_military_status_cd),3) ;018
head epr.encntr_prsnl_r_cd
  if (epr.encntr_prsnl_r_cd = admit_doc_cd)
    orders->admitting = pl.name_full_formatted
  ;elseif (epr.encntr_prsnl_r_cd = attend_doc_cd)		;003
  ; orders->attending = pl.name_full_formatted			;003
  endif
detail
  if (pa.person_alias_type_cd = mrn_alias_cd)
    if (pa.alias_pool_cd > 0)
      orders->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
      bing->Ref_urn = concat('Ref:',cnvtalias(pa.alias,pa.alias_pool_cd))
    else
      orders->mrn = pa.alias
      bing->Ref_urn = concat('ref:',pa.alias)
    endif
  endif
  if (pa2.person_alias_type_cd = ssn_alias_cd)             ;018
    if (pa2.alias_pool_cd > 0)                             ;018
      orders->ssn = cnvtalias(pa2.alias,pa2.alias_pool_cd) ;018
    else                                                   ;018
      orders->ssn = trim(pa2.alias,3)                      ;018
    endif                                                  ;018
  endif														;018
  if (pa3.person_alias_type_cd = milt_alias_cd)
    if (pa3.alias_pool_cd > 0)
      orders->concess_nbr = cnvtalias(pa3.alias,pa3.alias_pool_cd)
    else
      orders->concess_nbr = pa3.alias
    endif
  endif

  if (ea.encntr_alias_type_cd = fnbr_cd)
    if (ea.alias_pool_cd > 0)
      orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    else
      orders->fnbr = ea.alias
    endif
  endif
with nocounter,outerjoin=d1,dontcare=pa,outerjoin=d2,dontcare=ea,
  outerjoin=d3,dontcare=epr, outerjoin=d4


select into "nl:"
from
     encounter e,
     encntr_alias ea
plan e
  where e.encntr_id = request->order_qual[1].encntr_id
join ea
  where ea.encntr_id = e.encntr_id
    and ea.encntr_alias_type_cd = mrnnbr_cd
    and ea.active_ind = 1
    and ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 detail
	if (ea.alias_pool_cd > 0)
      orders->mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
      bing->Ref_urn = concat('Ref:',cnvtalias(ea.alias,ea.alias_pool_cd))
    else
      orders->mrn = ea.alias
      bing->Ref_urn = concat('Ref:',ea.alias)
    endif
with nocounter


;-------------------BING
select into "nl:"
	appt_loc = replace(trim(uar_get_code_display(sa.appt_location_cd)),' ','_')
from sch_appt sa
; from dummyt
plan sa where sa.encntr_id = request->order_qual[1].encntr_id

detail
	bing->appt_loc = concat("location:",appt_loc)

;with nocounter
;-------------------


select into "nl:"
from encntr_plan_reltn epr
	,health_plan hp
plan epr
	where epr.encntr_id = request->order_qual[1].encntr_id
	and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   epr.active_ind = 1
join hp
	where hp.health_plan_id = epr.health_plan_id
	and   hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   hp.active_ind = 1
order by
	epr.beg_effective_dt_tm
detail
	orders->health_plan = trim(substring(1,55,hp.plan_name))
	orders->health_plan_nbr = trim(epr.member_nbr)
with nocounter


/* 003 Starts Here --->*/
select into "nl:"
from encntr_prsnl_reltn epr,
     prsnl pl
plan epr
  where epr.encntr_prsnl_r_cd = attend_doc_cd
    and epr.encntr_id = request->order_qual[1].encntr_id
    and epr.expiration_ind + 0 = 0
join pl
  where pl.person_id = epr.prsnl_person_id
order by epr.active_status_dt_tm
head report
   orders->attending = pl.name_full_formatted
detail
 if (epr.prsnl_person_id = request-> print_prsnl_id)
	orders->attending = pl.name_full_formatted
 endif
/* <--- 003 Ends Here */

/** Begin 018 **/
;Get hospital name/financial class
select into "nl:"
from encounter e,
     organization o,
     address a
plan e where e.encntr_id = request->order_qual[1].encntr_id
join o where o.organization_id = e.organization_id
     and o.active_ind = 1
join a where a.parent_entity_id = outerjoin(o.organization_id)
     and a.parent_entity_name = outerjoin("ORGANIZATION")
     and a.active_ind = outerjoin(1)

detail
  orders->fin_class = trim(uar_get_code_display(e.financial_class_cd),3)
  orders->hospital_name = trim(o.org_name,3)
  orders->hospital_addr = concat(trim(a.street_addr,3)," ",trim(a.city,3)," ",trim(a.state,3)," ",trim(a.zipcode,3))

with nocounter


/** Begin 31 **/
;get org set name (for eastern health specific changes)
select into "nl:"
from encounter e
	 , org_set   os
	 , org_set_org_r   osr

plan e where e.encntr_id = request->order_qual[1].encntr_id
       join osr where e.organization_id = osr.organization_id
       join os where osr.org_set_id = os.org_set_id

detail
	If(substring(1,7,os.name) = "Eastern")   ;eastern have two org sets
   		orders->orgset_name = "Eastern Health"
   	else
   		orders->orgset_name = os.name
   	endif



with nocounter
/** End 31 **/

;get Service Location (separate to top, due to outerjoin)
select into "nl:"
from encounter e
	,code_value_extension cve


;  025 remove
;	, location_group lg1
;    , location_group lg2
;    , location l


plan e where e.encntr_id = request->order_qual[1].encntr_id

;025 ++++++
join cve where cve.code_value = e.loc_facility_cd
              and cve.code_set = 220
              and cve.field_NAME = "Pathology Name"


;025 remove
;join lg1 where lg1.parent_loc_cd = e.loc_facility_cd
;	and lg1.location_group_type_cd = FACILITY_CD
;
;join lg2 where lg2.parent_loc_cd = lg1.child_loc_cd
;
;join l where l.location_cd = lg2.child_loc_cd
;	and l.location_type_cd = LAB_CD

detail
	orders->service_prov =  cve.field_value         ;025  trim(uar_get_code_display(l.location_cd),3)

with nocounter

;Get Alerts
select into "nl:"
    alt_disp = substring(1,250,evaluate(textlen(trim(p.annotated_display,3)),0,n.source_string,p.annotated_display))
from problem p,
     nomenclature n
plan p where p.person_id = request->person_id
     and p.active_ind = 1
     and p.life_cycle_status_cd in(ACTIVE_CD,RESOLVED_CD)
     and p.classification_cd = CRIT_ALERTS_CD
join n where n.nomenclature_id = p.nomenclature_id
order p.onset_dt_tm desc,
      alt_disp
head report
  alert_cnt = 0
detail
  alert_cnt = alert_cnt + 1
  stat = alterlist(alerts->qual,alert_cnt)
  alerts->qual[alert_cnt].alert_disp = alt_disp
with nocounter
/** End 018 **/


/******************************************************************************
*     CLINICAL EVENT INFORMATION                                              *
******************************************************************************/

;set height_cd = uar_get_code_by("DISPLAYKEY", 72, "CLINICALHEIGHT")	;005 BEGIN
;set weight_cd = uar_get_code_by("DISPLAYKEY", 72, "CLINICALWEIGHT")
set height_cd = uar_get_code_by("DISPLAYKEY", 72, "HEIGHTLENGTHMEASURED")
set weight_cd = uar_get_code_by("DISPLAYKEY", 72, "WEIGHTMEASURED")

;select into "nl:"
;from code_value cv
;plan cv
;  where cv.code_set = 72
;    and cv.display_key in ("CLINICALHEIGHT","CLINICALWEIGHT")
;    and cv.active_ind = 1
;detail
;  case (cv.display_key)
;  of "CLINICALHEIGHT":
;    height_cd = cv.code_value
;  of "CLINICALWEIGHT":
;    weight_cd = cv.code_value
;  endcase
;with nocounter
;005 END

select into "nl:"
from clinical_event c
plan c
  where c.person_id = person_id
;   and c.encntr_id = encntr_id	;005
    and c.event_cd in (height_cd,weight_cd)
    and c.view_level = 1
    and c.publish_flag = 1
    and c.valid_until_dt_tm = cnvtdatetime("31-DEC-2100,00:00:00")
    and c.result_status_cd != inerror_cd
order c.event_end_dt_tm
detail
  if (c.event_cd = height_cd)
    orders->height = concat(trim(c.event_tag)," ",
      trim(uar_get_code_display(c.result_units_cd)))
 orders->height_dt_tm = format(datetimezone(c.updt_dt_tm, c.performed_tz), "mm/dd/yy;;d");009

  elseif (c.event_cd = weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",
      trim(uar_get_code_display(c.result_units_cd)))
 orders->weight_dt_tm = format(datetimezone(c.updt_dt_tm, c.performed_tz), "mm/dd/yy;;d");009

  endif
with nocounter

/******************************************************************************
*     FIND ACTIVE ALLERGIES AND CREATE ALLERGY LINE                           *
******************************************************************************/

select into "nl:"
from allergy a,
  (dummyt d with seq = 1),
  nomenclature n
plan a
  where a.person_id = request->person_id
    and a.active_ind = 1
    and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and (a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      or a.end_effective_dt_tm = NULL)
    and a.reaction_status_cd != canceled_cd
join d
join n
  where n.nomenclature_id = a.substance_nom_id
order cnvtdatetime(a.onset_dt_tm)
head report
  allergy->cnt = 0
detail
  if (n.source_string > " " or a.substance_ftdesc > " ")
    allergy->cnt = allergy->cnt + 1
    stat = alterlist(allergy->qual,allergy->cnt)
    allergy->qual[allergy->cnt].list = a.substance_ftdesc
    if (n.source_string > " ")
      allergy->qual[allergy->cnt].list = n.source_string
    endif
  endif
with nocounter,outerjoin=d,dontcare=n

for (x = 1 to allergy->cnt)
  if (x = 1)
    set allergy->line = allergy->qual[x].list
  else
    set allergy->line = concat(trim(allergy->line),", ",
      trim(allergy->qual[x].list))
  endif
endfor

if (allergy->cnt > 0)
   set pt->line_cnt = 0
   set max_length = 90
   execute dcp_parse_text value(allergy->line), value(max_length)
   set stat = alterlist(allergy->line_qual, pt->line_cnt)
   set allergy->line_cnt = pt->line_cnt
   for (x = 1 to pt->line_cnt)
     set allergy->line_qual[x].line = pt->lns[x].line
   endfor
endif

/******************************************************************************
*     USED FOR THE MNEMONIC ON PHARMACY ORDERS                                *
******************************************************************************/

set mnem_disp_level = "1"
set iv_disp_level = "0"

if (pharm_flag = 1)
   select into "nl:"
   from name_value_prefs n,app_prefs a
   plan n
     where n.pvc_name in ("MNEM_DISP_LEVEL","IV_DISP_LEVEL")
   join a
     where a.app_prefs_id = n.parent_entity_id
       and a.prsnl_id = 0
       and a.position_cd = 0
   detail
     if (n.pvc_name = "MNEM_DISP_LEVEL"
     and n.pvc_value in ("0","1","2"))
       mnem_disp_level = n.pvc_value
     elseif (n.pvc_name = "IV_DISP_LEVEL"
     and n.pvc_value in ("0","1"))
       iv_disp_level = n.pvc_value
     endif
   with nocounter
endif

/******************************************************************************
* ;023     USED FOR THE PRovider number alias pool for the patient encounter      *
******************************************************************************/
SELECT INTO "NL:"
FROM
         ENCOUNTER E
        , org_alias_pool_reltn oapr

PLAN e
 where e.encntr_id =  request->order_qual[1].encntr_id


join oapr
 where oapr.organization_id = e.organization_id
 and oapr.alias_entity_alias_type_cd = PROVIDER_NBR_CD ;1090 Provider Num
 and oapr.active_ind = 1
 and OAPR.END_EFFECTIVE_DT_TM > cnvtdatetime(curdate,curtime2)
     ;AND OAPR.alias_pool_cd != GPPROVIDER_VAR
 AND OAPR.alias_pool_cd not in ;033++
 			(GPPROVIDER_VAR, SITEPROVIDER_VAR, HPROFPROVIDER_VAR, ALLSITES_PROVIDER_VAR)


detail


 	if    (e.loc_facility_cd = 261886027)	ORG_ALIAS_POOL_VAR = 261881121	;	WHS BACCHUS MARSH PROVIDER NUMBER
	elseif(e.loc_facility_cd = 261888481)	ORG_ALIAS_POOL_VAR = 261878899	;	WHS COMM HEALTH PROVIDER NUMBER
	elseif(e.loc_facility_cd = 85758822)	ORG_ALIAS_POOL_VAR = 87458279	;	WHS FOOTSCRAY PROVIDER NUMBER
	elseif(e.loc_facility_cd = 261889053)	ORG_ALIAS_POOL_VAR = 261882409	;	WHS MELTON HEALTH PROVIDER NUMBER
	elseif(e.loc_facility_cd = 261888385)	ORG_ALIAS_POOL_VAR = 261883215	;	WHS RES CARE PROVIDER NUMBER
	elseif(e.loc_facility_cd = 86163538)	ORG_ALIAS_POOL_VAR = 87458282	;	WHS SUNBURY PROVIDER NUMBER
	elseif(e.loc_facility_cd = 86163400)	ORG_ALIAS_POOL_VAR = 87458285	;	WHS SUNSHINE PROVIDER NUMBER
	elseif(e.loc_facility_cd = 86163477)	ORG_ALIAS_POOL_VAR = 87458288	;	WHS WILLIAMSTOWN PROVIDER NUMBER
	endif

;	if(pa.alias_pool_cd = ORG_ALIAS_POOL_VAR)
;	bing->admit_provider = pa.alias
;	endif

;	ORG_ALIAS_POOL_VAR= OAPR.ALIAS_POOL_CD

with nocounter


select into 'nl;'
from encntr_prsnl_reltn eprsnlr
	, prsnl pr
	, prsnl_alias pa

plan eprsnlr
where	eprsnlr.encntr_id = request->order_qual[1].encntr_id
and		eprsnlr.encntr_prsnl_r_cd = 1116	; 'Admitting Doctor' from code set 333
and		eprsnlr.active_ind = 1	; active prsnl-encounter relationship only

join pr
where pr.person_id = eprsnlr.prsnl_person_id

join pa where pa.person_id = outerjoin(eprsnlr.prsnl_person_id)
 and pa.prsnl_alias_type_cd = outerjoin(1090)
 and pa.active_ind = outerjoin(1)
 and pa.end_effective_dt_tm > outerjoin(sysdate+1)
 and pa.alias_pool_cd = outerjoin(ORG_ALIAS_POOL_VAR)

detail

	bing->admit_provider = pr.name_full_formatted
	bing->admit_provider_PN = pa.alias

with nocounter



/******************************************************************************
*     ORDER LEVEL INFORMATION                                                 *
******************************************************************************/

set ord_cnt = 0

select
	if (orders->reprint_ind = 0)

plan d1
join o
  where o.order_id = request->order_qual[d1.seq].order_id
  and o.order_status_cd = ordered_cd
join oc where oc.catalog_cd = o.catalog_cd
join oa
  where oa.order_id = o.order_id
    and ((request->order_qual[d1.seq].conversation_id > 0 and    ;017
          oa.order_conversation_id = request->order_qual[d1.seq].conversation_id) or
          (request->order_qual[d1.seq].conversation_id <= 0 and oa.action_sequence = o.last_action_sequence))
join pl
  where pl.person_id = oa.action_personnel_id
join pl2
  where pl2.person_id = oa.order_provider_id
join pa where pa.person_id = outerjoin(pl2.person_id)  ;018
     ;020 and pa.prsnl_alias_type_cd = outerjoin(DOCNBR_CD) ;018
     and pa.prsnl_alias_type_cd = outerjoin(PROVIDER_NBR_CD) ;020
     and pa.active_ind = outerjoin(1)                  ;018
     and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3) )  ;023
     ;and pa.alias_pool_cd =outerjoin(ORG_ALIAS_POOL_VAR) ;023
join d2
join oef
  where oef.oe_format_id = o.oe_format_id
    and oef.action_type_cd = oa.action_type_cd


endif

into "nl:"
from  orders o,
	  order_catalog oc,
      order_action oa,
      prsnl pl,
      prsnl pl2,
      prsnl_alias pa, ;018
      oe_format_fields oef,
      (dummyt d1 with seq = value(order_cnt)),
      (dummyt d2 with seq = value(order_cnt))
plan d1
join o
  where o.order_id = request->order_qual[d1.seq].order_id

join oc where oc.catalog_cd = o.catalog_cd

join oa
  where oa.order_id = o.order_id
    and ((request->order_qual[d1.seq].conversation_id > 0 and    ;017
          oa.order_conversation_id = request->order_qual[d1.seq].conversation_id) or
          (request->order_qual[d1.seq].conversation_id <= 0 and oa.action_sequence = o.last_action_sequence))
join pl
  where pl.person_id = oa.action_personnel_id

join pl2
  where pl2.person_id = oa.order_provider_id

 join pa where pa.person_id = outerjoin(pl2.person_id)  ;018
     ;020 and pa.prsnl_alias_type_cd = outerjoin(DOCNBR_CD) ;018
     and pa.prsnl_alias_type_cd = outerjoin(PROVIDER_NBR_CD) ;020
     and pa.active_ind = outerjoin(1)                  ;018
     and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3) )  ;023
 	 ;and pa.alias_pool_cd = outerjoin(ORG_ALIAS_POOL_VAR);023

join d2
join oef
  where oef.oe_format_id = o.oe_format_id
    and oef.action_type_cd = oa.action_type_cd


order by o.oe_format_id,
 o.activity_type_cd,
 oc.activity_subtype_cd,
 o.current_start_dt_tm,
 o.order_id,                       ;024
 pa.prsnl_alias_id   ;023

head report
  orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  mnemonic_size = size(o.ordered_as_mnemonic,3) - 1	;016 ; MB swapped out o.hna_order_mnemonic

head o.order_id
  ord_cnt = ord_cnt + 1
  orders->qual[ord_cnt].status = uar_get_code_display(o.order_status_cd)
  if (orders->qual[ord_cnt].status = "Discontinued")
  	orders->qual[ord_cnt].status = "Cancelled"
  endif

  orders->qual[ord_cnt].catalog = uar_get_code_display(o.catalog_type_cd)
  orders->qual[ord_cnt].catalog_type_cd = o.catalog_type_cd
  orders->qual[ord_cnt].activity = uar_get_code_display(o.activity_type_cd)
  orders->qual[ord_cnt].activity_subtype_mean = trim(uar_get_code_meaning(oc.activity_subtype_cd),3) ;026
  orders->qual[ord_cnt]->activity_type_cd = o.activity_type_cd
  orders->qual[ord_cnt].activity_subtype_cd = oc.activity_subtype_cd
  orders->qual[ord_cnt].display_line = o.clinical_display_line
  orders->qual[ord_cnt].order_id = o.order_id
  orders->qual[ord_cnt].display_ind = 1
  orders->qual[ord_cnt].conversation_id = oa.order_conversation_id
  orders->qual[ord_cnt].template_order_flag = o.template_order_flag
  orders->qual[ord_cnt].cs_flag = o.cs_flag
  orders->qual[ord_cnt].oe_format_id = o.oe_format_id
  if (substring(245,10,o.clinical_display_line) > "  ")
    orders->qual[ord_cnt].clin_line_ind = 1
  else
    orders->qual[ord_cnt].clin_line_ind = 0
  endif
 ;026  - to force orders with no accession to top of print list
 orders->qual[ord_cnt].accession = "000000000000000001"
  orders->qual[ord_cnt].container_id = "00-00-000-0000A"

  ;BEGIN 016
   mnem_length = size(trim(o.ordered_as_mnemonic),1) ; MB swapped out o.hna_order_mnemonic
  if (mnem_length >= mnemonic_size
  	  and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...") ; MB swapped out o.hna_order_mnemonic
  	orders->qual[ord_cnt].mnemonic = concat((trim(o.ordered_as_mnemonic)), "...") ; MB swapped out o.hna_order_mnemonic
  else
    orders->qual[ord_cnt].mnemonic = (trim(o.ordered_as_mnemonic)) ; MB swapped out o.hna_order_mnemonic
  endif

   orders->qual[ord_cnt].mnemonic_sort =  orders->qual[ord_cnt].mnemonic
  if (orders->qual[ord_cnt].status != "Ordered")
  	;orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,char(10),char(13),
  	;"(",orders->qual[ord_cnt].status,")")
  orders->qual[ord_cnt].mnemonic = concat("{\fonttbl{\f0\fswiss Helv;}}\plain\f0 ",orders->qual[ord_cnt].mnemonic,"\par ",
  	"\b (",orders->qual[ord_cnt].status,") \par")
  else
  orders->qual[ord_cnt].mnemonic = concat("{\fonttbl{\f0\fswiss Helv;}}\plain\f0\plain ",orders->qual[ord_cnt].mnemonic," \par")
  endif
  ;END 016
;016  orders->qual[ord_cnt].mnemonic = cnvtupper(trim(o.hna_order_mnemonic))

  if(CURUTC>0);Begin 011
  orders->qual[ord_cnt].order_dt =  concat(format(datetimezone(oa.order_dt_tm, oa.order_tz), "mm/dd/yy;;d"),
        " ", datetimezonebyindex(oa.order_tz,offset,daylight,7,oa.order_dt_tm))
  else
  orders->qual[ord_cnt].order_dt = format(oa.order_dt_tm,"mm/dd/yy hh:mm;;qm")
  endif ;End 011

 orders->qual[ord_cnt].signed_dt=format(datetimezone(o.orig_order_dt_tm, o.orig_order_tz), "mm/dd/yy;;d");009

  orders->qual[ord_cnt].comment_ind = o.order_comment_ind
  orders->qual[ord_cnt].last_action_seq = o.last_action_sequence
  orders->qual[ord_cnt].enter_by = pl.name_full_formatted
  orders->qual[ord_cnt].order_dr = pl2.name_full_formatted
 ; orders->qual[ord_cnt].order_docnbr = cnvtalias(pa.alias,pa.alias_pool_cd)  ;023
  orders->qual[ord_cnt].type = uar_get_code_display(oa.communication_type_cd)
  orders->qual[ord_cnt].action_type_cd = oa.action_type_cd
  orders->qual[ord_cnt].action = uar_get_code_display(oa.action_type_cd)
  orders->qual[ord_cnt].iv_ind = o.iv_ind
  if (o.dcp_clin_cat_cd = iv_cd)
    orders->qual[ord_cnt].iv_ind = 1
  endif
  if (o.catalog_type_cd = pharmacy_cd)
    if (mnem_disp_level = "0")
	  ;BEGIN 016
	  mnem_length = size(trim(o.ordered_as_mnemonic),1) ; MB swapped out o.hna_order_mnemonic
	  if (mnem_length >= mnemonic_size
	  	  and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...") ; MB swapped out o.hna_order_mnemonic
	  	orders->qual[ord_cnt].mnemonic = concat(trim(o.ordered_as_mnemonic), "...") ; MB swapped out o.hna_order_mnemonic
	  else
	    orders->qual[ord_cnt].mnemonic = trim(o.ordered_as_mnemonic) ; MB swapped out o.hna_order_mnemonic
	  endif
	  ;END 016
;016      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
    endif
    if (mnem_disp_level = "1")
      if (o.hna_order_mnemonic = o.ordered_as_mnemonic
      or o.ordered_as_mnemonic = " ")
      	;BEGIN 016
      	mnem_length = size(trim(o.hna_order_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
	    else
	      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
	    endif
	    ;END 016
;016        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
      else
      	;BEGIN 016
      	mnem_length = size(trim(o.hna_order_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
	    else
	      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
	    endif

	    mnem_length = size(trim(o.ordered_as_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),"...)")
	    else
	      orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),")")
	    endif
	    ;END 016
;016        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o.ordered_as_mnemonic),")")
      endif
    endif
    if (mnem_disp_level = "2" and o.iv_ind != 1)
      if (o.hna_order_mnemonic = o.ordered_as_mnemonic
      or o.ordered_as_mnemonic = " ")
      	;BEGIN 016
      	mnem_length = size(trim(o.hna_order_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
	    else
	      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
	    endif
	    ;END 016
;016        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
      else
      	;BEGIN 016
      	mnem_length = size(trim(o.hna_order_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
	    else
	      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
	    endif

	    mnem_length = size(trim(o.ordered_as_mnemonic),1)
	    if (mnem_length >= mnemonic_size
	    	and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),"...)")
	    else
	      orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),")")
	    endif
	    ;END 016
;016        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o.ordered_as_mnemonic),")")
      endif
      if (o.order_mnemonic != o.ordered_as_mnemonic and o.order_mnemonic > " ")
      	;BEGIN 016
      	mnem_length = size(trim(o.order_mnemonic),1)
      	if (mnem_length >= mnemonic_size
      		and SUBSTRING(mnem_length - 3, mnem_length, o.order_mnemonic) != "...")
	  	  orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o.order_mnemonic),"...)")
	    else
	      orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o.order_mnemonic),")")
	    endif
	    ;END 016
;016        orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o.order_mnemonic),")")
      endif
    endif
  endif

  if (oef.action_type_cd > 0)
    orders->qual[ord_cnt].fmt_action_cd = oef.action_type_cd
  else
    orders->qual[ord_cnt].fmt_action_cd = order_cd
  endif

/*****************************************************************************
 *Put logic in here if you want to keep certain types of orders to not print *
 *May be things like complete orders/continuing orders/etc..                 *
 *****************************************************************************/

;;if (oa.action_type_cd in (order_cd,modify_cd,cancel_cd,discont_cd,studactivate_cd)) ;006,008
;  if ((oa.action_type_cd in (order_cd,modify_cd,cancel_cd,discont_cd,activate_cd,studactivate_cd)) AND o.encntr_id>0) ;008


If ( (orders->reprint_ind = 0 and oa.action_type_cd = order_cd and o.encntr_id>0)   ;029 auto printing part chg
   Or
   	 (orders->reprint_ind = 1 and o.encntr_id>0 and oa.action_type_cd
     in (order_cd,modify_cd,cancel_cd,discont_cd,activate_cd,studactivate_cd,status_change_cd))   )

 	  orders->qual[ord_cnt]->display_ind = 1
	  orders->spoolout_ind = 1


;if ((oa.action_type_cd
;in (order_cd,modify_cd,cancel_cd,discont_cd,activate_cd,studactivate_cd,status_change_cd)) AND o.encntr_id>0) ;008 ;021
;     orders->qual[ord_cnt]->display_ind = 1
;     orders->spoolout_ind = 1

  else
     orders->qual[ord_cnt]->display_ind = 0
  endif


 ;---023----------------------------------------------------------------------
;  Chk for provider no. in encounter facility pool and use if exists

head pa.prsnl_alias_id  ;023

  if (pa.alias_pool_cd = ORG_ALIAS_POOL_VAR) ;023
  		orders->qual[ord_cnt].order_docnbr = cnvtalias(pa.alias,pa.alias_pool_cd)
  endif

foot pa.prsnl_alias_id  ;023
null

 ;--If no provider no. in encounter facility pool then get any one if exists for the MO otherwise it will stay blank
foot o.order_id  ;023

 	If  (orders->qual[ord_cnt].order_docnbr = "" )
 		 orders->qual[ord_cnt].order_docnbr = '--' ;cnvtalias(pa.alias,pa.alias_pool_cd)
 	endif

;------------------------------------------------------------------------------
foot report
	orders->cnt = ord_cnt
    orders->total_cnt = orders->cnt

    if (orders->reprint_ind = 0)
    	stat = alterlist(orders->qual,orders->cnt)
    endif
with outerjoin = d2, nocounter

/******************************************************************************
*  GET ORDER DETAIL INFORMATION                                               *
******************************************************************************/

select into "nl:"
from order_detail od,
     oe_format_fields oef,
     order_entry_fields of1,
     (dummyt d1 with seq = value(order_cnt))

plan d1
  join od
    where orders->qual[d1.seq].order_id = od.order_id
  join oef
    where oef.oe_format_id = orders->qual[d1.seq].oe_format_id
      ;and oef.action_type_cd = orders->qual[d1.seq].fmt_action_cd
      and oef.oe_field_id = od.oe_field_id
  join of1
    where of1.oe_field_id = oef.oe_field_id
  ;order by od.order_id, od.oe_field_id, od.action_sequence desc
  order by od.order_id, od.detail_sequence, od.oe_field_id, od.action_sequence desc

;if order details need to print in the order on the format...try this order by
; order by od.order_id,oef.group_seq,oef.field_seq,od.oe_field_id,
;          od.action_sequence desc

  head report
    orders->qual[d1.seq].d_cnt = 0
  head od.order_id
    stat = alterlist(orders->qual[d1.seq].d_qual,5)
    orders->qual[d1.seq].stat_ind = 0
  head od.oe_field_id
    act_seq = od.action_sequence
    odflag = 1
    if (od.oe_field_meaning = "COLLPRI" or
        od.oe_field_meaning = "PRIORITY")
      orders->qual[d1.seq].priority = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "REQSTARTDTTM")
      ;020 orders->qual[d1.seq].req_st_dt = od.oe_field_display_value
      orders->qual[d1.seq].req_st_dt = format(od.oe_field_dt_tm_value,"dd/mm/yyyy hh:mm;;qm")	;020
      orders->qual[d1.seq].req_st_dt_tm = od.oe_field_dt_tm_value	;020
    endif
    if (od.oe_field_meaning = "FREQ")
      orders->qual[d1.seq].frequency = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "RATE")
      orders->qual[d1.seq].rate = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "DURATION")
      orders->qual[d1.seq].duration = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "DURATIONUNIT")
      orders->qual[d1.seq].duration_unit = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "NURSECOLLECT")
      orders->qual[d1.seq].nurse_collect = od.oe_field_display_value
    endif
    if (od.oe_field_meaning = "SPECIMEN TYPE")
      orders->qual[d1.seq].specimen_type = od.oe_field_display_value
    endif
	if ((od.oe_field_meaning = "OTHER") and (of1.description = "Fasting"))
      orders->qual[d1.seq].fasting = od.oe_field_display_value
    endif
;  head od.action_sequence
;    if (act_seq != od.action_sequence)
;      odflag = 0
;    endif
;  detail
;    if (odflag = 1)
      orders->qual[d1.seq].d_cnt=orders->qual[d1.seq].d_cnt+1
      dc = orders->qual[d1.seq].d_cnt
      if (dc > size(orders->qual[d1.seq].d_qual,5))
        stat = alterlist(orders->qual[d1.seq].d_qual,dc + 5)
      endif

      orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text)

	 		call echo("substring")
	 		call echo(orders->qual[d1.seq].d_qual[dc].label_text)
	 		call echo(size(orders->qual[d1.seq].d_qual[dc].label_text))
	 		call echo((size(orders->qual[d1.seq].d_qual[dc].label_text) ))
	 		call echo(substring((size(orders->qual[d1.seq].d_qual[dc].label_text)),1,orders->qual[d1.seq].d_qual[dc].label_text))
      if (substring((size(orders->qual[d1.seq].d_qual[dc].label_text)),1,orders->qual[d1.seq].d_qual[dc].label_text) = ":")
      	orders->qual[d1.seq].d_qual[dc].label_text = replace(orders->qual[d1.seq].d_qual[dc].label_text,":","",2)
      endif
      orders->qual[d1.seq].d_qual[dc].field_value=od.oe_field_value
      orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq
      orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id
      orders->qual[d1.seq].d_qual[dc].value = trim(od.oe_field_display_value)
      orders->qual[d1.seq].d_qual[dc].clin_line_ind = oef.clin_line_ind
      orders->qual[d1.seq].d_qual[dc].label =trim(oef.clin_line_label)
      orders->qual[d1.seq].d_qual[dc].suffix = oef.clin_suffix_ind
      orders->qual[d1.seq].d_qual[dc].field_description = of1.description
      orders->qual[d1.seq].d_qual[dc].oe_field_meaning = od.oe_field_meaning
      orders->qual[d1.seq].d_qual[dc].accept_ind = oef.accept_flag

      if (od.oe_field_display_value > " ")
        orders->qual[d1.seq].d_qual[dc].print_ind = 0
      else
        orders->qual[d1.seq].d_qual[dc].print_ind = 1
      endif

      if (od.oe_field_dt_tm_value != NULL) ;Begin 020
;        if (CURUTC>0)
 ;         orders->qual[d1.seq].d_qual[dc].value = datetimezoneformat(od.oe_field_dt_tm_value, od.oe_field_tz,
  ;             "MM/dd/yy HH:mm;;qm") ;022
   ;     else
          orders->qual[d1.seq].d_qual[dc].value = format(od.oe_field_dt_tm_value, "dd/mm/yy hh:mm;;qm") ;028 chged format
    ;    endif
      else
        orders->qual[d1.seq].d_qual[dc].value = trim(od.oe_field_display_value)
      endif ;End 020

 case (of1.description)
 	of "Blood Products Requested": orders->qual[d1.seq].bp_required = orders->qual[d1.seq].d_qual[dc].value
	of "Special Requirements"                     : orders->qual[d1.seq].special_requirements 	=
		orders->qual[d1.seq].d_qual[dc].value
	of "Date / Time Product Required"             : orders->qual[d1.seq].dt_tm_product_required =
												     orders->qual[d1.seq].d_qual[dc].value
	of "Date Product Required" 				: orders->qual[d1.seq].dt_tm_product_required =
												     orders->qual[d1.seq].d_qual[dc].value
	of "Pregnancy or Miscarriage in last 3 months": orders->qual[d1.seq].preg_last_3_months 		=
	orders->qual[d1.seq].d_qual[dc].value
	of "Transfusion in last 3 months"             : orders->qual[d1.seq].tx_last_3_months 			=
	orders->qual[d1.seq].d_qual[dc].value
	of "Previous Transfusion Reaction?"           : orders->qual[d1.seq].prev_tx_reaction 			=
	orders->qual[d1.seq].d_qual[dc].value
	of "Known Red Cell Antibodies (Specify)"      : orders->qual[d1.seq].red_cell_antibodies 		=
	orders->qual[d1.seq].d_qual[dc].value
	;030++
	;of "Units Required (RBC)"						: orders->qual[d1.seq].wh_units_required		=
	of "# Units Required (RBC)"						: orders->qual[d1.seq].wh_units_required		=
	orders->qual[d1.seq].d_qual[dc].value
	of "Indication for Transfusion"					: orders->qual[d1.seq].wh_clinical_indication  =
	orders->qual[d1.seq].d_qual[dc].value
	of "CMV Neg"									: orders->qual[d1.seq].wh_cmv_neg 				=
	orders->qual[d1.seq].d_qual[dc].value
	of "Irradiated"									: orders->qual[d1.seq].wh_irradiated 			=
	orders->qual[d1.seq].d_qual[dc].value
	of "Clinician Callback Number"					: orders->qual[d1.seq].wh_clinician_callback 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Anti-D in last 3 months"					: orders->qual[d1.seq].wh_anti_d			 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Known Red Cell Antibodies (Specify)"		: orders->qual[d1.seq].wh_known_rbc_abs		 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Specify Known RBC Abs"						: orders->qual[d1.seq].wh_specify_known_rbc_abs	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Hb"											: orders->qual[d1.seq].wh_hb	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Platelet Count"								: orders->qual[d1.seq].wh_platelet_count	=
	orders->qual[d1.seq].d_qual[dc].value
	of "INR"										: orders->qual[d1.seq].wh_inr	=
	orders->qual[d1.seq].d_qual[dc].value
	of "APTT"										: orders->qual[d1.seq].wh_aptt	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Fibrinogen"									: orders->qual[d1.seq].wh_fibrinogen	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Actively Bleeding"							: orders->qual[d1.seq].wh_active_bleeding 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Fresh (<..... Days)"						: orders->qual[d1.seq].wh_fresh 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Special Modified components"						: orders->qual[d1.seq].wh_other_requirements 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Site Required"						: orders->qual[d1.seq].wh_site_required 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Date/Time Required:"						: orders->qual[d1.seq].wh_dt_required 	=
	orders->qual[d1.seq].d_qual[dc].value
	of "Vials / Units Required"						: orders->qual[d1.seq].wh_vials_units_required 	=
	orders->qual[d1.seq].d_qual[dc].value
	;030--
 endcase

/*
      if ((od.oe_field_meaning_id = 1100
           or od.oe_field_meaning_id = 8
           or OD.OE_FIELD_MEANING_ID = 127
           or od.oe_field_meaning_id = 43)
           and trim(cnvtupper(od.oe_field_display_value)) = "STAT")
        orders->qual[d1.seq].stat_ind = 1
      endif
      if (of1.field_type_flag = 7)
        if (od.oe_field_value = 1)
          if (oef.disp_yes_no_flag = 0 or oef.disp_yes_no_flag = 1)
            orders->qual[d1.seq].d_qual[dc].value = trim(oef.label_text)
          else
            orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
          endif
        else
          if (oef.disp_yes_no_flag = 0 or oef.disp_yes_no_flag = 2)
            orders->qual[d1.seq].d_qual[dc].value = trim(oef.clin_line_label)
          else
            orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
          endif
        endif
      endif */
;    endif
  foot od.order_id
    stat = alterlist(orders->qual[d1.seq].d_qual, dc)
  with nocounter


select into "nl:"
from order_detail od,
     oe_format_fields oef,
     order_entry_fields of1,
     (dummyt d1 with seq = value(order_cnt))

plan d1
	where orders->qual[d1.seq].req_st_dt_tm = 0.0
  join od
    where orders->qual[d1.seq].order_id = od.order_id
    and od.oe_field_meaning = "REQSTARTDTTM"
  join oef
    ;where oef.oe_format_id = orders->qual[d1.seq].oe_format_id
   ;   and oef.action_type_cd = orders->qual[d1.seq].fmt_action_cd
    where oef.oe_field_id = od.oe_field_id
  join of1
    where of1.oe_field_id = oef.oe_field_id
  order by od.order_id, od.oe_field_id, od.action_sequence desc
  detail
      orders->qual[d1.seq].req_st_dt = format(od.oe_field_dt_tm_value,"dd/mm/yyyy hh:mm;;qm")	;020
      orders->qual[d1.seq].req_st_dt_tm = od.oe_field_dt_tm_value	;020
with nocounter


call echo("finding copy to physicians")
select into "nl:"
from order_detail od,
     oe_format_fields oef,
     order_entry_fields of1,
     (dummyt d1 with seq = value(order_cnt))

plan d1
  join od
    where orders->qual[d1.seq].order_id = od.order_id
    and od.oe_field_meaning = "FREETEXTPHYS"
  join oef
    where oef.oe_format_id = orders->qual[d1.seq].oe_format_id
      and oef.action_type_cd = orders->qual[d1.seq].fmt_action_cd
      and oef.oe_field_id = od.oe_field_id
  join of1
    where of1.oe_field_id = oef.oe_field_id
    and   of1.description = "Copy Results to Dr*"
  order by od.order_id, od.detail_sequence,od.oe_field_id, od.action_sequence desc


  head report
    macro (add_copydoctors)
    	stat = alterlist(copydoctors->qual,size(copydoctors->qual,5) +1)
    	copydoctors->qual[size(copydoctors->qual,5)].name = od.oe_field_display_value
    	call echo(od.order_id)
    	call echo(build("adding copy to doc:",copydoctors->qual[size(copydoctors->qual,5)].name))
    endmacro
    found_ndx = 0
    eval_ndx = 0
   head od.order_id
	found_ndx = 0
    eval_ndx = 0
  head od.oe_field_id
    act_seq = od.action_sequence
    odflag = 1
  head od.action_sequence
    if (act_seq != od.action_sequence)
      odflag = 0
    endif
  detail
    if (odflag = 1)
    found_ndx = 0
    eval_ndx = 0

 	found_ndx = locateval(eval_ndx, 1, size(copydoctors->qual,5), trim(od.oe_field_display_value),
 					copydoctors->qual[eval_ndx].name)
 	if (found_ndx = 0)
 		add_copydoctors
	endif
	endif
 foot report
 call echorecord(copydoctors)
 for (i = 1 to size(copydoctors->qual,5))
 	if (i = 1)
 		orders->copy_to = copydoctors->qual[i].name
 	else
 		orders->copy_to = concat(orders->copy_to,"; ",
 		copydoctors->qual[i].name)
 	endif
 endfor
 with nocounter


/******************************************************************************
*   Find Missing Priorities                     *
******************************************************************************/
select into "nl:"
from order_detail od,
     (dummyt d1 with seq = value(order_cnt))

plan d1
	where orders->qual[d1.seq].status != "Ordered"
	and orders->qual[d1.seq].priority = ""
join od
    where orders->qual[d1.seq].order_id = od.order_id
    and (od.oe_field_meaning = "COLLPRI" or
         od.oe_field_meaning = "PRIORITY" or
         od.oe_field_meaning = "SPECIMEN TYPE")
  order by od.order_id, od.oe_field_id, od.action_sequence desc
  head od.order_id
  	null
  head od.oe_field_id
  call echo(build("found od for ",orders->qual[d1.seq].mnemonic))
    if (od.oe_field_meaning = "COLLPRI" or
        od.oe_field_meaning = "PRIORITY")
      orders->qual[d1.seq].priority = od.oe_field_display_value
      call echo(orders->qual[d1.seq].priority)
    endif
    if (od.oe_field_meaning = "SPECIMEN TYPE")
      orders->qual[d1.seq].specimen_type = od.oe_field_display_value
    endif
with nocounter





/******************************************************************************
*   BUILD ORDER DETAILS LINE IF IT EXCEEDS 255 CHARACTERS                     *
******************************************************************************/

for (x = 1 to order_cnt)
  if (orders->qual[x].clin_line_ind = 1)
    set started_build_ind = 0
    for (fsub = 1 to 31)
      for (xx = 1 to orders->qual[x].d_cnt)
        if ((orders->qual[x].d_qual[xx].group_seq = fsub or fsub = 31)
             and orders->qual[x].d_qual[xx].print_ind = 0)
;          set orders->qual[x].d_qual[xx].print_ind = 1   ;004
          if (orders->qual[x].d_qual[xx].clin_line_ind = 1)
            if (started_build_ind = 0)
              set started_build_ind = 1
              if (orders->qual[x].d_qual[xx].suffix = 0
                  and orders->qual[x].d_qual[xx].label > "  ")
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].label)," ",
                    trim(orders->qual[x].d_qual[xx].value))
              elseif (orders->qual[x].d_qual[xx].suffix = 1
                      and orders->qual[x].d_qual[xx].label > " ")
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].value)," ",
                    trim(orders->qual[x].d_qual[xx].label))
              else
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].value)," ")
              endif
            else
              if (orders->qual[x].d_qual[xx].suffix = 0
                  and orders->qual[x].d_qual[xx].label > "  ")
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].label)," ",
                    trim(orders->qual[x].d_qual[xx].value))
              elseif (orders->qual[x].d_qual[xx].suffix = 1
                      and orders->qual[x].d_qual[xx].label > " ")
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].value)," ",
                    trim(orders->qual[x].d_qual[xx].label))
              else
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].value)," ")
              endif
            endif
          endif
        endif
      endfor
    endfor
  endif
endfor

/******************************************************************************
*  LINE WRAPPING FOR ORDER DETAILS                                            *
******************************************************************************/

for (x = 1 to order_cnt)
  if (orders->qual[x].display_line > " ")
   set pt->line_cnt = 0
   set max_length = 90
   execute dcp_parse_text value(orders->qual[x].display_line),value(max_length)
   set stat = alterlist(orders->qual[x].disp_ln_qual, pt->line_cnt)
   set orders->qual[x].disp_ln_cnt = pt->line_cnt
   for (y = 1 to pt->line_cnt)
     set orders->qual[x].disp_ln_qual[y].disp_line = pt->lns[y].line
   endfor
  endif
endfor

/** Begin 018 **/
;Get Pager Number from OEF
select into "nl:"
from (dummyt d with seq = value(size(orders->qual,5))),
     order_detail od
plan d
join od where od.order_id = orders->qual[d.seq].order_id
     and od.oe_field_id = 7275280 ;Pager Number
order d.seq,
      od.action_sequence
head d.seq
  null
head od.action_sequence
  orders->qual[d.seq].pager_nbr = trim(od.oe_field_display_value,3)
with nocounter

;Get Copy To
declare cp_to = vc with protect, noconstant("")

select into "nl:"
from (dummyt d with seq = value(size(orders->qual,5))),
     order_detail od
plan d
join od where od.order_id = orders->qual[d.seq].order_id
     and od.oe_field_meaning = "CONSULTDOC"
order d.seq,
      od.oe_field_display_value
head d.seq
  cp_to = ""
head od.oe_field_display_value
  if (size(trim(cp_to,3)) = 0)
    cp_to = trim(od.oe_field_display_value,3)
  else
    cp_to = concat(cp_to,"; ",trim(od.oe_field_display_value,3))
  endif
foot d.seq
  orders->qual[d.seq].copy_to = trim(cp_to,3)
with nocounter

;Get Clinical History (comments)
declare CLINHIST_CD = f8 with protect, constant(uar_get_code_by("MEANING",14,"CLINHIST"))
declare GENCLINHIST_CD = f8 with protect, constant(uar_get_code_by("MEANING",14,"GENCLINHIST"))
declare clin_hist = vc with protect, noconstant("")

select  if (orders->reprint_ind = 0)
			plan d
				join oc where oc.order_id = orders->qual[d.seq].order_id
			     and oc.comment_type_cd in(CLINHIST_CD,GENCLINHIST_CD)
join lt where lt.long_text_id = oc.long_text_id and lt.active_ind = 1
		endif
 into "nl:"
	sort_thingy = if (oc.comment_type_cd = CLINHIST_CD) 1
					else 2
				endif
from (dummyt d with seq = value(size(orders->qual,5))),
     order_comment oc,
     long_text lt
plan d
join oc where oc.order_id = orders->qual[d.seq].order_id
     and oc.comment_type_cd in(CLINHIST_CD,GENCLINHIST_CD)
join lt where lt.long_text_id = oc.long_text_id
and lt.active_ind = 1
order sort_thingy,d.seq,lt.long_text_id desc
head d.seq
  clin_hist = ""
  found_ndx = 0
  eval_ndx = 0
  gen_cnt = 0
detail
 found_ndx = 0
 found_ndx = locateval(eval_ndx, 1, size(comments->qual,5), trim(lt.long_text), comments->qual[eval_ndx].long_text)
 if (found_ndx = 0)
  stat = alterlist(comments->qual, size(comments->qual,5) + 1)
  comments->qual[size(comments->qual,5)].long_text = trim(lt.long_text)
  comments->qual[size(comments->qual,5)].order_id = oc.order_id
  if (oc.comment_type_cd = GENCLINHIST_CD)
  	gen_cnt = (gen_cnt + 1)
  	comments->qual[size(comments->qual,5)].gen_hist = gen_cnt
  	comments->qual[size(comments->qual,5)].order_id = 0.0
  endif
  if (size(trim(clin_hist,3)) = 0)
    clin_hist = trim(lt.long_text,3)
  else
    clin_hist = concat(clin_hist,char(10),char(13),trim(lt.long_text,3))
  endif
 endif
foot d.seq
  orders->qual[d.seq].clin_hist = clin_hist
foot report
	call echo(build("setting up ",cnvtstring(size(comments->qual,5)), " comments"))
	 for (i = 1 to size(comments->qual,5))
 	if (i = 1)
 		orders->clin_hist = comments->qual[i].long_text
 	else
 		orders->clin_hist = concat(orders->clin_hist,char(10),char(13),
 		comments->qual[i].long_text)
 	endif
 	call echo(build("new orders->clin_hist=",orders->clin_hist))
 endfor
with nocounter

call echorecord(comments)





/** End 018 **/
/******************************************************************************
*    GET ACCESSION NUMBER                                                     *
******************************************************************************/
call echo(build("ORDER CNT IS  ",order_cnt))
call echorecord(orders )

for (x = 1 to order_cnt)
  select into "nl:"
  from accession_order_r aor
      ,order_container_r oc
  	  ,container_accession ocr
  	  ,container c
  plan aor
    where aor.order_id = orders->qual[x].order_id
  join oc
  	where oc.order_id = aor.order_id
  join c
  	where c.container_id = oc.container_id
  join ocr
  	where ocr.container_id = c.container_id


  detail
    orders->qual[x].accession = aor.accession

	orders->qual[x].container_id  = concat(
			    trim(cnvtacc(aor.accession)),
			    EVALUATE (
			    ocr.ACCESSION_CONTAINER_NBR, 1, "A", 2, "B",3, "C", 4, "D",
			    5, "E", 6, "F", 7, "G", 8, "H", 9, "I", 10, "J", 11, "K",12, "L", 13, "M", 14, "N",
			            15, "O", 16, "P", 17, "Q", 18, "R", 19, "S", 20, "T", 21,"U", 22, "V", 23, "W",
			            24, "X", 25, "Y", 26, "Z", TRIM (CNVTSTRING
			(ocr.ACCESSION_CONTAINER_NBR))))


  with nocounter

endfor
 call echorecord(orders )
/******************************************************************************
*      BUILD ORDERABLE FOR IV ORDERS                                          *
******************************************************************************/
set mnemonic_size = 0

for (x = 1 to order_cnt)
  if (orders->qual[x].iv_ind = 1)
    select into "nl:"
    from order_ingredient oi
    plan oi
      where oi.order_id = orders->qual[x].order_id
    order oi.action_sequence,oi.comp_sequence
    head oi.action_sequence
      mnemonic_line = fillstring(1000," ")
      first_time = "Y"

      if (mnemonic_size = 0)
      	mnemonic_size = size(oi.ordered_as_mnemonic, 3) - 1
      endif

    detail
      if (first_time = "Y")
        if (oi.ordered_as_mnemonic > " ")
        	;BEGIN 016
        	mnem_length = size(trim(oi.ordered_as_mnemonic),1)
        	if (mnem_length >= mnemonic_size
        		and SUBSTRING(mnem_length - 3, mnem_length, oi.ordered_as_mnemonic) != "...")
		    	mnemonic_line = concat(trim(oi.ordered_as_mnemonic),"..., ",trim(oi.order_detail_display_line))
		    else
		    	mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line))
		    endif
		    ;END 016
        else
        	;BEGIN 016
        	mnem_length = size(trim(oi.order_mnemonic),1)
        	if (mnem_length >= mnemonic_size
        		and SUBSTRING(mnem_length - 3, mnem_length, oi.order_mnemonic) != "...")
		    	mnemonic_line = concat(trim(oi.order_mnemonic),"..., ",trim(oi.order_detail_display_line))
		    else
		    	mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
		    endif
		    ;END 016
        endif
        first_time = "N"
      else
        if (oi.ordered_as_mnemonic > " ")
        	;BEGIN 016
        	mnem_length = size(trim(oi.ordered_as_mnemonic),1)
        	if (mnem_length >= mnemonic_size
        		and SUBSTRING(mnem_length - 3, mnem_length, oi.ordered_as_mnemonic) != "...")
		    	mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),"..., ",
		    		trim(oi.order_detail_display_line))
		    else
		    	mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",
		    		trim(oi.order_detail_display_line))
		    endif
		    ;END 016
        else
        	;BEGIN 016
        	mnem_length = size(trim(oi.order_mnemonic),1)
        	if (mnem_length >= mnemonic_size
        		and SUBSTRING(mnem_length - 3, mnem_length, oi.order_mnemonic) != "...")
		    	mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),"..., ",
		    		trim(oi.order_detail_display_line))
		    else
		    	mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",
		    		trim(oi.order_detail_display_line))
		    endif
		    ;END 016
        endif
      endif
    foot report
      orders->qual[x].mnemonic = mnemonic_line
    with nocounter
  endif
endfor

/******************************************************************************
*   LINE WRAPPING FOR ORDERABLE                                               *
******************************************************************************/

for (x = 1 to order_cnt)
  if (orders->qual[x].mnemonic > " ")
   set pt->line_cnt = 0
   set max_length = 90
   execute dcp_parse_text value(orders->qual[x].mnemonic),value(max_length)
   set stat = alterlist(orders->qual[x].mnem_ln_qual, pt->line_cnt)
   set orders->qual[x].mnem_ln_cnt = pt->line_cnt
   for (y = 1 to pt->line_cnt)
     set orders->qual[x].mnem_ln_qual[y].mnem_line = pt->lns[y].line
   endfor
  endif
endfor

/******************************************************************************
*     RETRIEVE ORDER COMMENT AND LINE WRAPPING                                *
******************************************************************************/

for (x = 1 to order_cnt)
  if (orders->qual[x].comment_ind = 1)
    select into "nl:"
    from order_comment oc,
      long_text lt
    plan oc
      where oc.order_id = orders->qual[x].order_id
        and oc.comment_type_cd = comment_cd
    join lt
      where lt.long_text_id = oc.long_text_id
      and lt.active_ind = 1
    detail
      orders->qual[x].comment = lt.long_text
    with nocounter

 ;   set orders->qual[x].display_line = concat("{\fonttbl{\f0\fswiss Helv;}}\plain\f0 ",
 ;   	orders->qual[x].display_line,"  "," \b Comment: \b0 ",
 ;   	orders->qual[x].comment,"\par")
    set pt->line_cnt = 0
    set max_length = 90
    execute dcp_parse_text value(orders->qual[x].comment),value(max_length)
    set stat = alterlist(orders->qual[x].com_ln_qual, pt->line_cnt)
    set orders->qual[x].com_ln_cnt = pt->line_cnt
    for (y = 1 to pt->line_cnt)
      set orders->qual[x].com_ln_qual[y].com_line = pt->lns[y].line
    endfor
 ; else
 ; set orders->qual[x].display_line = concat("{\fonttbl{\f0\fswiss Helv;}}\plain\f0 ",
 ;   	orders->qual[x].display_line,"\par")
  endif
endfor
call echorecord(orders )
/******************************************************************************
*  DETERMINE PAGE BREAK                                                       *
******************************************************************************/

SELECT
	 bb_sort = if (orders->qual[d.seq].activity_subtype_cd = BLOODBANK_CD)
	 					1
	 				else
	 					0
	 				endif
	,req_start_dt = format(orders->qual[d.seq].req_st_dt_tm,"mmddyyyy hh:mm;;q")
	,req_start_dt_p = format(orders->qual[d.seq].req_st_dt_tm,"dd/mm/yyyy hh:mm;;q")
	,priority = if (orders->qual[d.seq].priority = "URGENT") concat("1 - URGENT")
				else concat("2 -",orders->qual[d.seq].priority)
				endif
	,specimen_type = substring(1,30,orders->qual[d.seq].specimen_type)
	,mnemonic = substring(1,50,orders->qual[d.seq].mnemonic_sort)
;++++ 026
	,accession_no = orders->qual[d.seq].accession

FROM
	(DUMMYT   D  WITH seq = value(orders->cnt))

order by
	 req_start_dt
	,bb_sort
	,accession_no   ;026
	,priority
	,specimen_type
	,mnemonic


head report
	page_break_cnt = 0
	sort_order_cnt = 0
	cur_break = 0
	detail_cnt = 0
	macro (page_break)
		sort_order_cnt = 0
		page_break_cnt = (page_break_cnt + 1)
		stat = alterlist(orders->page_break,page_break_cnt)
		orders->page_break[page_break_cnt].sequence = page_break_cnt
		orders->page_break[page_break_cnt].fasting = "No"
		call echo("page_break")
	endmacro

	macro (add_order)
		stat = alterlist(orders->page_break[page_break_cnt].order_list,sort_order_cnt)
		orders->page_break[page_break_cnt].order_list[sort_order_cnt].order_id = orders->qual[d.seq].order_id
	endmacro
head req_start_dt
	null
head bb_sort
	page_break
detail
	sort_order_cnt = (sort_order_cnt + 1)
	detail_cnt = 0

	call echo(build(page_break_cnt," / ",sort_order_cnt))
	call echo(orders->qual[d.seq].mnemonic)

	orders->qual[d.seq].page_break_id = page_break_cnt
	orders->qual[d.seq].sort_order_id = sort_order_cnt
	if (orders->qual[d.seq].fasting = "Yes")
		orders->page_break[page_break_cnt].fasting = "Yes"
	endif

	call echo("building order details")
	orders->qual[d.seq].display_line_rtf = concat(rtf_font_tbl)

	call echo("-->setting remaining details")

	for (i = 1 to size(orders->qual[d.seq].d_qual,5))

		if (	((trim(orders->qual[d.seq].d_qual[i].field_description)  in("Copy Results to Dr1",
																	    "Copy Results to Dr2",
																	    "Copy Results to Dr3",
																	    "Blood Products Requested",
																	    "Special Requirements",
																	    "Date / Time Product Required",
																	    "Date Product Required",  ;027 added in
																	    "Pregnancy or Miscarriage in last 3 months",
																	    "Transfusion in last 3 months",
																	    "Previous Transfusion Reaction?",
																	    "Known Red Cell Antibodies (Specify)"
																	    ;30++
																	    ;,"Units Required (RBC)"
																	    ,"# Units Required (RBC)"
																	    ,"Indication for Transfusion"
																	    ,"CMV Neg"
																	    ,"Irradiated"
																	    , "Clinician Callback Number"
																	    ,"Anti-D in last 3 months"
																	    ,"Known Red Cell Antibodies (Specify)"
																	    ,"Specify Known RBC Abs"
																	    ,"Hb"
																	    ,"Platelet Count"
																	    ,"INR"
																	    ,"APTT"
																	    ,"Fibrinogen"
																	    ,"Actively Bleeding"
																	    ,"Fresh (<..... Days)"
																	    ;,"Other Requirement"
																	    ,"Special Modified components"
																	    ,"Site Required"
																	    ,"Date/Time Required:"
																	    ,"Vials / Units Required"
																	    ;30--
																	    )
				)
			 or (orders->qual[d.seq].d_qual[i].oe_field_meaning  in("REASONFOREXAM",
			 														   "REQSTARTDTTM")))
			 or (orders->qual[d.seq].d_qual[i].accept_ind = 2)
			)
			call echo("skipping OD")
		else

			call echo(build("Found OD to add:",orders->qual[d.seq].d_qual[i].field_description))

			detail_cnt = (detail_cnt + 1)
 			orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)

			if (detail_cnt = 1)
				orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,
												rtf_font_0,rtf_bold,orders->qual[d.seq].d_qual[i].label_text,":",rtf_end_bold,
												orders->qual[d.seq].d_qual[i].value)
				orders->qual[d.seq].display_line_size = concat(orders->qual[d.seq].display_line_size,
												rtf_font_0,rtf_bold,orders->qual[d.seq].d_qual[i].label_text,":",rtf_end_bold,
												orders->qual[d.seq].d_qual[i].value)
			else
				orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,", ",
												rtf_font_0,rtf_bold,orders->qual[d.seq].d_qual[i].label_text,":",rtf_end_bold,
												orders->qual[d.seq].d_qual[i].value)
				orders->qual[d.seq].display_line_size = concat(orders->qual[d.seq].display_line_size,", ",
												rtf_font_0,rtf_bold,orders->qual[d.seq].d_qual[i].label_text,":",rtf_end_bold,
												orders->qual[d.seq].d_qual[i].value)

			endif

		endif
	endfor

		if (orders->qual[d.seq].comment_ind = 1)
		detail_cnt = (detail_cnt + 1)
		orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + orders->qual[d.seq].com_ln_cnt)

 		;030 - honour line breaks from original data entry, or attempt to
 		orders->qual[d.seq].comment = replace(orders->qual[d.seq].comment, char(10)  , rtf_cr)

		call echo("-->adding order comment")
			if (detail_cnt = 1)
				orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_cr,rtf_cr,
												rtf_font_0,rtf_bold,"Comment: ",rtf_end_bold,
												orders->qual[d.seq].comment)
				orders->qual[d.seq].display_line_size = concat(orders->qual[d.seq].display_line_size,crlf,crlf,
												rtf_font_0,rtf_bold,"Comment: ",rtf_end_bold,
												orders->qual[d.seq].comment)
			else
				;030 add extra newline
				orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,", ",
												rtf_font_0,rtf_bold,rtf_cr,"Comment: ",rtf_end_bold,
												orders->qual[d.seq].comment)
				orders->qual[d.seq].display_line_size = concat(orders->qual[d.seq].display_line_size,", ",
												rtf_font_0,rtf_bold,crlf,"Comment: ",rtf_end_bold,
												orders->qual[d.seq].comment)
			endif
	endif


		orders->qual[d.seq].bloodbank_req = 0

  If (orders->qual[d.seq].activity_subtype_cd = BLOODBANK_CD)

		call echo("-->setting Blood Bank information")

		orders->qual[d.seq].bloodbank_req = 1		;027 use in layout to switch heading on/off

    /*
    bp_required
		special_requirements
		dt_tm_product_required
		preg_last_3_months
		tx_last_3_months
		prev_tx_reaction
		red_cell_antibodies
    */

 ;027 - now only want to print Blood bank oef's if values acutally exist

	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_cr,   ;027 rtf_cr,
											rtf_font_11,rtf_bold,rtf_uline,"Transfusion Details",rtf_cr)
	orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)

 	If(size(trim(orders->qual[d.seq].bp_required,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Blood/Product Requested : ",rtf_end_bold,
                                                  orders->qual[d.seq].bp_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].special_requirements,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Special Requirements: ",rtf_end_bold,
                                                  orders->qual[d.seq].special_requirements,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].dt_tm_product_required,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Date / Time Product Required: ",rtf_end_bold,
                                                  orders->qual[d.seq].dt_tm_product_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].preg_last_3_months,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Pregnancy / Miscarriage in last 3months: ",rtf_end_bold,
                                                  orders->qual[d.seq].preg_last_3_months,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].tx_last_3_months,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Transfusion in last 3 months: ",rtf_end_bold,
                                                  orders->qual[d.seq].tx_last_3_months,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].prev_tx_reaction,3))>0)
    	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Previous Transfusion Reaction: ",rtf_end_bold,
                                                  orders->qual[d.seq].prev_tx_reaction,rtf_cr)
		orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].red_cell_antibodies,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Known Red Cell Antibodies: ",rtf_end_bold,
                                                  orders->qual[d.seq].red_cell_antibodies,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

	;orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 15)

	/*WH Specific transfusion oefs
		# Units Required
		Clinical Indication
		CMV Neg
		Irradiated
		Clinician Callback number
		Anti-D in last 3 months
		Known RBC Abs
		Specify Known RBC Abs
		Hb
		Platelet Count
		INR
		APTT
		Fibrinogen
		Actively Bleeding
		Fresh (< …...days)


	*/

	If(size(trim(orders->qual[d.seq].wh_units_required,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"# Units Required: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_units_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_clinical_indication,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Clinical Indication: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_clinical_indication,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_cmv_neg,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"CMV Neg: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_cmv_neg,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_irradiated,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Irradiated: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_irradiated,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_clinician_callback,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Clinician Callback: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_clinician_callback,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_anti_d,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Anti-D in last 3 months: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_anti_d,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf



     If(size(trim(orders->qual[d.seq].wh_specify_known_rbc_abs,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Specify Known RBC Abs: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_specify_known_rbc_abs,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_known_rbc_abs,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Known RBC Abs: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_known_rbc_abs,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_hb,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Hb: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_hb,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_platelet_count,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Platelet Count: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_platelet_count,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_inr,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"INR: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_inr,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf



    If(size(trim(orders->qual[d.seq].wh_aptt,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"APTT: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_aptt,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_fibrinogen,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Fibrinogen: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_fibrinogen,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_active_bleeding,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Actively Bleeding: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_active_bleeding,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_fresh,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Fresh (< ...days): ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_fresh,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

 	If(size(trim(orders->qual[d.seq].wh_other_requirements,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Special Modified components: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_other_requirements,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

 	If(size(trim(orders->qual[d.seq].wh_site_required,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Site Required: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_site_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_dt_required,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Date/Time Required: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_dt_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
    EndIf

    If(size(trim(orders->qual[d.seq].wh_vials_units_required,3))>0)
   	 	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_font_0,
                                                  rtf_bold,"Vials / Units Required: ",rtf_end_bold,
                                                  orders->qual[d.seq].wh_vials_units_required,rtf_cr)
        orders->qual[d.seq].disp_ln_cnt = (orders->qual[d.seq].disp_ln_cnt + 1)
        call echo(orders->qual[d.seq].wh_vials_units_required)
    EndIf


 Endif

	orders->qual[d.seq].display_line_rtf = concat(orders->qual[d.seq].display_line_rtf,rtf_cr)


	orders->page_break[page_break_cnt].order_cnt = sort_order_cnt
	orders->page_break[page_break_cnt].req_st_dt = req_start_dt_p
	orders->page_break[page_break_cnt].activity_type = uar_get_code_display(orders->qual[d.seq].activity_subtype_cd)
	add_order

foot report
	orders->page_break_cnt = page_break_cnt

WITH NOCOUNTER


 call echo("setting clinical history per page")



select
 into	"nl:"
 sort_thingy = if (oc.comment_type_cd = CLINHIST_CD) 1
					else 2
				endif
 ,sort_order_id = build(oc.order_id, oc.comment_type_cd)
from (dummyt d with seq = value(size(orders->page_break,5))),
     order_comment oc,
     long_text lt,
     (dummyt d2)
plan d
	where maxrec(d2,size(orders->page_break[d.seq].order_list,5))
join d2
join oc where oc.order_id = orders->page_break[d.seq].order_list[d2.seq].order_id
     and oc.comment_type_cd in(CLINHIST_CD,GENCLINHIST_CD)
join lt where lt.long_text_id = oc.long_text_id
and lt.active_ind = 1
order d.seq,sort_thingy,sort_order_id,oc.updt_dt_tm ,oc.order_id,lt.long_text_id desc
head report
	cnt = 0
	clin_hist = ""
	found_ndx = 0
	eval_ndx = 0
	stat = alterlist(comments->qual,0)
head d.seq
	cnt = 0
	clin_hist = ""
	stat = alterlist(comments->qual,0)
	call echo(build("page break=",d.seq))
head sort_order_id
	null
foot sort_order_id
	found_ndx = locateval(eval_ndx, 1, size(comments->qual,5), trim(lt.long_text), comments->qual[eval_ndx].long_text)
 if (found_ndx = 0)
  stat = alterlist(comments->qual, size(comments->qual,5) + 1)
  comments->qual[size(comments->qual,5)].long_text = trim(lt.long_text)
	cnt = (cnt + 1)
	if (cnt = 1)
		clin_hist = trim(lt.long_text)
	else
		clin_hist= concat(clin_hist,char(10),char(13),trim(lt.long_text))
	endif
	call echo(lt.long_text)
	call echo(oc.order_id)
 endif
foot d.seq
	orders->page_break[d.seq].clin_hist = clin_hist
with nocounter
/*end setting clinical history per page */


/******************************************************************************
*  SEND TO OUTPUT PRINTER                                                     *
******************************************************************************/
call echo("SEND TO OUTPUT PRINTER                                                     ")
for (i = 1 to orders->page_break_cnt)

if (orders->spoolout_ind = 1)

 set new_timedisp = cnvtstring(format(sysdate,"mmddyyhhmmss;;q"))
 set tempfile1a = build(concat("cer_temp:9dcpreq_",trim(cnvtstring(i)),"_",
 						trim(cnvtstring(orders->page_break[i].order_cnt)),"_",new_timedisp),".dat")

 ;call echorecord(orders)
set orders->fasting = orders->page_break[i].fasting
set orders->cnt = orders->page_break[i].order_cnt
set orders->req_st_dt = orders->page_break[i].req_st_dt
;set object_name = "vic_au_reqgen07_lyt"
;call echoxml(orders,"1mw_pathreqords.xml")
;031++
if (orders->orgset_name = "Eastern Health")
	set object_name = "eh_au_reqgen07_lyt"
elseif(orders->orgset_name = "DEMO VIC ALL") ;for testing, otherwise 'Western Health'
	set object_name = "wh_au_reqgen07_lyt"
elseif(orders->orgset_name = "Western Health")
	set object_name = "wh_au_reqgen07_lyt"
else
	set object_name = "wh_au_reqgen07_lyt"
endif

;031--
set orders->page_break[i].file_name = tempfile1a

set com_msg = concat("execute ",trim(object_name), " '", tempfile1a, "',", cnvtstring(i) ," go")

call parser(com_msg)
/** End Mod 026 **/
call echo(concat("Filename-->",tempfile1a))
set spool = value(trim(tempfile1a)) value(trim(request->printer_name)) with deleted
endif
/*
if (i = 1)
set request->printer_name = tempfile1a
endif */





endfor
call echorecord(orders)
#exit_script
set last_mod = "017"
end
go


 