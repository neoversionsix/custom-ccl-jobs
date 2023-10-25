/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_open_doc:dba go
create program mp_wlfw_custom_column_open_doc:dba
/**
Determine the number of in-progress documents for each received visit.
*/
 
/***********************************************************************************************************************************
* DECLARATIONS *********************************************************************************************************************
***********************************************************************************************************************************/

/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record must be declared by the consuming script, with the appropriate person details available.

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
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/
declare PUBLIC::Main(null) = null with private
declare PUBLIC::DetermineInProgressDocCount(null) = null with protect

/***********************************************************************************************************************************
* Main PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
call Main(null)
 
/***********************************************************************************************************************************
* SUBROUTINES **********************************************************************************************************************
***********************************************************************************************************************************/
 
/***********************************************************************************************************************************
* Main                                                                                                                             *
***********************************************************************************************************************************/
/**
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  call DetermineInProgressDocCount(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineInProgressDocCount                                                                                                      *
***********************************************************************************************************************************/
/**
Determine the number of in-progress clinical event documents for each encounter. Supply the count to the reply, but no pop-up 
details.
@param null
@returns null
*/
subroutine PUBLIC::DetermineInProgressDocCount(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare RESULT_IN_PROGRESS_STATUS_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 8, "IN PROGRESS"))
  declare EVENT_DOC_CLASS_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 53, "DOC"))
  declare EVENT_MDOC_CLASS_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 53, "MDOC"))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      doc_cnt = COUNT(ce.event_id) OVER(PARTITION BY ce.encntr_id) ; OLAP expression to get document count per visit.
    from clinical_event ce
      where EXPAND(exp_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[exp_idx].encntr_id)
        and ce.valid_until_dt_tm > CNVTDATETIME(curdate, curtime3)
        and ce.result_status_cd = RESULT_IN_PROGRESS_STATUS_CD
        and ce.event_class_cd in (EVENT_DOC_CLASS_CD, EVENT_MDOC_CLASS_CD)
    order by ce.encntr_id
    head report
      person_idx = 0
    head ce.encntr_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)

      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        reply->person[person_idx].count = CNVTINT(doc_cnt)
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
  with nocounter
end ; DetermineInProgressDocCount
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
