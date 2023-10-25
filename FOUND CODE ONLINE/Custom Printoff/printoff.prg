;********************************************************************************************************************
;*                                                                    												*
;********************************************************************************************************************
;																													*
; PROGRAM   :	msj_ph_custom_print																					*
; DATE      :	February 2019																						*
; PROGRAMMER:	tecrfx																								*
; CREATE SR :	SCTASK0032011																						*
; PURPOSE   :	Custom print layout for the physician handoff.														*
;																													*
;********************************************************************************************************************
;********************************************************************************************************************
;                         						MODIFICATION CONTROL                        						*
;                                                                     												*
;MOD#   DESCRIPTION																		DATE  		BY				*
;----   --------------------------------------------------------------------------		-------- 	-----			*
;

drop program msj_ph_custom_print:dba go
create program msj_ph_custom_print:dba

prompt
	"Output to File/Printer/MINE" = "MINE" ,
  	"JSON Request:" = ""
with outdev ,jsondata


;Declare Constants
declare 319_MRN_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",319,"MRN")),protect
declare 4003147_ILLNESSSEVERITY_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"ILLNESSSEVERITY")),protect
declare 200_CODESTATUS_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",200,"CODESTATUS")),protect
declare 4003147_COMMENT_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"COMMENT")),protect
declare 4003147_PATIENTSUMMARY_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"PATIENTSUMMARY")),protect
declare 4003147_ACTION_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",4003147,"ACTION")),protect
declare 6027_IPASSACTION_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",6027,"IPASSACTION")),protect
declare 79_PENDING_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",79,"PENDING")),protect
declare 12025_CANCELED_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",12025,"CANCELED")),protect

call echo(build2("319_MRN_CD: ",319_MRN_CD))
call echo(build2("4003147_ILLNESSSEVERITY_CD: ",4003147_ILLNESSSEVERITY_CD))
call echo(build2("200_CODESTATUS_CD: ",200_CODESTATUS_CD))
call echo(build2("4003147_COMMENT_CD: ",4003147_COMMENT_CD))
call echo(build2("4003147_PATIENTSUMMARY_CD: ",4003147_PATIENTSUMMARY_CD))
call echo(build2("4003147_ACTION_CD: ",4003147_ACTION_CD))
call echo(build2("6027_IPASSACTION_CD: ",6027_IPASSACTION_CD))
call echo(build2("79_PENDING_CD: ",79_PENDING_CD))
call echo(build2("12025_CANCELED_CD: ",12025_CANCELED_CD))


;Declare Variables
declare idx = i4 with noconstant(0),protect
declare patienthtml = vc with noconstant(" "),protect
declare finalhtml = vc with noconstant(" "),protect
declare newsize = i4 with noconstant(0),protect
declare printuser_name = vc with noconstant(" "),protect


;Declare Records
record data (
  1 cnt					= i4
  1 list[*]
    2 person_id			= f8
    2 encntr_id			= f8
    2 unit_id			= f8
    2 unit_disp			= vc
    2 room_id			= f8
    2 room_disp			= vc
    2 patient_name		= vc
    2 age				= vc
    2 gender			= vc
    2 mrn				= vc
    2 illness_severity	= vc
    2 primary_contact	= vc
    2 diagnosis			= vc
    2 code_status		= vc
    2 admit_dt_tm		= dq8
    2 admit_dt_tm_disp	= vc
    2 patient_summary	= vc
    2 sit_aware_cnt		= i4
    2 sit_aware[*]
      3 comment			= vc
    2 actions_cnt		= i4
    2 actions[*]
      3 action			= vc
    2 allergy_cnt		= i4
    2 allergies[*]
      3 allergy			= vc
    2 diag_cnt			= i4
    2 diags[*]
      3 diag			= vc
) with protect


record html_log (
  1 list[*]
  	2 start				= i4
    2 stop				= i4
    2 patient_text		= vc
) with protect


;Set printuser_name
select into "nl:"
from
	prsnl p
plan p
	where p.person_id = reqinfo->updt_id

detail
	printuser_name = trim(p.name_full_formatted, 3)

with nocounter


;Add json patients to data record
set stat = cnvtjsontorec($jsondata)

select into "nl:"
	encounter = print_options->qual[d1.seq].encntr_id
from
	(dummyt d1 with seq = evaluate(size(print_options->qual,5),0,1,size(print_options->qual,5)))
plan d1
	where size(print_options->qual,5) > 0
order by encounter

head report
	cnt = 0

head encounter
	cnt += 1
	if(mod(cnt, 20) = 1)
		stat = alterlist(data->list,cnt + 19)
	endif

	data->list[cnt].encntr_id = print_options->qual[d1.seq].encntr_id
	data->list[cnt].person_id = print_options->qual[d1.seq].person_id
	data->list[cnt].age = trim(print_options->qual[d1.seq].pat_age,3)

foot encounter
	null

foot report
	data->cnt = cnt
	stat = alterlist(data->list,cnt)

with nocounter


;Get patient information
select into "nl:"
from
	person p
plan p
	where expand(idx,1,data->cnt,p.person_id,data->list[idx].person_id)
order by p.person_id

head p.person_id
	pos = locateval(idx,1,data->cnt,p.person_id,data->list[idx].person_id)
	if(pos > 0)
		data->list[pos].patient_name = trim(p.name_full_formatted,3)
		data->list[pos].gender = trim(uar_get_code_display(p.sex_cd),3)
	endif

foot p.person_id
	null

with expand = 2


;Get encounter data
select into "nl:"
from
	encounter e
plan e
	where expand(idx,1,data->cnt,e.encntr_id,data->list[idx].encntr_id)
	and e.active_ind = 1
order by e.encntr_id

head e.encntr_id
	pos = locatevalsort(idx,1,data->cnt,e.encntr_id,data->list[idx].encntr_id)
	if(pos > 0)
		data->list[pos].unit_id = e.loc_nurse_unit_cd
		data->list[pos].unit_disp = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
		data->list[pos].room_id = e.loc_room_cd
		data->list[pos].room_disp = trim(uar_get_code_display(e.loc_room_cd),3)
		data->list[pos].admit_dt_tm = e.reg_dt_tm
		data->list[pos].admit_dt_tm_disp = format(e.reg_dt_tm,"mm/dd/yy hh:mm;;q")
	endif

foot e.encntr_id
	null

with expand = 2


;Get MRN
select into "nl:"
from
	encntr_alias ea
plan ea
	where expand(idx,1,data->cnt,ea.encntr_id,data->list[idx].encntr_id)
	and ea.active_ind = 1
	and ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
	and ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	and ea.encntr_alias_type_cd = 319_MRN_CD
order by ea.encntr_id

head ea.encntr_id
	pos = locatevalsort(idx,1,data->cnt,ea.encntr_id,data->list[idx].encntr_id)
	if(pos > 0)
		data->list[pos].mrn = trim(cnvtalias(ea.alias, ea.alias_pool_cd),3)
	endif

foot ea.encntr_id
	null

with expand = 2


;Get Illness Severity
select into "nl:"
from
	pct_ipass pi
	,code_value cv
plan pi
	where expand(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	and pi.active_ind = 1
	and pi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	and pi.ipass_data_type_cd = 4003147_ILLNESSSEVERITY_CD
join cv
	where cv.code_value = pi.parent_entity_id
	and cv.active_ind = 1
order by pi.encntr_id

head pi.encntr_id
	pos = locatevalsort(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	if(pos > 0)
		data->list[pos].illness_severity = trim(cv.display,3)
	endif

foot pi.encntr_id
	null

with expand = 2


;Get Code Status
select into "nl:"
from
	orders o
	,order_detail od
plan o
	where expand(idx,1,data->cnt,o.encntr_id,data->list[idx].encntr_id)
	and o.catalog_cd = 200_CODESTATUS_CD
join od
	where od.order_id = o.order_id
	and od.oe_field_id = 1040321.00		;Code Status
order by o.encntr_id, o.order_id, od.oe_field_id, od.action_sequence desc

head o.encntr_id
	pos = locatevalsort(idx,1,data->cnt,o.encntr_id,data->list[idx].encntr_id)

head o.order_id
	null

head od.oe_field_id
	if(pos > 0)
		data->list[pos].code_status = trim(od.oe_field_display_value,3)
	endif

foot od.oe_field_id
	null

foot o.order_id
	null

foot o.encntr_id
	null

with expand = 2


;Get Patient Summary and Situation Awareness & Planning
select into "nl:"
	result = evaluate(sn.long_text_id,0,trim(sn.sticky_note_text,3),trim(lt.long_text,3))
from
	pct_ipass pi
	,sticky_note sn
	,long_text lt
plan pi
	where expand(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	and pi.active_ind = 1
	and pi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	and pi.ipass_data_type_cd in (
		4003147_COMMENT_CD,
		4003147_PATIENTSUMMARY_CD
		)
join sn
	where sn.sticky_note_id = pi.parent_entity_id
	and sn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
	and sn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
join lt
	where lt.long_text_id = outerjoin(sn.long_text_id)
	and lt.active_ind = outerjoin(1)
order by pi.encntr_id, pi.ipass_data_type_cd, pi.begin_effective_dt_tm desc

head pi.encntr_id
	pos = locatevalsort(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	cnt = 0

head pi.ipass_data_type_cd
	if(pos > 0 and pi.ipass_data_type_cd = 4003147_PATIENTSUMMARY_CD)
		data->list[pos].patient_summary = result
	endif

detail
	if(pos > 0 and pi.ipass_data_type_cd = 4003147_COMMENT_CD)
		cnt += 1
		stat = alterlist(data->list[pos]->sit_aware, cnt)

		data->list[pos]->sit_aware[cnt].comment = result
	endif

foot pi.ipass_data_type_cd
	if(pos > 0)
		data->list[pos].sit_aware_cnt = cnt
	endif

foot pi.encntr_id
	null

with expand = 2


;Get Actions
select into "nl:"
from
	pct_ipass pi
	,task_activity ta
	,long_text lt
plan pi
	where expand(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	and pi.active_ind = 1
	and pi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	and pi.ipass_data_type_cd = 4003147_ACTION_CD
join ta
	where ta.task_id = pi.parent_entity_id
	and ta.task_activity_cd = 6027_IPASSACTION_CD
	and ta.task_status_cd = 79_PENDING_CD
join lt
	where lt.long_text_id = ta.msg_text_id
	and lt.parent_entity_name = "TASK_ACTIVITY"
	and lt.long_text != null
order by pi.encntr_id, pi.begin_effective_dt_tm desc

head pi.encntr_id
	pos = locatevalsort(idx,1,data->cnt,pi.encntr_id,data->list[idx].encntr_id)
	cnt = 0

detail
	if(pos > 0)
		cnt += 1
		stat = alterlist(data->list[pos]->actions, cnt)

		data->list[pos]->actions[cnt].action = trim(lt.long_text,3)
	endif

foot pi.encntr_id
	if(pos > 0)
		data->list[pos].actions_cnt = cnt
	endif

with expand = 2


;Get Allergies
select into "nl:"
	result = evaluate(a.substance_nom_id,0,trim(a.substance_ftdesc,3),trim(n.source_string,3))
from
	allergy a
	,nomenclature n
plan a
	where expand(idx,1,data->cnt,a.person_id,data->list[idx].person_id)
	and a.active_ind = 1
	and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
	and (a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
		or a.end_effective_dt_tm = null)
	and a.reaction_status_cd != 12025_CANCELED_CD
join n
	where n.nomenclature_id = outerjoin(a.substance_nom_id)
	and n.active_ind = outerjoin(1)
order by a.person_id, result

head a.person_id
	pos = locateval(idx,1,data->cnt,a.person_id,data->list[idx].person_id)
	cnt = 0

detail
	if(pos > 0)
		cnt += 1
		stat = alterlist(data->list[pos]->allergies, cnt)

		data->list[pos]->allergies[cnt].allergy = result
	endif

foot a.person_id
	if(pos > 0)
		data->list[pos].allergy_cnt = cnt
	endif

with expand = 2
call echojson(print_options,trim(concat(trim(logical("ccluserdir"),3),"/ph_print_testing.dat"),3))


;Put data record into HTML for output
call alterlist(html_log->list,data->cnt)
for(x = 1 to data->cnt)
	set html_log->list[x].start = textlen(trim(patienthtml,3)) + 1
	set patienthtml = build2(patienthtml,"<div>","<b>",'<table style="width:100%">',"<tr>","<tr>"
		,"<td class=patient-info>",data->list[x].unit_disp,"<div>",data->list[x].room_disp,"</div>","</td>"
		,"<td class=patient-info>",data->list[x].patient_name,"<div>",data->list[x].age," ",data->list[x].gender,"</div>","</td>"
		,"<td class=patient-info>",data->list[x].mrn,"</td>"
		,"<td class=patient-info>",data->list[x].illness_severity,"</td>"
		,"<td class=patient-info>",data->list[x].primary_contact,"</td>"
		,"<td class=patient-info>",data->list[x].diagnosis,"</td>"
		,"<td class=patient-info>",data->list[x].code_status,"</td>"
		,"<td class=patient-info>",data->list[x].admit_dt_tm_disp,"</td>"
		,"</tr>","</tr>","</table>","</b>","<tr>","</div>","<p>")
	set patienthtml = build2(patienthtml,"<div>",'<table style="width:100%">',"<tr>"
		,"<td>","</td>"
		,"<td class=patient-data-header>","Patient Summary","</td>"
		,"<td class=patient-data-header>","Situational Awareness & Planning","</td>"
		,"<td class=patient-data-header>","Actions","</td>"
		,"<td class=patient-data-header>","Allergies","</td>"
		,"<td class=patient-data-header>","Active Diagnosis","</td>"
		,"</tr>")
	set patienthtml = build2(patienthtml,"<tr>",'<td style="width:5%">',"</td>"
			,"<td class=paient-data>",data->list[x].patient_summary,"</td>"
			,"<td class=patient-data>")
		for(y = 1 to data->list[x].sit_aware_cnt)
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->sit_aware[y].comment,"</div>")
		endfor
		set patienthtml = build2(patienthtml,"</td>"
			,"<td class=patient-data>")
		for(y = 1 to data->list[x].actions_cnt)
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->actions[y].action,"</div>")
		endfor
		set patienthtml = build2(patienthtml,"</td>"
			,"<td class=patient-data>")
		for(y = 1 to data->list[x].allergy_cnt)
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->allergies[y].allergy,"</div>")
		endfor
		set patienthtml = build2(patienthtml,"</td>"
			,"<td class=patient-data>")
		for(y = 1 to data->list[x].diag_cnt)
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->diags[y].diag,"</div>")
		endfor
	set patienthtml = build2(patienthtml,"</td>","</tr>")
	set patienthtml = build2(patienthtml,"</table>")
	set patienthtml = build2(patienthtml,"<p>","Comments:","</p>","<div class=comment-box>","</div>","<hr>","</hr>")
	set html_log->list[x].stop = textlen(trim(patienthtml,3)) + 1
endfor


;Add HTML and CSS shell around patienthtml
set finalhtml = build2(
	"<!doctype html><html><head>"
	,"<meta charset=utf-8><meta name=description><meta http-equiv=X-UA-Compatible content=IE=Edge>"
	,"<title>MPage Print</title>"
	,"<style type=text/css>"
	,"body {font-family: arial;	font-size: 12px;}"
	,"td {vertical-align: top;}"
	,".print-header {display: flex;}"
	,".print-header div{display: flex; flex: 1 1;}"
	,".print-title {justify-content: center; font-style: bold; font-size: 24px;}"
	,".printed-date {justify-content: flex-end;}"
	,".column {border-bottom: 3px solid #b2b9c0; font-weight: bold; width: 10%}"
	,".patient-info {font-weight: bold; width: 10%}"
	,".patient-data-header {width: 17%; text-decoration: underline}"
	,".patient-data {width: 19%}"
	,".comment-box {height: 50px}"
	,"</style> </head>"
	,"<div id = print-container> <div class=print-header> <div class=printed-by-user>"
	,"<span> Printed By:  </span> <span>",printuser_name,"</span>"
	,"</div> <div class=print-title> <span> Physician Handoff </span> </div>"
	,"<div class=printed-date> <span>"
	,format(cnvtdatetime(curdate,curtime),"mm/dd/yyyy;;d")
	,"</span> </div> </div> </div>"
	,"<p class=print-title></p>"
	,'<div><b><table style="width:100%"><tr><tr>'
	,"<td class=column>Location</td>"
	,"<td class=column>Patient</td>"
	,"<td class=column>MRN</td>"
	,"<td class=column>Illness Severity</td>"
	,"<td class=column>Primary Contact</td>"
	,"<td class=column>Diagnosis</td>"
	,"<td class=column>Code Status</td>"
	,"<td class=column>Admit Date</td>"
	,"</tr></tr></table></b></div>"
	,patienthtml
	,"</body></html>")

;Send HTML string back to PowerChart for printing
if(validate(_memory_reply_string) = 1)
	set _memory_reply_string = finalhtml
else
	free record putrequest
   	record putrequest (
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line [*]
        2 linedata = vc
      1 overflowpage [*]
        2 ofr_qual [*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
	)
   	set putrequest->source_dir =  $OUTDEV
    set putrequest->isblob = "1"
   	set putrequest->document = finalhtml
   	set putrequest->document_size = size (putrequest->document)
   	execute eks_put_source with replace("REQUEST" ,putrequest), replace("REPLY" ,putreply)
endif


#exit_script
end
go