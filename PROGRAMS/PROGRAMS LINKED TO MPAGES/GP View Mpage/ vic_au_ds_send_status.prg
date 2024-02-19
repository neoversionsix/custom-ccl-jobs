/*****************************************************************************

        Source file name:       vic_au_ds_send_status.prg
        object name:            vic_au_ds_send_status

        Program purpose:		Display transmission details .

        Executing from:         Powerchart

        Special Notes:			This code populates the RHS panel of GPview screen

        						Only pulls data from the last 30 days, as fax tables are not indexed,
        						 and interface data tables are purged after 30 days.

******************************************************************************


*******************************************************************************
*                      MODIFICATION CONTROL LOG                               *
*******************************************************************************

Mod Date     Engineer          Comment
--- -------- ------------------ ------------------------------------------
000 MAY 2012 Anthony Steele     Initial Development

001 SEP 2014 Leigh W-Y			KE485488 - Fix duplication of electronic DS display for EHS
								[EHS interface creates 2 msgs one for GP & other for PCEHR]

002 Nov 2015 Grant W  			KE727114 - Fix Dr. Name in Electronic DS Delivery Screen.
								Change to MSH section of i12 HL7 message during M2015 upgrade
								has broken the presentation of Dr. Name in RHS payne

003 Dec 2015 Grant W			KE740077 - Fix "Fax Transmit Status" to indicate dt_tm
								of most recent fax activity

004 May 2016 Grant W			AHS ChartXR Implementation mods for RRD
								Gather and aggregate both MRP and ChartXR Chart Requests (30 day lookbehind)

005 Aug 2016 Grant W			PEN RNET updates - Suppress "Electronic Indentifier" on
								Electronic Transmissions (always "unknown" post RNET)

006 Sep 2016 Grant W			PEN KE766258 Only HealthLink/ReferralNet (GP Notify) events
								to be indicated when Transmission = Electronic
								ie: Not PCEHR or any other outbound DS's. (replaces 001)

007 May 2017 Grant W			ER774605 PH1463 Sequence Trans History by transmit_dt_tm (desc)

008 Nov 2017 Grant W			ER795122 EHS Alter DS Electronic Tx to pick up new DYNDOC DS's

009 Sep 2018 Mark W	 			I817062/KE817740 eliminate eso trigger rows with blank l_r_trigger_status_text
								from consideration (following introduction of RVEE_PDF_OUT_TCPIP in prdd5)

*******************************************************************************/

drop program vic_au_ds_send_status:dba go
create program vic_au_ds_send_status:dba


; Include standard rtf includes
%i cclsource:ma_rtf_tags.inc
%i cclsource:vic_ds_common_fonts.inc


record tmp (
  1 ds_flag = i1
  1 cnt = i4
  1 lst[*]
    2 trans_dt_tm = dq8
    2 request_dt_tm = dq8
    2 prsnl_id = f8
    2 name_first = vc
    2 name_last = vc
    2 transmit_method = i1 ; 1 = electronic, 2 = fax, 3 = print & Post
    2 chart_status = vc
    2 status = vc
    2 distribution = vc
    2 fax_number = vc
    2 area_code = vc
    2 fax_exchange = vc
    2 phone_suffix = vc
    2 healthlink = vc
    2 chart_request_id = f8
    2 print_flag = i1
    2 result_status = vc
)

record elec (
  1 cnt = i4
  1 max_keys_cnt = i4
  1 lst[*]
    2 oen_queue_id = f8
    2 keys_cnt = i4
    2 result_status = vc
    2 keys[*]
	  3 tx_key = c27
	  3 trans_date = dq8
	  3 name_last = vc
	  3 name_first = vc
	  3 status = vc
	  3 healthlink = vc
)

declare ENCNTR_ID = f8 with constant(request->visit[1].encntr_id), protect
;declare ENCNTR_ID = f8 with constant(18877800), protect; - TESTING

declare FAX_PHONE_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS")), protect
declare PRSNL_CD = f8 with constant(uar_get_code_by("MEANING",213,"PRSNL")), protect

; transmit method constants
declare ELECTRONIC = i1 with constant(1), protect
declare FAX = i1 with constant(2), protect
declare PRINT_POST = i1 with constant(3), protect

declare idx = i4 with noconstant(0), protect
declare rq_qual = vc with noconstant(""), protect
declare outstring = vc with noconstant(""), protect
declare outstringfax = vc with noconstant(""), protect


; Check if encounter has a discharge summary
select into "nl:"
from clinical_event ce
plan ce where ce.encntr_id = ENCNTR_ID
and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
and cnvtupper(ce.event_tag) = "*DISCHARGE SUMMARY*"

head report
	tmp->ds_flag = 1
with nocounter

if(tmp->ds_flag = 0)
	go to DISPLAY_RTF
endif

;-------------------------------------------------------------------------------------
; get fax details - MRP

select into "nl:"
from chart_request cr
	, output_dest od
	, device_xref dx
	, prsnl pl
	, remote_device r
	, chart_distribution d

plan cr where cr.encntr_id = ENCNTR_ID
and cr.request_type = 4 ;fax
and cr.active_ind = 1
join d where d.distribution_id = cr.distribution_id

join pl where pl.person_id = cr.prsnl_person_id

join od where od.output_dest_cd = cr.output_dest_cd

join dx where dx.device_cd = outerjoin(od.device_cd)
and dx.parent_entity_name = outerjoin("PRSNL")
join r where  r.device_cd = outerjoin(dx.device_cd)

order by cr.chart_request_id

;-------------------------------------------------------------------------------------
; write away MRP Fax Details

head report
	cnt = 0

head cr.chart_request_id
	call echo(cr.chart_request_id)
	cnt = cnt+1
	stat = alterlist(tmp->lst,cnt)
	tmp->lst[cnt].request_dt_tm = cnvtdatetime(cr.request_dt_tm)
	tmp->lst[cnt].prsnl_id = dx.parent_entity_id
	tmp->lst[cnt].transmit_method = FAX
	tmp->lst[cnt].area_code = r.area_code
	tmp->lst[cnt].fax_exchange = r.exchange
	tmp->lst[cnt].phone_suffix = r.phone_suffix
	;tmp->lst[cnt].fax_number = p.phone_num
	tmp->lst[cnt].chart_request_id = cr.chart_request_id
	tmp->lst[cnt].name_first = pl.name_first
	tmp->lst[cnt].name_last = pl.name_last
	tmp->lst[cnt].chart_status = uar_get_code_display(cr.chart_status_cd)
	tmp->lst[cnt].distribution = d.dist_descr
	tmp->lst[cnt].print_flag = 1

foot report
	tmp->cnt = cnt

with nocounter

;-------------------------------------------------------------------------------------
; get fax details - Chart XR
;004 +++

If(CHECKDIC("CR_REPORT_REQUEST", "T", 0) = 2);CXR Chart Request table exists, and I have access

	select into "nl:"
	from cr_report_request cr
		, output_dest od
		, device_xref dx
		, prsnl pl
		, remote_device r
		, chart_distribution d

	plan cr
		where cr.encntr_id = ENCNTR_ID
		and cr.request_type_flag = 4 ;distribution
		;and cr.active_ind = 1

	join d
		where d.distribution_id = cr.distribution_id

	join pl
		;where pl.person_id = cr.prsnl_person_id
		where pl.person_id = cr.provider_prsnl_id

	join od
		;where od.output_dest_cd = cr.output_dest_cd
		where od.output_dest_cd = outerjoin(cr.output_dest_cd) ;no ChartXR codeset for this!!!!

	join dx
		where dx.device_cd = outerjoin(od.device_cd)
		and dx.parent_entity_name = outerjoin("PRSNL")

	join r
		where  r.device_cd = outerjoin(dx.device_cd)

 	order by cr.report_request_id
	;-------------------------------------------------------------------------------------
	; write away ChartXR Fax Details

	head report
		cnt = tmp->cnt

	head cr.report_request_id
		call echo(cr.report_request_id)
		cnt = cnt+1
		stat = alterlist(tmp->lst,cnt)
		tmp->lst[cnt].request_dt_tm = cnvtdatetime(cr.request_dt_tm)
		tmp->lst[cnt].prsnl_id = dx.parent_entity_id
		tmp->lst[cnt].transmit_method = FAX
		tmp->lst[cnt].area_code = r.area_code
		tmp->lst[cnt].fax_exchange = r.exchange
		tmp->lst[cnt].phone_suffix = r.phone_suffix
		;tmp->lst[cnt].fax_number = p.phone_num
		tmp->lst[cnt].chart_request_id = cr.report_request_id
		tmp->lst[cnt].name_first = pl.name_first
		tmp->lst[cnt].name_last = pl.name_last
		tmp->lst[cnt].chart_status = uar_get_code_display(cr.report_status_cd)
		tmp->lst[cnt].distribution = d.dist_descr
		tmp->lst[cnt].print_flag = 1

	foot report
		tmp->cnt = cnt

	with nocounter

endif

;-------------------------------------------------------------------------------------
;MRP Fax
; Load transmission info from report queue. Only print if within appropriate date range.
for(x=1 to tmp->cnt)
	if(tmp->lst[x].transmit_method = FAX)
		;set rq_qual = concat("pCR",trim(cnvtstring(tmp->lst[x].chart_request_id)))
 		set rq_qual = concat("*CR",trim(cnvtstring(tmp->lst[x].chart_request_id)))
		select into "nl:"
		from report_queue rq
		;plan rq where rq.transmit_dt_tm >= cnvtlookbehind("30,D")		;003
		plan rq where rq.updt_dt_tm >= cnvtlookbehind("30,D")			;003
		and rq.converted_file_name = patstring(concat("*",trim(rq_qual),"*"))
		;order by rq.transmit_dt_tm desc								;003
		order by rq.updt_dt_tm desc										;003

		head report
			tmp->lst[x].status = uar_get_code_display(rq.transmission_status_cd)
			;tmp->lst[x].trans_dt_tm = cnvtdatetime(rq.transmit_dt_tm)	;003
			tmp->lst[x].trans_dt_tm = cnvtdatetime(rq.updt_dt_tm)		;003

		with nocounter
	endif
endfor

;-------------------------------------------------------------------------------------
; Electronic Transfers - consult interface tables. These are purged every 30 days.

select into "nl:"
from fsieso_que_details fqd
	, cqm_fsieso_que cfq
	, fsieso_que_details fqd2
	, fsieso_que_details fqd3
	, clinical_event ce
	, cqm_fsieso_tr_1 cft1

plan fqd where fqd.parent_entity_id = ENCNTR_ID;19584091.00;19590044.00
and fqd.parent_entity_name = "ENCOUNTER"

join cfq where cfq.queue_id = fqd.queue_id
and cfq.class = "CE"
and cfq.type in ("DOC", "MDOC")				;008 Added MDOC
and cfq.subtype in ("DOC", "DYNDOC")		;008 Added DYNDOC

join fqd2 where fqd2.queue_id = fqd.queue_id
and fqd2.parent_entity_name = "CLINICAL_EVENT"

join fqd3 where fqd3.queue_id = fqd.queue_id
and fqd3.parent_entity_name = "RESULT_STATUS_CD"

join ce where ce.event_id = fqd2.parent_entity_id
and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
and ce.event_cd in (select cv.code_value from code_value cv where cv.code_set = 72
					and cv.display_key = "DISCHARGESUMMARY*")

join cft1 where cft1.queue_id = fqd.queue_id
and cft1.l_r_trigger_status_text != " "		;009 Added

order by cft1.create_dt_tm desc
		, cft1.queue_id

head report
	cnt = 0

head cft1.queue_id ;005a
;detail
	cnt = cnt+1
	if(mod(cnt,5)=1)
		stat = alterlist(elec->lst,cnt+4)
	endif
	elec->lst[cnt].oen_queue_id = cnvtreal(substring(5,132,cft1.l_r_trigger_status_text))
	elec->lst[cnt].result_status = uar_get_code_display(fqd3.parent_entity_id)

foot report
	stat = alterlist(elec->lst,cnt)
	elec->cnt = cnt

with nocounter

;--------------------------------------------------------------------------------------------
;call echo(build("Before if elec-cnt.."))
;call echorecord(elec)

if(elec->cnt > 0)
	; Now get open engine data
	select into "nl:"
	from (dummyt d1 with seq=elec->cnt)
		, cqm_oeninterface_que coq
		, cqm_oeninterface_tr_1 cot1
		, cqm_listener_config clc   ;001
		, oen_procinfo op			;006 new

	plan d1

	join coq where coq.queue_id = elec->lst[d1.seq].oen_queue_id

	join cot1 where cot1.queue_id = coq.queue_id

	join clc where clc.listener_id = cot1.listener_id    ;001
		;and clc.listener_alias     !=  "1106"  ;001 EHS PCEHR pid
		;and clc.listener_alias     in ("1040", "1041", "1068", "1088") ;(RVH, EHS, AHS, PEN) HLink/RNET pid ;006
		;and clc.listener_alias not in ("1106", "1177", "1179", "1176") ;(EHS, AHS, AHS, PEN) PCEHR pid ;006 ALTERNATIVE

	;006 new +++ one code segment fits all Agencies
	join op
		where op.interfaceid = cnvtint(clc.listener_alias)

	;													      < op.proc_desc >
		and trim(op.proc_name) in ("RVEE_REF_OUT_TCPIP"		; RVEE Discharge Summary Outbound
								   , "EH_REF_OUT_TCPIP"		; Eastern Discharge Summary Outbound
								   , "AH_REF_OUT_TCPIP"		; Austin Discharge Summary Outbound
								   , "PH_REF_OUT_TCPIP")	; Peninsula Discharge Summary Outbound
	;006 new ---

	order by cot1.queue_id
			, cot1.process_stop_dt_tm desc

	head report
		comma_pos = 0
		col_pos = 0

	head cot1.queue_id
		keys_cnt = 0

	detail
		keys_cnt = keys_cnt+1
		stat = alterlist(elec->lst[d1.seq].keys,keys_cnt)
		comma_pos = (findstring(",",cot1.l_r_trigger_status_text) + 1)
		col_pos = (findstring(";",cot1.l_r_trigger_status_text,comma_pos) - comma_pos)
		elec->lst[d1.seq].keys[keys_cnt].tx_key = notrim(substring(comma_pos,col_pos,cot1.l_r_trigger_status_text))

		elec->lst[d1.seq].keys[keys_cnt].trans_date = cnvtdatetime(cot1.process_stop_dt_tm)
		case(cot1.process_status_flag)
			of 0:
				elec->lst[d1.seq].keys[keys_cnt].status = "Not active"
			of 10:
				elec->lst[d1.seq].keys[keys_cnt].status = "Active"
			of 30:
				elec->lst[d1.seq].keys[keys_cnt].status = "In progress"
			of 50:
				elec->lst[d1.seq].keys[keys_cnt].status = "Hold"
			of 70:
				elec->lst[d1.seq].keys[keys_cnt].status = "Failed"
			of 75:
				elec->lst[d1.seq].keys[keys_cnt].status = "Skipped"
			of 90:
				elec->lst[d1.seq].keys[keys_cnt].status = "Transmitted";"Completed"
			of 110:
				elec->lst[d1.seq].keys[keys_cnt].status = "Replay Active"
			else
				elec->lst[d1.seq].keys[keys_cnt].status = "Unknown"
		endcase

	foot cot1.queue_id
		elec->lst[d1.seq].keys_cnt = keys_cnt
		if(keys_cnt > elec->max_keys_cnt)
			elec->max_keys_cnt = keys_cnt
		endif

	with nocounter

;    call echo(build("After if......"))
;	call echorecord(elec)
;
;-------------------------------------------------------------------------------------------------------
	; Parse HL7 message to get healthlink & GO

	select into "nl:"

	name_sorter = cnvtupper(concat(elec->lst[d1.seq].keys[d2.seq].name_first,"*",
									elec->lst[d1.seq].keys[d2.seq].name_last)) ;lwy

	from (dummyt d1 with seq=elec->cnt)
		, (dummyt d2 with seq=elec->max_keys_cnt)
		, oen_txlog otl

	plan d1

	join d2 where d2.seq <= elec->lst[d1.seq].keys_cnt
	and elec->lst[d1.seq].keys[d2.seq].tx_key > " "

	join otl where elec->lst[d1.seq].keys[d2.seq].tx_key = otl.tx_key

	order by elec->lst[d1.seq].keys[d2.seq].name_first ;moved up here but jmcd can't sort on values that haven't been populated yet
			,elec->lst[d1.seq].keys[d2.seq].name_last
			, elec->lst[d1.seq].keys[d2.seq].trans_date desc

	detail

		elec->lst[d1.seq].keys[d2.seq].healthlink = piece(replace(otl.msg_text,"^","="),"|",6,"")

		;002 +++
		;elec->lst[d1.seq].keys[d2.seq].name_first = piece(piece(replace(otl.msg_text,"^","="),"|",24,""),"=",2,"")
		;elec->lst[d1.seq].keys[d2.seq].name_last  = piece(piece(replace(otl.msg_text,"^","="),"|",24,""),"=",1,"")

		elec->lst[d1.seq].keys[d2.seq].name_first = piece(piece(piece(otl.msg_text, char(13), 3, ""),"|", 3, ""),"^", 2, "")
		elec->lst[d1.seq].keys[d2.seq].name_last  = piece(piece(piece(otl.msg_text, char(13), 3, ""),"|", 3, ""),"^", 1, "")
		;002 ---

	with nocounter

;	call echo(build("after hl7 msg..."))

;	call echorecord(elec)

;-----------------------------------------------------------------------------------------------------------
	; Load tmp-> record with most recent status for each person
	select into "nl:"

	from (dummyt d1 with seq=elec->cnt)
	   , (dummyt d2 with seq=elec->max_keys_cnt)

	plan d1

	join d2 where d2.seq <= elec->lst[d1.seq].keys_cnt
	and concat(elec->lst[d1.seq].keys[d2.seq].name_first,elec->lst[d1.seq].keys[d2.seq].name_last) > " "


	order by  elec->lst[d1.seq].keys[d2.seq].name_first
			,elec->lst[d1.seq].keys[d2.seq].name_last
			, elec->lst[d1.seq].keys[d2.seq].trans_date desc

	head report
		cnt = tmp->cnt


	detail
		cnt = cnt+1
		stat = alterlist(tmp->lst,cnt)
		tmp->lst[cnt].trans_dt_tm = cnvtdatetime(elec->lst[d1.seq].keys[d2.seq].trans_date)
		tmp->lst[cnt].transmit_method = ELECTRONIC
		tmp->lst[cnt].name_first = cnvtcap(elec->lst[d1.seq].keys[d2.seq].name_first)
		tmp->lst[cnt].name_last = cnvtcap(elec->lst[d1.seq].keys[d2.seq].name_last)
		tmp->lst[cnt].healthlink = elec->lst[d1.seq].keys[d2.seq].healthlink
		tmp->lst[cnt].status = elec->lst[d1.seq].keys[d2.seq].status
		tmp->lst[cnt].print_flag = 1
		tmp->lst[cnt].result_status = elec->lst[d1.seq].result_status

	foot report
		tmp->cnt = cnt

	with nocounter

endif

;call echorecord(tmp)
;call echorecord(elec)

 ;------------------------------------------------------------------------------------------

#DISPLAY_RTF

; Display RTF Output
select  into "nl:"

	transmit_dt_tm = cnvtdatetime(tmp->lst[d1.seq].trans_dt_tm)
	, name_sorter = cnvtupper(concat(tmp->lst[d1.seq].name_first,"*",tmp->lst[d1.seq].name_last))


from (dummyt d1 with seq=tmp->cnt)

plan d1 where tmp->lst[d1.seq].print_flag = 1

order by ;tmp->lst[d1.seq].transmit_method,				;007
		 ;name_sorter,									;007
		tmp->lst[d1.seq].trans_dt_tm desc
		;tmp->lst[d1.seq].request_dt_tm desc			;007
		,tmp->lst[d1.seq].name_first					;007
 		,tmp->lst[d1.seq].name_last						;007

head report
	qual_flag = 0
	call ApplyFont(active_fonts->header_patient_name)
	call PrintText("Transmitted Discharge Summaries",1,0,1)
	call NextLine(1)
	call ApplyFont(active_fonts->normal)
	call PrintText("This view shows the last 30 days of electronic or automatic fax data.",0,0,0)
	call NextLine(1)
	call PrintText("Automatic Fax entries will not show until Chart Distributions have occurred.",0,0,0)
	call NextLine(1)
	call PrintText("This view will not show Print and Post or manual MRP prints.",0,0,0)
	call NextLine(2)

detail
	qual_flag = 1

	; Name and transmission date/time
	if(tmp->lst[d1.seq].name_first > " " and tmp->lst[d1.seq].name_last > " ")
		outstring = concat(tmp->lst[d1.seq].name_first," ",tmp->lst[d1.seq].name_last)
	elseif(tmp->lst[d1.seq].name_last > " ")
		outstring = tmp->lst[d1.seq].name_last
	else
		outstring = tmp->lst[d1.seq].name_first
	endif

	call PrintText(outstring,1,0,0)
	call NextLine(1)

	; Method
	call PrintLabeledDataFixed("Method: ",evaluate(tmp->lst[d1.seq].transmit_method
															,ELECTRONIC,"Electronic"
															,FAX,"Fax"
															,PRINT_POST,"Print and Post")
								,30)
	if(tmp->lst[d1.seq].transmit_method = ELECTRONIC)
		call NextLine(1)
		call PrintLabeledDataFixed("Discharge Summary Status: ",tmp->lst[d1.seq].result_status,30)
	endif
	call NextLine(1)

	if (CURDOMAIN != "*3") ;005 RNET Change - PEN/G3 opt-out of Electronic Identifier logic
		; Number or EDI
		if(tmp->lst[d1.seq].transmit_method = ELECTRONIC)
			call PrintLabeledDataFixed("Electronic Identifier: ",tmp->lst[d1.seq].healthlink,30)
			call NextLine(1)
		endif
	endif

	if(tmp->lst[d1.seq].transmit_method = FAX)
			outstringfax = "NONE "

		if (tmp->lst[d1.seq].area_code > " ")
				outstringfax = trim(tmp->lst[d1.seq].area_code)
 			endif
				if(tmp->lst[d1.seq].fax_exchange > " ")
					outstringfax = concat(outstringfax," ",trim(tmp->lst[d1.seq].fax_exchange))
				endif
				if(tmp->lst[d1.seq].phone_suffix > " ")
					outstringfax = concat(outstringfax,"  ",trim(tmp->lst[d1.seq].phone_suffix))
				elseif
				(outstringfax = "NONE ")
				outstringfax = "Fax Station no longer associated to provider"
				endif

			call PrintLabeledDataFixed("Fax: ",outstringfax,60)

			call NextLine(1)

  	endif
	; Distribution
	if(tmp->lst[d1.seq].distribution > " ")
		call PrintLabeledDataFixed("Distribution: ",tmp->lst[d1.seq].distribution,50)
		call NextLine(1)
	endif

	; Request Status
	if(tmp->lst[d1.seq].chart_status > " ")
		outstring = concat(tmp->lst[d1.seq].chart_status," - ",format(tmp->lst[d1.seq].request_dt_tm,"dd/mm/yyyy hh:mm;;q"))
		call PrintLabeledDataFixed("Chart Request Status: ",outstring,50)
		call NextLine(1)
	endif

	; Transmit Status
	if(tmp->lst[d1.seq].status > " ")
		outstring = concat(tmp->lst[d1.seq].status," - ",format(tmp->lst[d1.seq].trans_dt_tm,"dd/mm/yyyy hh:mm;;q"))
		if(tmp->lst[d1.seq].transmit_method = FAX)
			call PrintLabeledDataFixed("Fax Transmit Status: ",outstring,50)
		elseif(tmp->lst[d1.seq].transmit_method = ELECTRONIC)
			call PrintLabeledDataFixed("Electronic Transmit Status: ",outstring,50)
		else
			call PrintLabeledDataFixed("Transmit Status: ",outstring,50)
		endif
		call NextLine(1)
	endif
	call NextLine(1)

foot report
	if(tmp->ds_flag = 0)
		call PrintText("**No Signed Discharge Summary for visit.**",0,0,0)
		call NextLine(1)
	elseif(qual_flag = 0)
		call PrintText("**Signed Discharge Summary exists, but there has been No Fax or Electronic Transmissions within 30 days.**",0,0,0)
		call NextLine(1)
	call PrintText("**Validate GP Consent Status as GP Consent = No or Unknown will stop all Fax and Electronic Transmissions**",0,0,0)
	call NextLine(1)
	endif

with nocounter, nullreport



call FinishText(0)
call echo(rtf_out->text)
set reply->text = rtf_out->text

end
go
