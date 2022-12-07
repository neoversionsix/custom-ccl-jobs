/*--------------------------------------------------------------------------------
	Program Name.: CITY_CA_UNREVIEWED_MEDS
	Programmer...: David Pace
	Date.........: 09/07/2007
	Description..: Meds Given Prior to Nurse Review:  Report selects all Med
	               Clinical Events signed within a given date range and returns
	               all doses given for which the order was not reviewed at the time
	               the dose was given.
 
	               Various Date fields
 
	               Charted   : dt/tm med dose administration charted
	               Date Given: dt/tm chart indicates med dose was administered
	               Reviewed  : dt/tm med order reviewed
 
 
----------------------- <<<<< MODIFICATION LOG >>>>> -----------------------------
 
 xxxx  mm/dd/yyyy  Programmer
	Description of changes
 
----------------------------------------------------------------------------------*/
 
drop program city_ca_unreviewed_meds go
create program city_ca_unreviewed_meds
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "From Date" = "CURDATE"
	, "Thru Date" = "CURDATE"
	, "Nurse Unit(s)" = ""
	, "Report Type" = 1
	, "Output Format" = 0
 
with OUTDEV, frdate, todate, nunit, type, skip
 
free record ce
;define record structure of clinical_event_ids and fk to order_review
record ce(
	1 list[*]
		2 ceid = f8
		2 orvid = f8
	)
 
free record rec
record rec (
	1 unit[*]
		2	nu_cd = f8
	)
 
declare cnt = i4
 
;Nurse unit list from prompt selection
;This allows us to limit locations to Nursing units only when 'Any(*)' is selected
 
select into "nl:"
 
from
	code_value cv
 
where cv.code_set = 220
	and cv.display = $nunit
 
head report
 
	stat = alterlist(rec->unit,20)
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (size(rec->unit,5) < cnt)
		stat = alterlist(rec->unit, cnt +10)
	endif
 
	rec->unit[cnt].nu_cd = cv.code_value
 
foot report
	stat = alterlist(rec->unit, cnt)
 
with nocounter
 
set fin_cd = uar_get_code_by("DISPLAY",263,"FIN")
set mrn_cd = uar_get_code_by("DISPLAY",263,"MRN")
 
/*----------------------------------------------------------------------------
	Initialize & call layout subroutines
------------------------------------------------------------------------------*/
 
execute reportrtl
%i ccluserdir:city_ca_unreviewed_meds.dvl
set d0 = InitializeReport(0)
 
/*-------------------------------------------------------------------------
  Collect all Med Clinical Events.  We need this extra query because
  the fk we need exists in different fields depending on whether this
  is a one-time order or a repeating order.
---------------------------------------------------------------------------*/
 
select into "nl:"
	id = c.clinical_event_id,
	ptr = if(o.template_order_id = 0)
			o.order_id
		  else
		  	o.template_order_id
		  endif
 
from
	clinical_event c,
	orders o
 
plan c where c.clinsig_updt_dt_tm between cnvtdatetime($frdate) and cnvtdatetime(concat($todate,
" 23:59:59"))
    and c.event_class_cd = 232
    and c.result_status_cd = 25
 
join o where c.order_id = o.order_id
 
head report
 
	stat = alterlist(ce->list,5000)
	cnt = 0
 
detail
 
	cnt = cnt + 1
 
	if (size(ce->list,5) < cnt)
		stat = alterlist(ce->list, cnt + 500)
	endif
 
	ce->list[cnt].ceid = id
	ce->list[cnt].orvid = ptr
 
foot report
 
	stat = alterlist(ce->list, cnt)
 
with nocounter
 
/*-------------------------------------------------------------------------
                               Main Query
---------------------------------------------------------------------------*/
 
select into $outdev
	name = p.name_full_formatted,
	mrn = format(pa.alias,"########;rp0"),
	fin = ea.alias,
	unit = uar_get_code_display( el.loc_nurse_unit_cd ),
	room = uar_get_code_display( el.loc_room_cd ),
	bed = uar_get_code_display( el.loc_bed_cd ),
	ordered_as = uar_get_code_display( c.event_cd ),
	date_given = format(c.event_end_dt_tm,"mm/dd hh:mm;;q"),
	time_given = format(c.event_end_dt_tm,"hh:mm;;q"),
	charted = c.clinsig_updt_dt_tm "@SHORTDATETIME",
	signed = c.verified_dt_tm "@SHORTDATETIME",
	given_by = p1.name_full_formatted,
	reviewed = format(orv.review_dt_tm,"mm/dd hh:mm;;q"),
	reviewed_by = p2.name_full_formatted,
	c.order_id,
	o.template_order_id,
	c.result_val,
	ordertype = uar_get_code_display( o.med_order_type_cd ),
	status = uar_get_code_display( c.result_status_cd )
 
from
	(dummyt d with seq = value(size(ce->list,5))),
	clinical_event  c,
	orders  o,
	order_action oa,
	order_review  orv,
	prsnl  p1,
	prsnl  p2,
	encounter  e,
	encntr_alias  ea,
	person  p,
	person_alias  pa,
	encntr_loc_hist  el
 
plan d
 
join c where ce->list[d.seq].ceid = c.clinical_event_id
 
join o where c.order_id = o.order_id
 
join p1 where c.performed_prsnl_id = p1.person_id
 
join oa where ce->list[d.seq].orvid = oa.order_id
	and oa.action_sequence = (select max(oa1.action_sequence)
								from order_action oa1
								where oa1.order_id = oa.order_id
								and oa1.action_dt_tm < c.event_end_dt_tm)
 
join orv where oa.order_id = orv.order_id
	and oa.action_sequence = orv.action_sequence
	and (orv.review_dt_tm > c.event_end_dt_tm
		or orv.review_dt_tm is null)
	and (orv.location_cd not in (633869,13571246,13571298,13571356,13571453,44705610)) ;ED
 
join p2 where outerjoin(orv.review_personnel_id) = p2.person_id
    and p2.person_id > outerjoin(0)
 
join e where c.encntr_id = e.encntr_id
 
join p where c.person_id = p.person_id
 
join ea where c.encntr_id = ea.encntr_id
    and ea.active_ind = 1
    and ea.alias_pool_cd = fin_cd
    and ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
 
join pa where c.person_id = pa.person_id
    and pa.active_ind = 1
    and pa.alias_pool_cd = mrn_cd
    and pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
 
join el where c.encntr_id = el.encntr_id
    and el.beg_effective_dt_tm <= c.performed_dt_tm
    and el.end_effective_dt_tm >= c.performed_dt_tm
    and expand(cnt,1,size(rec->unit,5),el.loc_nurse_unit_cd,rec->unit[cnt].nu_cd)
 
order by
	unit,
	room,
	bed,
	date_given
 
/*-------------------------------------------------------------------------
	Reportwriter section - Use report layout builder
---------------------------------------------------------------------------*/
 
head report
 
	cnt = 0
 
head page
 
	if( curpage > 1)
		d0 = PageBreak(0)
	endif
 
	d0 = HeadPageSection(Rpt_Render)
 
head unit
 
	if($type = 1) ;Detail Report
		if( cnt > 0)
			Break
		endif
	endif
 
	cnt = 0
 
detail
 
	if(_YOffset + DetailSection(Rpt_CalcHeight) > 9.5)
		Break
	endif
 
	if ($type = 1) ; Detail Report
		d0 = DetailSection(Rpt_Render)
	endif
 
	cnt = cnt + 1
 
foot unit
 
	if(_YOffset + FootUnitSection(Rpt_CalcHeight) > 9.5)
		Break
	endif
 
	d0 = FootUnitSection(Rpt_Render)
 
 
foot page
 
	d0 = FootPageSectionABS(Rpt_Render, _XOffset, 10.0)
 
 
with format, separator = " ", skipreport = $skip
 
;Direct output to output device queue
if ($skip = 0)
	set d0 = FinalizeReport($outdev)
endif
 
end
go
 