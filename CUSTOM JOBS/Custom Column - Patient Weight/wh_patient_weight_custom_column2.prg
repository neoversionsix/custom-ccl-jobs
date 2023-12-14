drop program wh_patient_weight_custom_colum:dba go
create program wh_patient_weight_custom_colum:dba
/**
Determine the Result Indicator for heart rate for each each patient
*/
 
/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record
/* The request record is passed in as a JSON object, and converted to a persistscript record. It contains a patient list and the
duisplay_style for results */
/*
record reply (
  1 person[*]
    2 person_id   = f8
    2 encntr_id   = f8
    2 ppr_cd      = f8
    2 layout_flag = i4
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
      3 link_type = vc
      3 link_params = vc
      3 display_style = vc
 
%i cclsource:status_block.inc
) with protect
*/
 
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/

declare PUBLIC::Main(null) = null with private
declare PUBLIC::GetWeight(null) = null with protect
 
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
  call GetWeight(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* GetResultIndicator                                                                                                      *
***********************************************************************************************************************************/
/**
Determine the Result Indicator for heart rate for each patient
@param null
@returns null
*/
subroutine PUBLIC::GetWeight(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  declare cnt = i4 with protect, noconstant(0)
  
;   for(pt_idx = 1 to PERSON_CNT)
;     set reply->person[pt_idx].layout_flag = 1
;     set reply->person[pt_idx].icon = "images/6627_16.png"
;   endfor
 
  select
    into "nl:"
      enctr = ce.encntr_id
    from clinical_event ce
      where EXPAND(exp_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[exp_idx].encntr_id)
        AND ce.event_cd = 7334438 ; Filters Weight Measured
	    AND ce.valid_until_dt_tm > SYSDATE ; not invalid time
	    AND ce.publish_flag = 1 ; publish
        AND ce.view_level = 1; viewable
        ; only weights recorded in the last 3 months
        ; AND ce.event_end_dt_tm BETWEEN CNVTLOOKBEHIND("3,M") AND CNVTDATETIME(CURDATE,CURTIME3) 
        AND c.UPDT_DT_TM = (
		    select MAX(CE_DUMMY.UPDT_DT_TM)
		    from CLINICAL_EVENT CE_DUMMY
		    where
			    EXPAND(exp_idx, 1, PERSON_CNT, CE_DUMMY.encntr_id, reply->person[exp_idx].encntr_id)
				AND
				CE_DUMMY.event_cd = 7334438 ; Filters Weight Measured
				AND 
				CE_DUMMY.valid_until_dt_tm > SYSDATE ; not invalid time
				AND 
				CE_DUMMY.publish_flag = 1 ; publish
				AND 
				CE_DUMMY.view_level = 1; viewable
	    )
     order by 
      c.person_id
      , 
      c.updt_dt_tm asc ; the asc ord desc here changes to most recent Weight
    head report
      person_idx = 0
    head c.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, c.person_id, reply->person[loc_idx].person_id)
 
      ; Since the same person could have multiple visits in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        ; Add the result string to the contents list for the current person.
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].contents[1].primary = c.result_val
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, c.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; GetWeight
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 