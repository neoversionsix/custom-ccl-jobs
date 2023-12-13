drop program wh_column_vis_mode_int go
create program wh_column_vis_mode_int

/* The reply record must be declared by the consuming script, with the appropriate person details already available.
record reply (
  1 person[*]
    2 person_id = f8
    2 encntr_id = f8
    2 ppr_cd = f8
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
%i cclsource:status_block.inc
) with protect
*/


declare PUBLIC::Main(null) = null with private
declare PUBLIC::ReasonForVisit(null) = null with protect

/**
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  call ReasonForVisit(null)
  set reply->status_data.status = "S"
end ; Main


/**
Determine the reason for visit of each person. Add the reason for visit to the person's content list. No secondary data is included.
@param null
@returns null
*/
subroutine PUBLIC::ReasonForVisit(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare REASON_FOR_VISIT_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAY_KEY", 16449, "REASONFOREXAM"))
  declare exp_idx = i4 with protect, noconstant(0)

	select into "nl:"
	from
		(dummyt   d  with seq = size(reply->person, 5))
	detail
		call alterlist(reply->person[d.seq].contents,1)
		reply->person[d.seq].contents[1].primary = "--"
	with nocounter

	select into "nl:"
	from sch_appt   sa
		, sch_booking   sb
		, sch_event_detail sed
	where expand(exp_idx, 1, PERSON_CNT, sa.encntr_id, reply->person[exp_idx].encntr_id)
	and sb.booking_id=sa.booking_id
	and sed.sch_event_id=sa.sch_event_id
	and sed.oe_field_id=REASON_FOR_VISIT_CD
	and sed.version_dt_tm=cnvtdatetime("31-DEC-2100")
	order by sa.encntr_id, sa.beg_effective_dt_tm desc
	head sa.encntr_id
		pos = LOCATEVAL(exp_idx, 1, PERSON_CNT, sa.encntr_id, reply->person[exp_idx].encntr_id)
		while(pos>0)
			reply->person[pos].contents[1].primary = sed.oe_field_display_value
			pos = LOCATEVAL(exp_idx, pos+1, PERSON_CNT, sa.encntr_id, reply->person[exp_idx].encntr_id)
		endwhile
	with nocounter,expand=1
end ; ReasonForVisit

call PUBLIC::Main(null)

#EXIT_SCRIPT

/* select into "nl:"
from prsnl p
where p.person_id = reqinfo->updt_id
and p.username="AI021650"
detail
	call echoxml(reply,"1ai_reply",0)
	;call echoxml(request,"1ai_request",0)
	;call echoxml(requestin,"1ai_requestin",0)
	call echorecord(reply)
with nocounter */

if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif

end
go
