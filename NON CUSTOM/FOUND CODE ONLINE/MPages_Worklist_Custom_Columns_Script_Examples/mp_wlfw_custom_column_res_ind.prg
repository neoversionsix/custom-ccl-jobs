/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 05/15/2016 vm033103  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_res_ind:dba go
create program mp_wlfw_custom_column_res_ind:dba
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
declare PUBLIC::GetResultIndicator(null) = null with protect
 
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
  call GetResultIndicator(null)
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
subroutine PUBLIC::GetResultIndicator(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare HEART_RATE_EVENT_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAY_KEY", 72, "HEARTRATE"))
  declare HEARTRATEAPNEA_EVENT_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAY_KEY", 72, "HEARTRATEAPNEA"))
  declare APICALHEARTRATE_EVENT_CD = f8 WITH protect ,constant (UAR_GET_CODE_BY ("DISPLAY_KEY" ,72 ,
    "APICALHEARTRATE" ) )
  declare NORMALCY_CODE_HIGH = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 52, "HIGH"))
  declare NORMALCY_CODE_CRITICAL = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 52, "CRITICAL"))
  declare NORMALCY_CODE_ABNORMAL = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 52, "ABNORMAL"))
  declare NORMALCY_CODE_NORMAL = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 52, "NORMAL"))
  declare NORMALCY_CODE_LOW = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 52, "LOW"))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  declare cnt = i4 with protect, noconstant(0)
  
  for(pt_idx = 1 to PERSON_CNT)
    set reply->person[pt_idx].layout_flag = 1
    set reply->person[pt_idx].icon = "images/6627_16.png"
  endfor
 
  select
    into "nl:"
      enctr = ce.encntr_id
    from clinical_event ce
      where EXPAND(exp_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[exp_idx].encntr_id)
        and ce.valid_until_dt_tm > CNVTDATETIME(curdate, curtime3)
        and ce.event_cd in (HEART_RATE_EVENT_CD, HEARTRATEAPNEA_EVENT_CD, APICALHEARTRATE_EVENT_CD)
        and ce.event_end_dt_tm BETWEEN CNVTLOOKBEHIND("3,M") AND CNVTDATETIME(CURDATE,CURTIME3)
 
    order by ce.encntr_id
    head report
      person_idx = 0
    head ce.encntr_id
      cnt = 0
    detail
    person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      while (person_idx > 0)
        cnt = size(reply->person[person_idx].contents,5)
        if(ce.normalcy_cd = NORMALCY_CODE_HIGH)
          reply->person[person_idx].layout_flag = 3
          reply->person[person_idx].icon = ""
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.result_val
          reply->person[person_idx].contents[cnt].display_style = "result-high"
        elseif(ce.normalcy_cd = NORMALCY_CODE_CRITICAL)
          reply->person[person_idx].layout_flag = 3
          reply->person[person_idx].icon = ""
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.result_val
          reply->person[person_idx].contents[cnt].display_style = "result-critical"
        elseif(ce.normalcy_cd = NORMALCY_CODE_ABNORMAL)
          reply->person[person_idx].layout_flag = 3
          reply->person[person_idx].icon = ""
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.result_val
          reply->person[person_idx].contents[cnt].display_style = "result-abnormal"
        elseif(ce.normalcy_cd = NORMALCY_CODE_LOW)
          reply->person[person_idx].layout_flag = 3
          reply->person[person_idx].icon = ""
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.result_val
          reply->person[person_idx].contents[cnt].display_style = "result-low"
        elseif(ce.normalcy_cd = NORMALCY_CODE_NORMAL)
          reply->person[person_idx].layout_flag = 3
          reply->person[person_idx].icon = ""
          cnt = cnt + 1
          call ALTERLIST(reply->person[person_idx].contents, cnt)
          reply->person[person_idx].contents[cnt].primary = ce.result_val
          reply->person[person_idx].contents[cnt].display_style = "result-normal"
        endif
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
 
  with nocounter
end ; GetResultIndicator
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 