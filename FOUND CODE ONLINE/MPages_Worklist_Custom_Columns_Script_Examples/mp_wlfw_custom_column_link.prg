/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 04/06/2016 vm033103  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_link:dba go
create program mp_wlfw_custom_column_link:dba
/**
Determine the number of document links available for present patient.
*/
 
/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record
/* The request record is passed in as a JSON object, and converted to a persistscript record. It contains a patient list and the 
link types for the popover view */
/*
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
      3 link_type = vc
      3 link_params = vc
%i cclsource:status_block.inc
) with protect
*/
 
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/
declare PUBLIC::Main(null) = null with private
declare PUBLIC::DetermineDocLinks(null) = null with protect
 
/***********************************************************************************************************************************
* Main PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
call Main(null)
 
/***********************************************************************************************************************************
* Main                                                                                                                             *
***********************************************************************************************************************************/
/**
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  call DetermineDocLinks(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineDocLinks                                                                                                      *
***********************************************************************************************************************************/
/**
Determine the number of Auth (Verified) clinical event documents for each encounter.
@param null
@returns null
*/
subroutine PUBLIC::DetermineDocLinks(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare RESULT_AUTH_VERIFIED_STATUS_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 8, "AUTH"))
  declare EVENT_DOC_CLASS_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 53, "DOC"))
  declare DYNAMICDOCUMENTATION_VAR = f8 with Constant(uar_get_code_by("MEANING",29520,"DYNDOC")),protect
  declare POWERNOTE_VAR = f8 with Constant(uar_get_code_by("MEANING",29520,"POWERNOTE")),protect  
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  declare cnt = i4 with protect, noconstant(0)
  declare pt_idx = i4 with protect, noconstant(0)
  
  for(pt_idx = 1 to size(reply->person, 5))
    call ALTERLIST(reply->person[pt_idx].contents, 4)
    set reply->person[pt_idx].contents[1].link_type = 'ADMMEDREC'
    set reply->person[pt_idx].contents[1].primary = 'Admission Meds Rec'
    set reply->person[pt_idx].contents[2].link_type = 'TRANSMEDREC'
    set reply->person[pt_idx].contents[2].primary = 'Transfer Meds Rec'
    set reply->person[pt_idx].contents[3].link_type = 'DISCHMEDREC'
    set reply->person[pt_idx].contents[3].primary = 'Discharge Meds Rec'
    set reply->person[pt_idx].contents[4].link_type = 'MEDSHISTORY'
    set reply->person[pt_idx].contents[4].primary = 'Medication History'
  endfor
 
  select
    into "nl:"
      doc_cnt = COUNT(ce.event_id) OVER(PARTITION BY ce.encntr_id) ; OLAP expression to get document count per visit.
    from clinical_event ce
      where EXPAND(exp_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[exp_idx].encntr_id)
        and ce.valid_until_dt_tm > CNVTDATETIME(curdate, curtime3)
        and ce.result_status_cd = RESULT_AUTH_VERIFIED_STATUS_CD
        and ce.event_class_cd in (EVENT_DOC_CLASS_CD)
        and ce.event_end_dt_tm BETWEEN CNVTLOOKBEHIND("3,M") AND CNVTDATETIME(CURDATE,CURTIME3) 

    order by ce.encntr_id
    head report
      person_idx = 0
    head ce.encntr_id
      cnt = 0
    detail
    person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        cnt = size(reply->person[person_idx].contents,5)
        if(ce.entry_mode_cd = DYNAMICDOCUMENTATION_VAR)
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.event_tag
          reply->person[person_idx].contents[cnt].secondary = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
          reply->person[person_idx].contents[cnt].link_type = 'DD'  ;build2(uar_get_code_display(ce.entry_mode_cd))
          reply->person[person_idx].contents[cnt].link_params = build(ce.event_id)
        elseif(ce.entry_mode_cd = POWERNOTE_VAR)
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.event_tag
          reply->person[person_idx].contents[cnt].secondary = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
          reply->person[person_idx].contents[cnt].link_type = 'PN'
          reply->person[person_idx].contents[cnt].link_params = build(ce.event_id)
        endif
        reply->person[person_idx].count = cnt     
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile

  with nocounter
  
  select
    into "nl:"
    from dcp_forms_activity dfa
      where EXPAND(exp_idx, 1, PERSON_CNT, dfa.encntr_id, reply->person[exp_idx].encntr_id)
        and dfa.active_ind = 1
    and dfa.form_dt_tm BETWEEN CNVTLOOKBEHIND("3,M") AND CNVTDATETIME(CURDATE,CURTIME3) 
        and dfa.form_status_cd = RESULT_AUTH_VERIFIED_STATUS_CD

    order by dfa.encntr_id
    head report
      person_idx = 0
    head dfa.encntr_id
      cnt = 0
    detail
    person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, dfa.encntr_id, reply->person[loc_idx].encntr_id)
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        cnt = size(reply->person[person_idx].contents,5)
        cnt = cnt + 1
        call ALTERLIST(reply->person[person_idx].contents, cnt)
        reply->person[person_idx].contents[cnt].primary = dfa.description
        reply->person[person_idx].contents[cnt].secondary = 'PF'
        reply->person[person_idx].contents[cnt].link_type = 'PF'
        reply->person[person_idx].contents[cnt].link_params = build(dfa.dcp_forms_ref_id, "|", dfa.dcp_forms_activity_id)

        reply->person[person_idx].count = cnt     
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, dfa.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile

  with nocounter
end ; DetermineDocLinks
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 