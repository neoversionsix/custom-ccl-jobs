/**
Retrieve Patient "Weight Measured"
Programmer: Jason Whittle
Requestor: Alison Qvist
Date 25th of November 2022
*/

drop program wh_patient_weight_custom_column go
create program wh_patient_weight_custom_column

 declare PUBLIC::Main(null) = null with private
declare PUBLIC::GetWeight(null) = null with protect
call Main(null)
 subroutine PUBLIC::Main(null)
  call GetWeight(null)
  set reply->status_data.status = "S"
end ; Main
 
subroutine PUBLIC::GetWeight(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
 
  select
    into "nl:"
    from clinical_event   c
      where EXPAND(exp_idx, 1, PERSON_CNT, c.person_id, reply->person[exp_idx].person_id)
        ;and c.sex_cd > 0
        AND c.event_cd = 86163053 ; Filters Weight Measured
	      AND c.valid_until_dt_tm > SYSDATE ; not invalid time
	      AND c.publish_flag = 1 ; publish
        AND c.view_level = 1; viewable
    order by c.person_id, c.updt_dt_tm asc ; the asc ord desc here changes to most recent Weight
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